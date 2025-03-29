import 'package:divertidachat/common/theme.dart';
import 'package:divertidachat/models/models.dart';
import 'package:divertidachat/pages/pages.dart';
import 'package:divertidachat/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    Provider(create: (_) => ApiService('http://192.168.15.5:8080')),
    Provider(
        create: (context) => GoogleAuthService(context.read<ApiService>())),
    ChangeNotifierProvider(
        create: (context) => AuthState(context.read<GoogleAuthService>())),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DivertidaChat',
      theme: theme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _authFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the authentication check only once.
    _authFuture =
        Provider.of<AuthState>(context, listen: false).checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authFuture,
      builder: (context, snapshot) {
        // While waiting for the auth check to complete, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Once the future completes, use a Consumer to decide which page to show.
        return Consumer<AuthState>(
          builder: (context, authState, child) {
            if (authState.isAuthenticated) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        );
      },
    );
  }
}

class AuthState with ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  final GoogleAuthService _googleAuthService;
  AuthState(this._googleAuthService);

  Future<void> signIn() async {
    _user = await _googleAuthService.signIn();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleAuthService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthentication() async {
    _user = await _googleAuthService.getCurrentUser();
    notifyListeners();
  }
}
