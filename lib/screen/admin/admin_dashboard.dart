import "package:flutter/material.dart";

class AdminDashBoard extends StatelessWidget {
  const AdminDashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: _mainBody(),
      bottomNavigationBar: _bottom(),
    );
  }
}

AppBar _buildAppBar() {
  return AppBar(
    backgroundColor: Color(0xFF333333),
    title: const Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'LockIn',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  color: Colors.white
                ),
              ),
              Spacer(),
              
              Row(
                children: [
                  Icon(Icons.people),
                  Text('120')
                ],
              )
            ],
          ),
        ),
      ],
    ),
  );
}

BottomNavigationBar _bottom() {
  return BottomNavigationBar(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.red,
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,

    items: [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'DashBoard'),
      BottomNavigationBarItem(
        icon: Icon(Icons.sports_gymnastics),
        label: 'Workout Types',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Trainers'),
      BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Trainers'),
    ],
  );
}
