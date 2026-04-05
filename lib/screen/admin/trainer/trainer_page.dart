import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {

  final supabase = Supabase.instance.client;

  List trainers = [];
  List workoutTypes = [];

  @override
  void initState() {
    super.initState();
    fetchTrainers();
    fetchWorkoutTypes();
  }

  // ================= FETCH TRAINERS =================
  Future<void> fetchTrainers() async {
    final data = await supabase.from('trainers').select();

    setState(() {
      trainers = data;
    });
  }

  // ================= FETCH WORKOUT TYPES =================
  Future<void> fetchWorkoutTypes() async {
    final data = await supabase.from('workouts').select();

    setState(() {
      workoutTypes = data;
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
              'Trainers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: trainers.isEmpty
                  ? const Center(
                child: Text(
                  "No trainers",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: trainers.length,
                itemBuilder: (context, index) {
                  final trainer = trainers[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trainer['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                trainer['type'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editTrainer(index),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTrainer(index),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _addTrainer,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= ADD =================
  void _addTrainer() {
    TextEditingController nameController = TextEditingController();

    String selectedType = workoutTypes.isNotEmpty
        ? workoutTypes[0]['name']
        : '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Trainer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Trainer name'),
              ),

              const SizedBox(height: 10),

              DropdownButton<String>(
                value: selectedType.isEmpty ? null : selectedType,
                isExpanded: true,
                items: workoutTypes.map<DropdownMenuItem<String>>((workout) {
                  return DropdownMenuItem(
                    value: workout['name'],
                    child: Text(workout['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || selectedType.isEmpty) return;

                await supabase.from('trainers').insert({
                  'name': nameController.text.trim(),
                  'type': selectedType,
                });

                Navigator.pop(context);
                fetchTrainers();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ================= EDIT =================
  void _editTrainer(int index) {
    TextEditingController controller =
    TextEditingController(text: trainers[index]['name']);

    String selectedType = trainers[index]['type'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Trainer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller),

              const SizedBox(height: 10),

              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: workoutTypes.map<DropdownMenuItem<String>>((workout) {
                  return DropdownMenuItem(
                    value: workout['name'],
                    child: Text(workout['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await supabase
                      .from('trainers')
                      .update({
                    'name': controller.text.trim(),
                    'type': selectedType,
                  })
                      .eq('id', trainers[index]['id']);

                  Navigator.pop(context);
                  fetchTrainers();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ================= DELETE =================
  void _deleteTrainer(int index) async {
    await supabase
        .from('trainers')
        .delete()
        .eq('id', trainers[index]['id']);

    fetchTrainers();
  }
}