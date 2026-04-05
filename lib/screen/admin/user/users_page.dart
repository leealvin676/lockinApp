import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  final supabase = Supabase.instance.client;

  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // ================= FETCH USERS =================
  Future<void> fetchUsers() async {
    final data = await supabase.from('profiles').select();

    setState(() {
      users = data;
    });
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
              child: users.isEmpty
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

                        // 🗑 Delete only
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

  // ================= DELETE =================
  void _deleteUser(int index) async {
    await supabase
        .from('profiles')
        .delete()
        .eq('id', users[index]['id']);

    fetchUsers();
  }
}