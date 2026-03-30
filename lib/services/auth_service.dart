import 'package:hive/hive.dart';

class AuthService {
  final Box userBox = Hive.box('users');

  // REGISTER
  Future<bool> register(String name, String email, String password) async {
    // check if user already exists
    for (var user in userBox.values) {
      if (user['email'] == email) {
        return false;
      }
    }

    await userBox.add({
      "name": name,
      "email": email,
      "password": password,
    });

    return true;
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    for (var user in userBox.values) {
      if (user['email'] == email &&
          user['password'] == password) {
        return true;
      }
    }
    return false;
  }
}