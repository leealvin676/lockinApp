import 'package:flutter/material.dart';
import '../theme/colors.dart';

class TrainerProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, color: Colors.black, size: 40),
            ),
            SizedBox(height: 10),
            Text("Alex Trainer", style: TextStyle(fontSize: 20)),
            Text("Fitness Coach", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {},
              child: Text("Edit Profile", style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}