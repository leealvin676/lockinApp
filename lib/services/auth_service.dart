import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<Box> _getUserBox() async {
    if (!Hive.isBoxOpen('users')) {
      await Hive.openBox('users');
    }
    return Hive.box('users');
  }

  // REGISTER
  Future<bool> register(String name, String email, String password) async {
    final box = await _getUserBox();

    for (var user in box.values) {
      if (user['email'] == email) {
        return false;
      }
    }

    await box.add({
      "name": name,
      "email": email,
      "password": password,
    });

    return true;
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    final box = await _getUserBox();

    for (var user in box.values) {
      if (user['email'] == email && user['password'] == password) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('name', user['name']);
        await prefs.setString('currentUser', email);

        return true;
      }
    }
    return false;
  }
}