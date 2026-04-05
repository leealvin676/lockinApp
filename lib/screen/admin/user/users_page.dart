import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // ✅ 正确：等 UI build 完才 fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUsers();
    });
  }

  // ================= FETCH USERS =================
  Future<void> fetchUsers() async {
    try {
      final data = await supabase.from('profiles').select();

      if (!mounted) return;

      setState(() {
        users = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });

    } catch (e) {
      print("Fetch error: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load users")),
      );
    }
  }

  // ================= DELETE =================
  Future<void> _deleteUser(int index) async {
    final id = users[index]['id'];

    try {
      await supabase
          .from('profiles')
          .delete()
          .eq('id', id);

      if (!mounted) return;

      setState(() {
        users.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted")),
      );

    } catch (e) {
      print("Delete error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : users.isEmpty
                  ? const Center(
                child: Text(
                  "No users",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {

                  final user = users[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF444444),
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(
                      children: [

                        const Icon(Icons.person, color: Colors.red),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            user['name'] ?? 'No Name',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}