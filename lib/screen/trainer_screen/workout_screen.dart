import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  final String userName;

  const WorkoutScreen({super.key, required this.userName});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  final titleController = TextEditingController();
  final descController = TextEditingController();

  // 🔥 USER-SPECIFIC DATABASE
  Map<String, List<Map<String, String>>> userPlans = {
    "John Doe": [
      {"title": "Cardio Plan", "desc": "30 mins running"},
    ],
  };

  List<Map<String, String>> get plans =>
      userPlans[widget.userName] ?? [];

  // =========================
  // CREATE PLAN
  // =========================
  void createPlan() {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      show("Fill all fields");
      return;
    }

    setState(() {
      userPlans.putIfAbsent(widget.userName, () => []);
      userPlans[widget.userName]!.add({
        "title": titleController.text,
        "desc": descController.text,
      });
    });

    titleController.clear();
    descController.clear();

    show("Plan created");
  }

  // =========================
  // DELETE PLAN (FIXED)
  // =========================
  void deletePlan(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Plan"),
        content: Text("Delete this plan?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                userPlans[widget.userName]!.removeAt(index);
              });
              Navigator.pop(context);
              show("Plan deleted");
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // =========================
  // EDIT PLAN (FIXED)
  // =========================
  void editPlan(int index) {
    final editTitle = TextEditingController(
        text: plans[index]["title"]);
    final editDesc = TextEditingController(
        text: plans[index]["desc"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Plan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editTitle,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: editDesc,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (editTitle.text.isEmpty || editDesc.text.isEmpty) {
                show("Fill all fields");
                return;
              }

              setState(() {
                userPlans[widget.userName]![index] = {
                  "title": editTitle.text,
                  "desc": editDesc.text,
                };
              });

              Navigator.pop(context);
              show("Plan updated");
            },
            child: const Text("Save",
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
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
        title: Text("${widget.userName} Plans"),
        backgroundColor: Colors.black,
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

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue),
              onPressed: createPlan,
              child: const Text("Create Plan"),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${widget.userName} Plan History",
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            if (plans.isEmpty)
              const Text("No plans yet",
                  style: TextStyle(color: Colors.grey)),

            ...plans.asMap().entries.map((entry) {
              int index = entry.key;
              var p = entry.value;

              return Card(
                color: Colors.grey[900],
                child: ListTile(
                  title: Text(p["title"]!,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(p["desc"]!,
                      style: const TextStyle(color: Colors.grey)),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                        const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editPlan(index),
                      ),
                      IconButton(
                        icon:
                        const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletePlan(index),
                      ),
                    ],
                  ),
                ),
              );
            })
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