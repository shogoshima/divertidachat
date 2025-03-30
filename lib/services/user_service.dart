import 'package:divertidachat/common/secure_storage.dart';
import 'package:divertidachat/models/models.dart';
import 'package:divertidachat/services/services.dart';

class UserService {
  final ApiService api;

  UserService(this.api);

  Future<User> getUser(String username) async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final data = await api.get('/users/username/$username', token);

    return User.fromJson(data['user']);
  }
}
