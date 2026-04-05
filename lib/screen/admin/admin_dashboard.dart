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

  List<Widget> get _pages =>
      [
        _mainBody(),
        WorkoutPage(),
        TrainerPage(),
        UserPage(),
      ];

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFF333333),
      title: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'LockIn',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'Admin',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.logout, color: Colors.red),
        ),
      ],
    );
  }

  Widget _mainBody() {
    return FutureBuilder(


      future: Supabase.instance.client.from('profiles').select(),
      builder: (context, snapshot) {
        int totalUsers = 0;

        if (snapshot.hasData) {
          final data = snapshot.data as List;
          totalUsers = data.length;
        }

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Welcome Back', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 30),


              Container(
                height: 150,
                width: 350,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF444444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Users',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '$totalUsers', // 🔥 动态数据
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // 下面两个保持不动（你原本设计）
              Container(
                height: 150,
                width: 350,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF444444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Row(children: [Icon(Icons.people), Text('120')]),
                  ],
                ),
              ),

              SizedBox(height: 30),

              Container(
                height: 150,
                width: 350,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF444444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trainer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Row(children: [Icon(Icons.people), Text('120')]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

      items: [
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
