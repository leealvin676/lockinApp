import "package:flutter/material.dart";
import 'package:lockinapp/screen/admin/workout/workout_page.dart';
import 'package:lockinapp/screen/admin/trainer/trainer_page.dart';
import 'package:lockinapp/screen/admin/user/users_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lockinapp/screen/admin/trainer/booking_page.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashBoard extends StatefulWidget {
  const AdminDashBoard({super.key});

  @override
  State<AdminDashBoard> createState() => _AdminDashBoardState();
}

class _AdminDashBoardState extends State<AdminDashBoard> {
  int _currentIndex = 0;
  int totalBookings = 0;
  Map<String, int> workoutStats = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: _bottom(_currentIndex, (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
    );
  }


  List<Widget> get _pages => [
    _mainBody(),
    WorkoutPage(),
    TrainerPage(),
    UserPage(),
    AdminBookingPage(),
  ];


  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF333333),
      title: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'LockIn',
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'Admin',
              style:
              TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        )
      ],
    );
  }


  Widget _mainBody() {
    return FutureBuilder(
      future: Future.wait([
        Supabase.instance.client.from('profiles').select(),
        Supabase.instance.client.from('workouts').select(),
        Supabase.instance.client.from('trainers').select(),
        Supabase.instance.client.from('bookings').select(),
      ]),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        int totalUsers = 0;
        int totalWorkouts = 0;
        int totalTrainers = 0;

        if (snapshot.hasData) {
          final data = snapshot.data as List;

          totalUsers = (data[0] as List).length;
          totalWorkouts = (data[1] as List).length;
          totalTrainers = (data[2] as List).length;

          final bookings = data[3] as List;
          totalBookings = bookings.length;

          Map<String, int> tempStats = {};
          for (var b in bookings) {
            final goal = (b['goal'] ?? "unknown").toString();
            tempStats[goal] = (tempStats[goal] ?? 0) + 1;
          }

          workoutStats = tempStats;
        }

        return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Welcome Back',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),


              Container(
                height: 150,
                width: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Users',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '$totalUsers',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),


              Container(
                height: 150,
                width: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Workout Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '$totalWorkouts',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),


              Container(
                height: 150,
                width: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trainer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '$totalTrainers',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      'Booking Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Total Bookings: $totalBookings',
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 10),

                    buildChart(),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget buildChart() {
    if (workoutStats.isEmpty) {
      return const Text(
        "No data",
        style: TextStyle(color: Colors.white),
      );
    }

    final keys = workoutStats.keys.toList();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= keys.length) return const SizedBox();

                  return Text(
                    keys[index],
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(keys.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: workoutStats[keys[i]]!.toDouble(),
                  width: 14,
                  color: Colors.red,
                )
              ],
            );
          }),
        ),
      ),
    );
  }


  BottomNavigationBar _bottom(int currentIndex, Function(int) onTap) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,

      currentIndex: currentIndex,
      onTap: onTap,

      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'DashBoard'),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_gymnastics),
          label: 'Workout Types',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Trainers'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_online),
          label: 'Bookings',
        ),
      ],
    );
  }
}