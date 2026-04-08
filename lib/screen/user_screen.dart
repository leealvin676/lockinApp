import 'package:flutter/material.dart';
import 'user_form.dart';
import '../theme/colors.dart';

class UserScreen extends StatelessWidget {
  final users = [
    {"name": "John Doe", "goal": "Weight Loss"},
    {"name": "Sarah Lee", "goal": "Muscle Gain"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ...users.map((u) => userCard(context, u)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => UserForm())),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget userCard(BuildContext context, Map user) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(user["name"]),
        subtitle: Text(user["goal"]),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => UserForm())),
      ),
    );
  }
}