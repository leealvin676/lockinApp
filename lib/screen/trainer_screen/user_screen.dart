import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  final users = const [
    {"name": "John Doe", "goal": "Weight Loss"},
    {"name": "Sarah Lee", "goal": "Muscle Gain"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...users.map((u) => userCard(context, u)).toList(),

        const SizedBox(height: 20),

        // ➕ ADD USER BUTTON (FULL WIDTH like modern UI)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lime,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text("Add User",
              style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget userCard(BuildContext context, Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user["name"],
              style: const TextStyle(color: Colors.white, fontSize: 16)),

          Text(user["goal"],
              style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/workoutPlan');
                  },
                  child: const Text("Workout Plan",
                      style: TextStyle(color: Colors.black)),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/recommendation');
                  },
                  child: const Text("Recommendation",
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}