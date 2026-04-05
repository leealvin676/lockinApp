import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lockinapp/widgets/animated_workout_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:lockinapp/services/db_helper.dart'; // ✅ 新增

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "";

  int todayMinutes = 0;
  int streak = 0;
  int caloriesBurned = 0;
  int dailyGoal = 0;

  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final bodyFatController = TextEditingController();
  final goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
    loadStats();
    loadBodyData();
    loadGoal();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadBodyData();
    loadStats();
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    bodyFatController.dispose();
    goalController.dispose();
    super.dispose();
  }

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      userName = prefs.getString('name') ?? "User";
    });
  }

  // ✅ BODY DATA（改为 SharedPreferences）
  void saveBodyData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('height', heightController.text);
    await prefs.setString('weight', weightController.text);
    await prefs.setString('bodyFat', bodyFatController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data saved!")),
    );
  }

  void loadBodyData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      heightController.text = prefs.getString('height') ?? "";
      weightController.text = prefs.getString('weight') ?? "";
      bodyFatController.text = prefs.getString('bodyFat') ?? "";
    });
  }

  // ✅ STATS（改为 SQLite）
  void loadStats() async {
    final workouts = await DBHelper().getWorkouts();

    int totalToday = 0;
    Set<String> workoutDays = {};

    final now = DateTime.now();

    for (var workout in workouts) {
      if (workout['date'] == null) continue;

      final date = DateTime.tryParse(workout['date']) ?? DateTime.now();
      final duration = workout['duration'] ?? 0;

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        totalToday += duration as int;
      }

      workoutDays.add("${date.year}-${date.month}-${date.day}");
    }

    int currentStreak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    while (true) {
      String key = "${checkDate.year}-${checkDate.month}-${checkDate.day}";

      if (workoutDays.contains(key)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    int calories = totalToday * 5;

    if (!mounted) return;

    setState(() {
      todayMinutes = totalToday;
      streak = currentStreak;
      caloriesBurned = calories;
    });
  }

  // ✅ GOAL（改为 SharedPreferences）
  void loadGoal() async {
    final prefs = await SharedPreferences.getInstance();

    dailyGoal = prefs.getInt('dailyGoal') ?? 0;
    goalController.text = dailyGoal == 0 ? "" : dailyGoal.toString();

    if (!mounted) return;
    setState(() {});
  }

  void saveGoal() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'dailyGoal',
      int.tryParse(goalController.text) ?? 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Goal saved!")),
    );

    loadGoal();
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
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('currentUser');
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Welcome, $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Let's crush your fitness goals today",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Body Data",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Height (cm)",
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: weightController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Weight (kg)",
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Expanded(
                          child: TextField(
                            controller: bodyFatController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: "Body Fat %",
                              labelStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    const Text("Advice: Measure once 3 months for better results",
                        style: TextStyle(color: Colors.grey)),

                    const SizedBox(height: 5),

                    ElevatedButton(
                      onPressed: saveBodyData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lime,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DAILY SUMMARY
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
                    const Text(
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
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(child: streakCard()),
                        const SizedBox(width: 8),
                        Expanded(child: minutesCard()),
                        const SizedBox(width: 8),
                        Expanded(child: caloriesCard()),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              //TODAY'S GOAL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Today's Goal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextField(
                      controller: goalController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Enter calories goal",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 5),

                    ElevatedButton(
                      onPressed: saveGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lime,
                      ),
                      child: const Text(
                        "Set Goal",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Progress Bar
                    dailyGoal > 0
                        ? Column(
                      children: [
                        LinearProgressIndicator(
                          value: (caloriesBurned / dailyGoal).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            caloriesBurned >= dailyGoal
                                ? Colors.green
                                : Colors.limeAccent,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "$caloriesBurned / $dailyGoal kcal",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    )
                        : const SizedBox(),

                    const SizedBox(height: 5),

                    Text(
                      dailyGoal == 0
                          ? "Set your goal for today"
                          : caloriesBurned >= dailyGoal
                          ? "Congratulations! You have hit your today's goal"
                          : "Keep grinding! You're almost there.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: caloriesBurned >= dailyGoal
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  buildButton("Start Workout", Icons.play_arrow, () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/workoutSession',
                      arguments: "General",
                    );

                    if (result == true) {
                      loadStats();
                    }
                  }),
                  buildButton("History", Icons.history, () async {
                    await Navigator.pushNamed(context, '/history');
                    loadStats();
                  }),
                ],
              ),

              const SizedBox(height: 20),

              // WORKOUT TYPES
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Workout Types",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),

                    AnimatedWorkoutCard(
                      title: "Cardio",
                      imagePath: "assets/images/cardio.jpg",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/workoutSession',
                          arguments: "Cardio",
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    AnimatedWorkoutCard(
                      title: "Strength",
                      imagePath: "assets/images/strength.jpg",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/workoutSession',
                          arguments: "Strength",
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    AnimatedWorkoutCard(
                      title: "Yoga",
                      imagePath: "assets/images/yoga.jpg",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/workoutSession',
                          arguments: "Yoga",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget streakCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.whatshot,
            color: Colors.orange,
            size: 30.0,
          ),
          const Text(
            "Streak",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            "$streak days",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget minutesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: Colors.lightBlueAccent,
            size: 30.0,
          ),
          const Text(
            "Minutes",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            "$todayMinutes min",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget caloriesCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purpleAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.bolt_outlined,
            color: Colors.purpleAccent,
            size: 30.0,
          ),
          const Text(
            "Calories",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            "$caloriesBurned kcal",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String text, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lime,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(height: 8),
              Text(text, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
  }
