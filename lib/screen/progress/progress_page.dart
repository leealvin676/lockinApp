import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/services/db_helper.dart';

const bgColor = Colors.black;
const cardColor = Color(0xFF2C2C2C);
const inputColor = Color(0xFF3A3A3A);
const textGrey = Colors.grey;
const neonGreen = Color(0xFFD4E157);

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {

  List<double> weeklyCalories = List.filled(7, 0);
  List<double> weeklyMinutes = List.filled(7, 0);

  int dailyGoal = 30;
  int totalWorkouts = 0;
  int totalMinutes = 0;
  int totalCalories = 0;
  int streak = 0;
  bool isLoading = true;
  double improvement = 0;
  double avgTime = 0;
  String badge = "";

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  int calculateStreak(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0;


    final uniqueDates = data
        .map((w) => DateTime.tryParse(w['date'] ?? ''))
        .whereType<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList();

    uniqueDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();

    for (int i = 0; i < uniqueDates.length; i++) {
      final expected = DateTime(today.year, today.month, today.day - i);

      if (uniqueDates.any((d) =>
      d.year == expected.year &&
          d.month == expected.month &&
          d.day == expected.day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  double calculateImprovement(List<Map<String, dynamic>> data) {
    final now = DateTime.now();

    int thisWeek = 0;
    int lastWeek = 0;

    for (var w in data) {
      final date = DateTime.tryParse(w['date'] ?? '');
      if (date == null) continue;

      if (date.isAfter(now.subtract(const Duration(days: 7)))) {
        thisWeek += (w['duration'] ?? 0) as int;
      } else if (date.isAfter(now.subtract(const Duration(days: 14)))) {
        lastWeek += (w['duration'] ?? 0) as int;
      }
    }

    if (lastWeek == 0) {
      return thisWeek > 0 ? 999 : 0;

    }
    return ((thisWeek - lastWeek) / lastWeek) * 100;
  }

  double getAverageTime() {
    if (totalWorkouts == 0) return 0;
    return totalMinutes / totalWorkouts;
  }

  String getBadge() {
    if (streak >= 7) return "🔥 Pro";
    if (streak >= 3) return "💪 Active";
    return "🌱 Beginner";
  }

  String getSmartFeedback() {
    if (totalMinutes >= dailyGoal) return "🔥 Goal achieved!";
    if (streak >= 5) return "💪 Strong consistency!";
    if (totalWorkouts == 0) return "Start today 🚀";
    return "Keep going!";
  }


  String getMotivation() {
    if (streak >= 7) return "🔥 On fire! Keep it up!";
    if (streak >= 3) return "💪 Good consistency!";
    if (streak >= 1) return "👍 Nice start!";
    return "🚀 Let's begin today!";
  }

  Future<void> loadProgress() async {
    final data = await DBHelper().getWorkouts();
    totalWorkouts = data.length;

    int minutes = 0;
    int calories = 0;
    improvement = calculateImprovement(data);
    avgTime = getAverageTime();
    badge = getBadge();

    List<double> tempCalories = List.filled(7, 0);
    List<double> tempMinutes = List.filled(7, 0);

    final now = DateTime.now();

    List<Map<String, dynamic>> filtered = data.where((w) {
      final date = DateTime.tryParse(w['date'] ?? '');
      if (date == null) return false;

      if (selected == 0) {

        return date.isAfter(now.subtract(const Duration(days: 7)));
      } else {

        return date.isAfter(DateTime(now.year, now.month - 1, now.day));
      }
    }).toList();

    for (var w in filtered) {
      final duration = (w['duration'] as int? ?? 0);
      final date = DateTime.tryParse(w['date'] ?? '');

      minutes += duration;
      calories += duration * 5;

      if (date != null) {
        final today = DateTime.now();
        final difference = today.difference(date).inDays;

        if (selected == 0) {

          if (difference >= 0 && difference < 7) {
            int index = 6 - difference;
            tempMinutes[index] += duration;
            tempCalories[index] += duration * 5;
          }
        } else {

          if (difference >= 0 && difference < 30) {
            int index = (difference ~/ 4); // group into 7 bars
            if (index > 6) index = 6;

            tempMinutes[index] += duration;
            tempCalories[index] += duration * 5;
          }
        }

      }
    }

    setState(() {
      totalMinutes = minutes;
      totalCalories = calories;
      streak = calculateStreak(data);

      weeklyCalories = tempCalories;
      weeklyMinutes = tempMinutes;


      avgTime = getAverageTime();
      badge = getBadge();
      improvement = calculateImprovement(data);

      isLoading = false;
    });
  }
  int selected = 0;

  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  double bmi = 0;

  void calculateBMI() {
    double h = double.tryParse(heightController.text) ?? 0;
    double w = double.tryParse(weightController.text) ?? 0;

    if (h == 0 || w == 0) return;

    h = h / 100;

    setState(() {
      bmi = w / (h * h);
    });
  }

  String bmiStatus() {
    if (bmi == 0) return "";
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Progress",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Track your fitness journey",
                style: TextStyle(color: textGrey),
              ),
              const SizedBox(height: 20),

              _summary(),
              const SizedBox(height: 20),

              _goalCard(),

              const SizedBox(height: 20),



              _toggle(),
              const SizedBox(height: 20),

              _lineCard(),
              const SizedBox(height: 20),

              _barCard(),
              const SizedBox(height: 20),

              _bmiCard(),
              const SizedBox(height: 20),

              _streakCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summary() {
    return Column(
      children: [

        Row(
          children: [
            Expanded(child: _card(Icons.local_fire_department, "$totalCalories", "Week\nCalories", Colors.orange)),
            const SizedBox(width: 10),
            Expanded(child: _card(Icons.timer, "$totalMinutes", "Week\nMinutes", Colors.blue)),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(child: _card(Icons.bolt, "$streak", "Day\nStreak", Colors.purple)),
            const SizedBox(width: 10),
            Expanded(child: _card(Icons.fitness_center, "$totalWorkouts", "Total\nWorkouts", Colors.green)),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Level: $badge",
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 5),

              Text(
                "Avg Workout: ${avgTime.toStringAsFixed(1)} min",
                style: const TextStyle(color: textGrey),
              ),

              const SizedBox(height: 5),

              Text(
                improvement == 999
                    ? "New progress 🚀"
                    : "Progress: ${improvement.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: improvement >= 0 ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                getSmartFeedback(),
                style: const TextStyle(color: textGrey),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _goalCard() {
    double progress = totalMinutes / dailyGoal;
    if (progress > 1) progress = 1;

    return _cardContainer(
      title: "Daily Goal",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "$totalMinutes / $dailyGoal min",
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey,
            color: Colors.blue,
          ),

          const SizedBox(height: 10),

          Text(
            progress == 1
                ? "🔥 Goal completed!"
                : "Keep going 💪",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String value, String label, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _toggle() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _toggleBtn("Weekly", 0),
          _toggleBtn("Monthly", 1),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, int index) {
    return Expanded(
      child: GestureDetector(onTap: () async {
        setState(() {
          selected = index;
          isLoading = true;
        });

        await loadProgress();
      },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected == index ? inputColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  color: selected == index ? Colors.white : textGrey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lineCard() {
    return _cardContainer(
      title: "Weekly Calories Burned",
      child: SizedBox(height: 200, child: _lineChart()),
    );
  }

  Widget _lineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            spots: List.generate(7, (index) {
              return FlSpot(index.toDouble(), weeklyCalories[index]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _barCard() {
    return _cardContainer(
      title: "Weekly Duration",
      child: SizedBox(height: 200, child: _barChart()),
    );
  }

  Widget _barChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyMinutes[index],
                color: Colors.orange,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _bmiCard() {
    return _cardContainer(
      title: "BMI Calculator",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Calculate your Body Mass Index",
            style: TextStyle(color: textGrey),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _input(heightController, "Height (cm)")),
              const SizedBox(width: 10),
              Expanded(child: _input(weightController, "Weight (kg)")),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: neonGreen,
                foregroundColor: Colors.black,
              ),
              onPressed: calculateBMI,
              child: const Text("Calculate BMI"),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "BMI: ${bmi.toStringAsFixed(2)} (${bmiStatus()})",
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textGrey),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _streakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            "Streak Tracker",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "Keep the momentum going!",
            style: TextStyle(color: textGrey),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 60),
          const SizedBox(height: 10),
          Text(
            "$streak Days",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          Text(
            getMotivation(),
            style: const TextStyle(color: textGrey),
          ),
        ],
      ),
    );
  }

  Widget _cardContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}