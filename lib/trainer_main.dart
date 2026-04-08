import 'package:flutter/material.dart';
import 'screen/trainer_login.dart';
import 'theme/colors.dart';

void main() {
  runApp(LockInApp());
}

class LockInApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: TrainerLogin(),
    );
  }
}