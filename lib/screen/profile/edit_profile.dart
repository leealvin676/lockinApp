import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const bgColor = Colors.black;
const cardColor = Color(0xFF2C2C2C);
const inputColor = Color(0xFF3A3A3A);
const textGrey = Colors.grey;
const neonGreen = Color(0xFFD4E157);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    emailController.text = email;

    if (user == null) return;

    email = user.email ?? "";

    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      nameController.text = data['name'] ?? "";
      ageController.text = (data['age'] ?? "").toString();
      heightController.text = (data['height'] ?? "").toString();
      weightController.text = (data['weight'] ?? "").toString();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveProfile() async {
    setState(() {
      isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await Supabase.instance.client.from('profiles').upsert({
      'id': user.id,
      'name': nameController.text,
      'age': int.tryParse(ageController.text) ?? 0,
      'height': int.tryParse(heightController.text) ?? 0,
      'weight': int.tryParse(weightController.text) ?? 0,
    });

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [

              _input(nameController, "Full Name"),
              const SizedBox(height: 10),

              _emailField(),
              const SizedBox(height: 10),

              _input(ageController, "Age (years)"),
              const SizedBox(height: 10),

              _input(heightController, "Height (cm)"),
              const SizedBox(height: 10),

              _input(weightController, "Weight (kg)"),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: saveProfile,
                  child: const Text("Save Changes"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: textGrey),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextField(
      enabled: false,
      controller: emailController,
      style: const TextStyle(color: textGrey),
      decoration: InputDecoration(
        hintText: "Email",
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    emailController.dispose();
    super.dispose();
  }
}