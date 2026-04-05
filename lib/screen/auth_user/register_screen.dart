import 'package:flutter/material.dart';
import 'package:lockinapp/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void register() async {
    final auth = AuthService();

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    bool success = await auth.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text); //save name

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created! Please login")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User already exists")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900], // grey box
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView(
              shrinkWrap: true, // important so it fits inside box
              children: [

                Container(
                  width: 60,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.lime,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.black,
                    size: 35,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Create Account",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Start your fitness transformation today",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Icon(Icons.person, color: Colors.grey, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Full Name",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),


                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Sam Sulek",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Icon(Icons.email, color: Colors.grey, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Email",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),


                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "SamSulek@example.com",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Icon(Icons.lock, color: Colors.grey, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Password",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),


                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "********",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Icon(Icons.lock, color: Colors.grey, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Confirm Password",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),


                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "********",
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lime,
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}