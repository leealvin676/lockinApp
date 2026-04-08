import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bgColor = Colors.black;
const cardColor = Color(0xFF2C2C2C);
const inputColor = Color(0xFF3A3A3A);
const textGrey = Colors.grey;
const neonGreen = Color(0xFFD4E157);

class SetGoalPage extends StatefulWidget {
  const SetGoalPage({super.key});

  @override
  State<SetGoalPage> createState() => _SetGoalPageState();
}

class _SetGoalPageState extends State<SetGoalPage> {

  String selectedGoal = "";
  bool isLoading = true;

  final goals = [
    "Lose Weight",
    "Build Muscle",
    "Stay Fit",
    "Improve Endurance",
  ];

  @override
  void initState() {
    super.initState();
    loadGoal();
  }

  Future<void> loadGoal() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await Supabase.instance.client
        .from('profiles')
        .select('goal')
        .eq('id', user.id)
        .maybeSingle();

    selectedGoal = data?['goal'] ?? "";

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveGoal() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await Supabase.instance.client.from('profiles').upsert({
      'id': user.id,
      'goal': selectedGoal,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Set Fitness Goal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...goals.map((g) => _goalItem(g)).toList(),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: selectedGoal.isEmpty ? null : saveGoal,
                child: const Text("Save Goal"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _goalItem(String goal) {
    final isSelected = selectedGoal == goal;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? inputColor : cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? neonGreen : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flag,
              color: isSelected ? neonGreen : Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              goal,
              style: TextStyle(
                color: isSelected ? neonGreen : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}