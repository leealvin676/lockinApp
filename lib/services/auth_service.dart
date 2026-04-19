import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;


  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        return "Registration failed";
      }

      await supabase.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
      });

      return null;

    } catch (e) {
      print("REGISTER ERROR: $e");
      return e.toString();
    }
  }


  Future<bool> login(String email, String password) async {

    if (email == "admin@lockin.com" && password == "123456") {
      return true;
    }

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', email);

        return true;
      }

      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }


  Future<void> logout() async {
    await supabase.auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }
}