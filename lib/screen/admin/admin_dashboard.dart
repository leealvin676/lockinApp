import "package:flutter/material.dart";
import 'package:lockinapp/screen/admin/workout/workout_page.dart';
import 'package:lockinapp/screen/admin/trainer/trainer_page.dart';
import 'package:lockinapp/screen/admin/user/users_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashBoard extends StatefulWidget {
  const AdminDashBoard({super.key});

  @override
  State<AdminDashBoard> createState() => _AdminDashBoardState();
}

class _AdminDashBoardState extends State<AdminDashBoard> {
  int _currentIndex = 0;

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

  // 🔥 用 get（避免卡住）
  List<Widget> get _pages => [
    _mainBody(),
    WorkoutPage(),
    TrainerPage(),
    UserPage(),
  ];

  // ================= APP BAR =================
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
          onPressed: () {},
          icon: const Icon(Icons.logout, color: Colors.red),
        ),
      ],
    );
  }

  // ================= MAIN DASHBOARD =================
  Widget _mainBody() {
    return FutureBuilder(
      future: Future.wait([
        Supabase.instance.client.from('profiles').select(),
        Supabase.instance.client.from('workouts').select(),
        Supabase.instance.client.from('trainers').select(),
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
        }

        return Padding(
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

              // ================= USERS =================
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

              // ================= WORKOUT =================
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

              // ================= TRAINERS =================
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
            ],
          ),
        );
      },
    );
  }

  // ================= BOTTOM NAV =================
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
      ],
    );
  }
}