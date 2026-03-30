import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lockinapp/widgets/animated_workout_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";

  int todayMinutes = 0;
  int streak = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadStats();
  }

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? "User";
    });
  }

  void loadStats() {
    final box = Hive.box('workouts');

    int totalToday = 0;
    Set<String> workoutDays = {};

    final now = DateTime.now();

    for (int i = 0; i < box.length; i++) {
      final workout = box.getAt(i);

      final date = DateTime.parse(workout['date']);
      final duration =
          int.tryParse(workout['duration'] ?? "0") ?? 0;

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        totalToday += duration;
      }

      workoutDays.add("${date.year}-${date.month}-${date.day}");
    }

    int currentStreak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    while (true) {
      String key =
          "${checkDate.year}-${checkDate.month}-${checkDate.day}";

      if (workoutDays.contains(key)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    setState(() {
      todayMinutes = totalToday;
      streak = currentStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(now);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("LockIN"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('currentUser');
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, $userName",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
          ),

          const SizedBox(height: 5),

          Text(
            "Let's crush your fitness goals today",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 20),

          //Daily Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Summary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton("Start Workout", Icons.play_arrow, () {
                Navigator.pushNamed(context, '/addWorkout');
              }),
              buildButton("History", Icons.history, () {
                Navigator.pushNamed(context, '/history');
              }),
            ],
          ),

          const SizedBox(height: 30),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Workout Types",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView(
                      children: [
                        AnimatedWorkoutCard(
                          title: "Cardio",
                          imagePath: "assets/images/cardio.jpg",
                          onTap: () {
                            Navigator.pushNamed(context, '/addWorkout', arguments: "Cardio");
                          },
                        ),
                        const SizedBox(height: 5),
                        AnimatedWorkoutCard(
                          title: "Strength",
                          imagePath: "assets/images/strength.jpg",
                          onTap: () {
                            Navigator.pushNamed(context, '/addWorkout', arguments: "Strength");
                          },
                        ),
                        const SizedBox(height: 5),
                        AnimatedWorkoutCard(
                          title: "Yoga",
                          imagePath: "assets/images/yoga.jpg",
                          onTap: () {
                            Navigator.pushNamed(context, '/addWorkout', arguments: "Yoga");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget buildButton(String text, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lime,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.black),
              SizedBox(height: 8),
              Text(text, style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  Widget workoutCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/addWorkout', arguments: title);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120, // makes it rectangular
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}