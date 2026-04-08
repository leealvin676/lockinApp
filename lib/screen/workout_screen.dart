import 'package:flutter/material.dart';
import '../theme/colors.dart';

class WorkoutScreen extends StatelessWidget {
  final users = ["John Doe", "Sarah Lee"];

  @override
  Widget build(BuildContext context) {
    String? selectedUser;

    return Scaffold(
      appBar: AppBar(title: Text("Workout Plans")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            field("Plan Title"),
            field("Description"),

            DropdownButtonFormField(
              hint: Text("Assign User"),
              items: users.map((u) {
                return DropdownMenuItem(value: u, child: Text(u));
              }).toList(),
              onChanged: (val) {
                selectedUser = val;
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () {},
              child: Text("Create Plan", style: TextStyle(color: Colors.black)),
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