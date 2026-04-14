import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lockinapp/screen/trainer_screen/workoutplan.dart';

const bgColor = Colors.black;
const cardColor = Color(0xFF1E1E1E);
const primaryBlue = Color(0xFF2196F3);

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  // =========================
  // LOAD USERS FROM SUPABASE
  // =========================
  Future<void> loadUsers() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null || authUser.email == null) return;

      // 🔥 GET TRAINER
      final trainer = await supabase
          .from('trainers')
          .select()
          .eq('email', authUser.email!)
          .maybeSingle();

      if (trainer == null) return;

      // 🔥 GET ACCEPTED BOOKINGS
      final data = await supabase
          .from('bookings')
          .select()
          .eq('trainer_id', trainer['id'])
          .eq('status', 'accepted');

      setState(() {
        users = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });

    } catch (e) {
      print("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text("My Clients"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
            ? const Center(
          child: Text(
            "No clients yet",
            style: TextStyle(color: Colors.grey),
          ),
        )
            : Column(
          children: [

            // USER LIST
            Expanded(
              child: ListView(
                children:
                users.map((u) => userCard(context, u)).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // ADD USER BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Feature coming soon")),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add User",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // USER CARD
  // =========================
  Widget userCard(BuildContext context, Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          // USER INFO
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: primaryBlue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user["user_name"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user["goal"] ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrainerWorkoutPlanPage(
                          userName: user["user_name"],
                        ),
                      ),
                    );
                  },
                  child: const Text("Workout Plan"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryBlue),
                    foregroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/recommendation');
                  },
                  child: const Text("Recommendation"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}