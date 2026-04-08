import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  String? selectedUser;

  // 🔥 SIMULATED DATABASE
  List<Map<String, String>> plans = [
    {
      "title": "Cardio Plan",
      "desc": "30 mins running",
      "user": "John Doe"
    },
    {
      "title": "Strength Plan",
      "desc": "Upper body workout",
      "user": "Sarah Lee"
    }
  ];

  final users = ["John Doe", "Sarah Lee"];

  void createPlan() {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty ||
        selectedUser == null) {
      show("Fill all fields");
      return;
    }

    setState(() {
      plans.add({
        "title": titleController.text,
        "desc": descController.text,
        "user": selectedUser!,
      });
    });

    titleController.clear();
    descController.clear();

    show("Plan created");
  }

  void retrievePlans() {
    show("Plans retrieved (local DB simulation)");
    setState(() {}); // refresh UI
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
        title: const Text("Workout Plans"),
        backgroundColor: Colors.black,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: retrievePlans,
        child: const Icon(Icons.refresh),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: input("Plan Title"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: input("Description"),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField(
              dropdownColor: Colors.black,
              hint: const Text("Assign User"),
              items: users.map((u) {
                return DropdownMenuItem(value: u, child: Text(u));
              }).toList(),
              onChanged: (val) => selectedUser = val,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue),
              onPressed: createPlan,
              child: const Text("Create Plan"),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Plan History",
                  style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 10),

            ...plans.map((p) => Card(
              color: Colors.grey[900],
              child: ListTile(
                title: Text(p["title"]!,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  "${p["desc"]}\nUser: ${p["user"]}",
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      plans.remove(p);
                    });
                    show("Plan deleted");
                  },
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  InputDecoration input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[900],
    );
  }
}