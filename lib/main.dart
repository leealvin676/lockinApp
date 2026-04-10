import 'package:flutter/material.dart';
import 'package:lockinapp/MainNavigation.dart';


import 'package:lockinapp/screen/home/add_workout_screen.dart';
import 'package:lockinapp/screen/admin/adminlogin.dart';
import 'package:lockinapp/screen/home/auth_user/login_screen.dart';
import 'package:lockinapp/screen/home/auth_user/register_screen.dart';
import 'package:lockinapp/screen/home/history_screen.dart';
import 'package:lockinapp/screen/home/home_screen.dart';
import 'package:lockinapp/screen/home/workout_session_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lockinapp/screen/trainer_screen/trainer_login.dart';

import 'package:lockinapp/screen/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jjuwccjrjzvuluejbbfw.supabase.co',
    anonKey: 'sb_publishable_Hx_2HcYWliXpTlqyywsZ4A_Qhj4s_6d',
  );

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

      initialRoute: '/login', // ✅ 保留这个

      routes: {

        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // 🔥🔥🔥 这里改！
        '/home': (context) => const MainNavigation(),

        '/addWorkout': (context) => const AddWorkoutScreen(),
        '/history': (context) => const HistoryScreen(),

        '/workoutSession': (context) {
          final args =
          ModalRoute.of(context)!.settings.arguments as String?;
          return WorkoutSessionScreen(workoutType: args);
        },

        // =====================
        // ADMIN
        // =====================
        '/adminLogin': (context) => const AdminLogin(),
        '/trainerLogin': (context) => TrainerLogin()
      },
    );
  }
}