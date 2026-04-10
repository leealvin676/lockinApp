import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final goalController = TextEditingController();

  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email);
  }

  void saveUser() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        goalController.text.isEmpty) {
      show("All fields required");
      return;
    }

    if (!isValidEmail(emailController.text)) {
      show("Email must be ___@gmail.com");
      return;
    }

    show("User saved (local)");

    Navigator.pop(context);
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
        title: const Text("User Form"),
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            field("Name", nameController),
            field("Email", emailController),
            field("Goal", goalController),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: saveUser,
              child: const Text("Save"),
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
          filled: true,
          fillColor: Colors.grey[900],
        ),
      ),
    );
  }
}