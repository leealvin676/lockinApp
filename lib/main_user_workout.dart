import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lockinapp/screen/add_workout_screen.dart';
import 'package:lockinapp/screen/auth_user/login_screen.dart';
import 'package:lockinapp/screen/auth_user/register_screen.dart';
import 'package:lockinapp/screen/history_screen.dart';
import 'package:lockinapp/screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('users');
  await Hive.openBox('workouts');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LockIN App',
      theme: ThemeData.dark(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/addWorkout': (context) => const AddWorkoutScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}