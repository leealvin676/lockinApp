import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lockinapp/screen/add_workout_screen.dart';
import 'package:lockinapp/screen/auth_user/login_screen.dart';
import 'package:lockinapp/screen/auth_user/register_screen.dart';
import 'package:lockinapp/screen/history_screen.dart';
import 'package:lockinapp/screen/home_screen.dart';
import 'package:lockinapp/screen/workout_session_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open all required boxes BEFORE running the app
  await Hive.openBox('users');
  await Hive.openBox('userBox');
  await Hive.openBox('userData');
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

        '/workoutSession': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as String?;

          return WorkoutSessionScreen(workoutType: args);
        },
      },
    );
  }
}