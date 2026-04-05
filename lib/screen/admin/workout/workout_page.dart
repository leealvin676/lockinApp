import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {

  final supabase = Supabase.instance.client;

  List workouts = [];

  @override
  void initState() {
    super.initState();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    final data = await supabase.from('workouts').select();

    setState(() {
      workouts = data;
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
              'WORKOUT TYPE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: workouts.isEmpty
                  ? const Center(
                child: Text(
                  "No workouts yet",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];

                  return Dismissible(
                    key: Key(workout['id'].toString()),
                    direction: DismissDirection.endToStart,

                    onDismissed: (direction) async {
                      await supabase
                          .from('workouts')
                          .delete()
                          .eq('id', workout['id']);

                      fetchWorkouts();
                    },

                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF444444),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.red),
                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              workout['name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _editWorkout(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _addWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= ADD =================
  void _addWorkout() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Workout'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter workout name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                await supabase.from('workouts').insert({
                  'name': controller.text.trim(),
                });

                Navigator.pop(context);
                fetchWorkouts();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ================= EDIT =================
  void _editWorkout(int index) {
    TextEditingController controller =
    TextEditingController(text: workouts[index]['name']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Workout'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await supabase
                      .from('workouts')
                      .update({'name': controller.text.trim()})
                      .eq('id', workouts[index]['id']);

                  Navigator.pop(context);
                  fetchWorkouts();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}