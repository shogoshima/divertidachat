import 'package:divertidachat/common/secure_storage.dart';
import 'package:divertidachat/models/user.dart';
import 'package:divertidachat/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final ApiService api;

  GoogleAuthService(this.api);

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    serverClientId:
        '830238838384-2stg8g2od1tmudfcfo0f6psbalsuct31.apps.googleusercontent.com',
  );

  Future<User?> signIn() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final data = await api.post('/auth/login', {}, googleAuth.idToken);
    if (data == null) {
      throw Exception('Failed to authenticate with Google');
    }

    final token = data['token'];
    final storage = SecureStorage();
    await storage.setToken(token);

    final user = User.fromJson(data['user']);
    return user;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      throw Exception('Failed to sign out: $error');
    }
  }

  Future<User?> getCurrentUser() async {
    final storage = SecureStorage();
    final jwtToken = await storage.getToken();
    if (jwtToken == null) {
      return null;
    }
    try {
      final data = await api.get('/users/me', jwtToken);

      if (data == null) {
        return null;
      }
      return User.fromJson(data['user']);
    } catch (error) {
      throw Exception('Error $error');
    }
  }
}
