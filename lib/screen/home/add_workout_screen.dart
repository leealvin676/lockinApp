import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/db_helper.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final durationController = TextEditingController();
  final notesController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();

  void saveWorkout(String type) async {
    // 🔍 Validation

    if ((type == "Cardio" || type == "Yoga") &&
        durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter duration")),
      );
      return;
    }

    if (type == "Strength") {
      if (setsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter sets")),
        );
        return;
      }

      if (repsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter reps")),
        );
        return;
      }
    }

    if (notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter notes")),
      );
      return;
    }



    await DBHelper().insertWorkout({
      "type": type,
      "duration": (type == "Strength")
          ? null
          : int.tryParse(durationController.text) ?? 0,
      "sets": (type == "Strength")
          ? int.tryParse(setsController.text) ?? 0
          : null,
      "reps": (type == "Strength")
          ? int.tryParse(repsController.text) ?? 0
          : null,
      "notes": notesController.text,
      "date": DateTime.now().toIso8601String(),
    });

    print("INSERT SUCCESS 🔥");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout saved!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String type =
    ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("$type Workout"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            if (type == "Cardio" || type == "Yoga") ...[
              Row(
                children: const [
                  Icon(Icons.timelapse, color: Colors.grey, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "Duration (minutes)",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              TextField(
                controller: durationController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText: "40",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ]


            else if (type == "Strength") ...[
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.layers, color: Colors.grey, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "Sets",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              TextField(
                controller: setsController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText: "Sets",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Icon(Icons.loop, color: Colors.grey, size: 20),
                  SizedBox(width: 6),
                  Text(
                    "Reps",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              TextField(
                controller: repsController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText: "Reps",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],

            const SizedBox(height: 10),


            Row(
              children: const [
                Icon(Icons.note_alt_outlined, color: Colors.grey, size: 20),
                SizedBox(width: 6),
                Text(
                  "Notes",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            TextField(
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Notes",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => saveWorkout(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.limeAccent,
              ),
              child: const Text(
                "Save Workout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}