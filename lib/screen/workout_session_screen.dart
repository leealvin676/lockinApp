import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final String? workoutType;

  const WorkoutSessionScreen({super.key, this.workoutType});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  Timer? timer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void finishWorkout() {
    stopTimer();

    final durationMinutes = (seconds / 60).round();

    // Simple calorie estimate (you can improve this later)
    final caloriesBurned = durationMinutes * 5;

    final box = Hive.box('workouts');

    box.add({
      "date": DateTime.now().toIso8601String(),
      "duration": durationMinutes.toString(),
      "calories": caloriesBurned.toString(),
      "type": widget.workoutType ?? "General",
    });

    Navigator.pop(context, true);
  }

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Workout Session"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.workoutType ?? "Workout",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),

            const SizedBox(height: 20),

            Text(
              formatTime(seconds),
              style: const TextStyle(
                color: Colors.lime,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: finishWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lime,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 16),
              ),
              child: const Text(
                "Finish Workout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
}