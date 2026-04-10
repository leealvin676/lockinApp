import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<Map<String, dynamic>> workouts = [];

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  void loadWorkouts() async {
    final data = await DBHelper().getWorkouts();
    setState(() {
      workouts = data;
    });
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
        inputFormatters:
        isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
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

  void _showEditDialog(BuildContext context, Map workout) {
    String selectedType = workout['type'];

    TextEditingController durationController =
    TextEditingController(text: workout['duration']?.toString() ?? "");
    TextEditingController setsController =
    TextEditingController(text: workout['sets']?.toString() ?? "");
    TextEditingController repsController =
    TextEditingController(text: workout['reps']?.toString() ?? "");
    TextEditingController notesController =
    TextEditingController(text: workout['notes'] ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                "Edit Workout",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
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
                        setStateDialog(() {
                          selectedType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

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
                  onPressed: () async {
                    final updatedWorkout = {
                      'type': selectedType,
                      'duration': selectedType == "Strength"
                          ? null
                          : int.tryParse(durationController.text) ?? 0,
                      'sets': selectedType == "Strength"
                          ? int.tryParse(setsController.text) ?? 0
                          : null,
                      'reps': selectedType == "Strength"
                          ? int.tryParse(repsController.text) ?? 0
                          : null,
                      'notes': notesController.text,
                      'date': workout['date'],
                    };

                    await DBHelper().updateWorkout(
                      workout['id'],
                      updatedWorkout,
                    );

                    loadWorkouts();

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

      body: workouts.isEmpty
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

          String formattedDate = "Unknown date";

          if (workout['date'] != null) {
            final parsedDate = DateTime.tryParse(workout['date']);
            if (parsedDate != null) {
              formattedDate =
              "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
            }
          }

          return Dismissible(
            key: Key(workout['id'].toString()),

            direction: DismissDirection.endToStart,

            onDismissed: (direction) async {
              await DBHelper().deleteWorkout(workout['id']);

              loadWorkouts();

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
                          workout['type'] ?? "",
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
                          _showEditDialog(context, workout);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 5),

                  if (workout['duration'] != null)
                    Text("Duration: ${workout['duration']} min",
                        style: const TextStyle(color: Colors.white)),

                  if (workout['sets'] != null)
                    Text("Sets: ${workout['sets']}",
                        style: const TextStyle(color: Colors.white)),

                  if (workout['reps'] != null)
                    Text("Reps: ${workout['reps']}",
                        style: const TextStyle(color: Colors.white)),

                  if (workout['notes'] != null &&
                      workout['notes'] != "")
                    Text("Notes: ${workout['notes']}",
                        style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}