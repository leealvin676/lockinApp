import 'package:flutter/material.dart';
import '../theme/colors.dart';

class RecommendationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recommendations")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Enter Tips",
                filled: true,
                fillColor: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {},
              child: Text("Update", style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}