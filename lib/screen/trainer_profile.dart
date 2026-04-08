import 'package:flutter/material.dart';

class TrainerProfile extends StatelessWidget {
  const TrainerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.lime,
          ),
          padding: const EdgeInsets.all(20),
          child: const Icon(Icons.person, size: 40, color: Colors.black),
        ),

        const SizedBox(height: 10),

        const Text(
          "Alex Trainer",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),

        const Text(
          "Fitness Coach",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 15),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lime,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Edit Profile",
                style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
}