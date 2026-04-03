import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const bgColor = Color(0xFF000000);
const cardColor = Color(0xFF1F2937);
const inputColor = Color(0xFF374151);
const textGrey = Color(0xFF9CA3AF);
const neonGreen = Color(0xFFA3E635);

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {

  int selected = 0;

  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  double bmi = 0;
  int streak = 2;

  void calculateBMI() {
    double h = double.tryParse(heightController.text) ?? 0;
    double w = double.tryParse(weightController.text) ?? 0;

    if (h == 0 || w == 0) return;

    h = h / 100;

    setState(() {
      bmi = w / (h * h);
    });
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _card(Icons.local_fire_department, "750", "Week\nCalories", Colors.orange),
        _card(Icons.show_chart, "145", "Week\nMinutes", Colors.blue),
        _card(Icons.calendar_today, "2", "Day\nStreak", Colors.green),
      ],
    );
  }

  Widget _card(IconData icon, String value, String label, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
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
      child: GestureDetector(
        onTap: () {
          setState(() {
            selected = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected == index ? Colors.black : Colors.transparent,
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
            spots: const [
              FlSpot(0, 0),
              FlSpot(1, 0),
              FlSpot(2, 0),
              FlSpot(3, 100),
              FlSpot(4, 150),
              FlSpot(5, 450),
            ],
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
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 30, color: Colors.green)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 45, color: Colors.green)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 60, color: Colors.green)]),
        ],
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: calculateBMI,
              child: const Text("Calculate BMI"),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "BMI: ${bmi.toStringAsFixed(2)}",
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
        ),
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
              color: Colors.orangeAccent, size: 60),

          const SizedBox(height: 10),

          Text(
            "$streak Days",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),

          const Text(
            "You're building a habit!",
            style: TextStyle(color: textGrey),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircleAvatar(radius: 4, backgroundColor: Colors.orange),
              SizedBox(width: 5),
              CircleAvatar(radius: 4, backgroundColor: Colors.orange),
            ],
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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