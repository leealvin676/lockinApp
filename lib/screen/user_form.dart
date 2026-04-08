import 'package:flutter/material.dart';
import '../theme/colors.dart';

class UserForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Form")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            field("Name"),
            field("Email"),
            field("Goal"),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {},
              child: Text("Save", style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  Widget field(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.black,
        ),
      ),
    );
  }
}