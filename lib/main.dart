import 'dart:developer';

import 'package:divertidachat/common/theme.dart';
import 'package:divertidachat/models/models.dart';
import 'package:divertidachat/pages/pages.dart';
import 'package:divertidachat/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MultiProvider(providers: [
    Provider(create: (_) => ApiService('http://10.0.2.2:8080')),
    Provider(create: (_) => WebSocketService('ws://10.0.2.2:8080')),
    Provider(
        create: (context) => GoogleAuthService(context.read<ApiService>())),
    Provider(create: (context) => ChatService(context.read<ApiService>())),
    Provider(create: (context) => UserService(context.read<ApiService>())),
    ChangeNotifierProvider(
        create: (context) => AuthState(context.read<GoogleAuthService>())),
    ChangeNotifierProvider(
      create: (context) => HomeState(
        context.read<WebSocketService>(),
        context.read<ChatService>(),
        context.read<UserService>(),
      ),
    ),
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

class HomeState with ChangeNotifier {
  final WebSocketService _webSocketService;
  final ChatService _chatService;
  final UserService _userService;

  final Map<String, ChatDetails> _chats = {};
  Map<String, ChatDetails> get chats => _chats;

  final List<TextFilter> _textFilters = [];
  List<TextFilter> get textFilters => _textFilters;

  TextFilter _activeTextFilter;
  TextFilter get activeTextFilter => _activeTextFilter;

  HomeState(this._webSocketService, this._chatService, this._userService)
      : _activeTextFilter =
            TextFilter(id: 0, name: 'Default', emoji: '', command: '');

  Future<void> loadChats() async {
    // Fetch the updated timestamps
    List<ChatTimestamp> timestamps = await _chatService.getTimestamps();

    // TODO: Check the chats that need to be updated on the database

    // Fetch the chats based on the timestamps
    List<String> chatIds = timestamps.map((e) => e.chatId).toList();
    final chats = await _chatService.getAllUpdatedChats(chatIds);

    // Fetch the text filters, and set the default as the first one
    final textFilters = await _chatService.getTextFilters();
    _textFilters.clear();
    _textFilters.addAll(textFilters);
    setActiveTextFilter(textFilters[0]);

    _chats.clear();
    _chats.addAll(chats);
    notifyListeners();
  }

  void setActiveTextFilter(TextFilter textFilter) {
    _activeTextFilter = textFilter;
    log('Active text filter set to: ${textFilter.name}');
    notifyListeners();
  }

  void sendMessage(String userId, String chatId, String text) async {
    log('Sending message: $text to chat: $chatId');
    final message = WebSocketMessage(
      id: Uuid().v4(),
      chatId: chatId,
      chatName: _chats[chatId]?.chatName ?? '',
      senderId: userId,
      sentAt: DateTime.now(),
      text: text,
      textFilterId: activeTextFilter.id,
    );

    // Send the message through the WebSocket
    _webSocketService.sendMessage(message);
  }

  void listen(BuildContext context) {
    _webSocketService.listen((data) async {
      final message = WebSocketMessage.fromJson(data);
      final chatId = message.chatId;

      final newMessage = Message(
        id: message.id,
        chatId: chatId,
        senderId: message.senderId,
        sentAt: message.sentAt,
        text: message.text,
      );

      // Check if the chat already exists in the map
      if (!_chats.containsKey(chatId)) {
        ChatDetails newChat = await _chatService.getSingleUpdatedChat(chatId);
        _chats[chatId] = newChat;
      }

      // Add the new message to the corresponding chat
      _chats[chatId]!.messages.insert(0, newMessage);

      notifyListeners();
    }, context);
  }

  void connect(String userId) {
    _webSocketService.connect(userId);
  }

  void disconnect() {
    _webSocketService.close();
  }

  Future<User?> searchUser(String username, BuildContext context) async {
    try {
      final user = await _userService.getUser(username);
      return user;
    } catch (e) {
      // Handle user not found
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
    return null;
  }

  Future<void> createChat(String username) async {
    try {
      final chat = await _chatService.createChat(username);
      _chats[chat.chatId] = ChatDetails(
        chatId: chat.chatId,
        chatName: chat.chatName,
        isGroup: false,
        messages: [],
        participants: chat.participants,
      );
      notifyListeners();
    } catch (e) {
      // Handle error
      throw Exception('Failed to create chat: $e');
    }
  }
}
