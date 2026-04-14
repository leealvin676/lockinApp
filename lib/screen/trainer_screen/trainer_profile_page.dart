import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerProfilePage extends StatefulWidget {
  const TrainerProfilePage({super.key});

  @override
  State<TrainerProfilePage> createState() => _TrainerProfilePageState();
}

class _TrainerProfilePageState extends State<TrainerProfilePage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile(); // 🔥 NEW
  }

  // =========================
  // LOAD PROFILE FROM SUPABASE
  // =========================
  Future<void> loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await Supabase.instance.client
        .from('trainers')
        .select()
        .eq('email', user.email ?? "")
        .maybeSingle();

    if (data != null) {
      nameController.text = data['name'] ?? "";
      emailController.text = data['email'] ?? "";
      phoneController.text = data['phone'] ?? "";
    } else {
      // fallback (first time)
      emailController.text = user.email ?? "";
    }

    setState(() {
      isLoading = false;
    });
  }

  // =========================
  // VALIDATION
  // =========================
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email);
  }

  // =========================
  // SAVE TO SUPABASE
  // =========================
  Future<void> saveProfile() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      show("All fields required");
      return;
    }

    if (!isValidEmail(emailController.text)) {
      show("Invalid Gmail format");
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      await Supabase.instance.client.from('trainers').upsert({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      show("Profile saved ✅");
    } catch (e) {
      show("Error saving profile");
      print(e);
    }
  }

  void show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.black,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            GestureDetector(
              onTap: () => show("Upload image clicked"),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Icon(Icons.camera_alt),
              ),
            ),

            const SizedBox(height: 20),

            field("Name", nameController),
            field("Email", emailController),
            field("Phone", phoneController),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: saveProfile,
                child: const Text("Save"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}