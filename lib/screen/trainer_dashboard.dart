import 'package:flutter/material.dart';
import 'workout_screen.dart';
import 'recommendation_screen.dart';
import 'trainer_profile_page.dart';
import 'user_form.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  List<Map<String, dynamic>> users = [
    {"name": "John Doe", "goal": "Weight Loss", "progress": 55, "active": true},
    {"name": "Sarah Lee", "goal": "Muscle Gain", "progress": 12, "active": false},
    {"name": "Maria Garcia", "goal": "Strength Training", "progress": 82, "active": true},
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((u) {
      return u["name"].toLowerCase().contains(searchQuery.toLowerCase()) ||
          u["goal"].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        // 🔥 LOGOUT
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: confirmLogout,
        ),

        title: const Text("Trainer Dashboard"),

        // 🔥 PROFILE NAVIGATION
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TrainerProfilePage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  SizedBox(width: 5),
                  Text("Alex Trainer"),
                ],
              ),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserForm()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Welcome back, Trainer 👋",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Text(
              "Manage your clients and plans efficiently",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 15),

            // 🔍 SEARCH
            TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search users...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text("Users",
                style: TextStyle(color: Colors.white, fontSize: 18)),

            const SizedBox(height: 10),

            Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                  child: Text("No users found",
                      style: TextStyle(color: Colors.grey)))
                  : ListView(
                children:
                filteredUsers.map((u) => userCard(u)).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget userCard(Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user["name"],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Icon(Icons.circle,
                            size: 10,
                            color: user["active"]
                                ? Colors.blue
                                : Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          user["active"] ? "Active" : "Inactive",
                          style: const TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                    Text(user["goal"],
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: user["progress"] / 100,
                      color: Colors.blue,
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                  Text("${user["progress"]}%",
                      style: const TextStyle(color: Colors.white)),
                ],
              )
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: blueButton("Workout Plan", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WorkoutScreen()),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: outlineButton(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RecommendationScreen()),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(child: deleteButton(user)),
            ],
          )
        ],
      ),
    );
  }

  Widget blueButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }

  Widget outlineButton(VoidCallback onTap) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.blue),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onTap,
      child: const Text("Recommendation",
          style: TextStyle(color: Colors.white)),
    );
  }

  Widget deleteButton(Map user) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () => confirmDelete(user),
      child: const Text("Delete"),
    );
  }

  void confirmDelete(Map user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Delete ${user["name"]}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                users.remove(user);
              });
              Navigator.pop(context);
            },
            child:
            const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child:
            const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}