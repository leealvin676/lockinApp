import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Box workoutBox;

  @override
  void initState() {
    super.initState();
    workoutBox = Hive.box('workouts');
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool isNumber = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.limeAccent),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index, Map workout) {
    String selectedType = workout['type'];

    TextEditingController durationController =
    TextEditingController(text: workout['duration']);
    TextEditingController setsController =
    TextEditingController(text: workout['sets']);
    TextEditingController repsController =
    TextEditingController(text: workout['reps']);
    TextEditingController notesController =
    TextEditingController(text: workout['notes']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                "Edit Workout",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [

                    // TYPE DROPDOWN
                    DropdownButton<String>(
                      value: selectedType,
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.limeAccent),
                      items: const [
                        DropdownMenuItem(value: "Cardio", child: Text("Cardio")),
                        DropdownMenuItem(value: "Strength", child: Text("Strength")),
                        DropdownMenuItem(value: "Yoga", child: Text("Yoga")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    //CONDITIONAL FIELDS

                    if (selectedType == "Strength") ...[
                      _buildTextField(setsController, "Sets", isNumber: true),
                      _buildTextField(repsController, "Reps", isNumber: true),
                    ] else ...[
                      _buildTextField(durationController, "Duration (min)", isNumber: true),
                    ],

                    _buildTextField(notesController, "Notes"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final updatedWorkout = {
                      'type': selectedType,
                      'duration': (selectedType == "Strength")
                          ? ""
                          : durationController.text,
                      'sets': (selectedType == "Strength")
                          ? setsController.text
                          : "",
                      'reps': (selectedType == "Strength")
                          ? repsController.text
                          : "",
                      'notes': notesController.text,
                    };

                    workoutBox.putAt(index, updatedWorkout);

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Workout History"),
        backgroundColor: Colors.black,
      ),
      body: ValueListenableBuilder(
        valueListenable: workoutBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No workouts yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final workout = box.getAt(index);

              return Dismissible(
                key: Key(index.toString()),
                direction: DismissDirection.endToStart,

                //CONFIRM BEFORE DELETE
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text(
                        "Delete Workout",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        "Are you sure you want to delete this workout?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },

                // Only runs if user presses "Delete"
                onDismissed: (direction) {
                  workoutBox.deleteAt(index);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Workout deleted")),
                  );
                },

                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              workout['type'],
                              style: const TextStyle(
                                color: Colors.limeAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              _showEditDialog(context, index, workout);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      if (workout['duration'] != "")
                        Text("Duration: ${workout['duration']} min",
                            style: const TextStyle(color: Colors.white)),

                      if (workout['sets'] != "")
                        Text("Sets: ${workout['sets']}",
                            style: const TextStyle(color: Colors.white)),

                      if (workout['reps'] != "")
                        Text("Reps: ${workout['reps']}",
                            style: const TextStyle(color: Colors.white)),

                      if (workout['notes'] != "")
                        Text("Notes: ${workout['notes']}",
                            style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}