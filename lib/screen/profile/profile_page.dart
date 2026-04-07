import 'package:flutter/material.dart';
import '/services/db_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lockinapp/screen/profile/edit_profile.dart';

const bgColor = Colors.black;
const cardColor = Color(0xFF2C2C2C);
const inputColor = Color(0xFF3A3A3A);
const textGrey = Colors.grey;
const neonGreen = Color(0xFFD4E157);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  String name = "User";
  String email = "";
  int totalWorkouts = 0;
  int totalCalories = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      email = user.email ?? "";

      // OPTIONAL: fetch name from profiles table
      final data = await Supabase.instance.client
          .from('profiles')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      name = data?['name'] ?? "User";
    }

    final stats = await DBHelper().getStats();

    setState(() {
      totalWorkouts = stats['workouts']!;
      totalCalories = stats['calories']!;
      isLoading = false;
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
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileCard(),
                  const SizedBox(height: 20),
                  _statsCard(),
                  const SizedBox(height: 20),
                  _menuCard(),
                ],
              ),
            ),
    );
  }

  // ================= PROFILE =================
  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: neonGreen,
            child: Text(
              name.isNotEmpty ? name[0] : "U",
              style: const TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(email, style: const TextStyle(color: textGrey)),
            ],
          )
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Stats",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _statBox(
                    Icons.fitness_center, "$totalWorkouts", "Total Workouts",
                    Colors.green),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statBox(Icons.local_fire_department,
                    "$totalCalories", "Calories Burned", Colors.red),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _statBox(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  // ================= MENU =================
  Widget _menuCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _menuItem(Icons.edit, "Edit Profile", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ).then((_) {
              loadProfile(); // 🔥 auto refresh after returning
            });
          }),
          _menuItem(Icons.flag, "Set Fitness Goal", () {}),
          _menuItem(Icons.notifications, "Notification Settings", () {}),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: textGrey, size: 16),
      onTap: onTap,
    );
  }


}