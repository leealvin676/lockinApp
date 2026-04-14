import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerWorkoutPlanPage extends StatefulWidget {
  final String userName;

  const TrainerWorkoutPlanPage({super.key, required this.userName});

  @override
  State<TrainerWorkoutPlanPage> createState() =>
      _TrainerWorkoutPlanPageState();
}

class _TrainerWorkoutPlanPageState
    extends State<TrainerWorkoutPlanPage> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  final supabase = Supabase.instance.client;

  Future<void> savePlan() async {
    final trainer = supabase.auth.currentUser;

    if (titleController.text.isEmpty ||
        descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    await supabase.from('workout_plans').insert({
      'user_name': widget.userName,
      'trainer_id': trainer?.id,
      'title': titleController.text,
      'description': descController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout plan saved")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Workout Plan"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text(
              "Client: ${widget.userName}",
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Plan Title",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Workout details...",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2196F3),
                ),
                onPressed: savePlan,
                child: const Text("Save Plan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}