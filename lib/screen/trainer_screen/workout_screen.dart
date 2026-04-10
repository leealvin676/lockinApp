import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/services/db_helper.dart';

class WorkoutScreen extends StatefulWidget {
  final String userName;

  const WorkoutScreen({super.key, required this.userName});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  final titleController = TextEditingController();
  final typeController = TextEditingController();
  String selectedGoal = "";
  List workoutTypes = [];

  List<Map<String, dynamic>> workouts = [];

  String bookingStatus = ""; // 🔥 booking state

  @override
  void initState() {
    super.initState();
    loadWorkouts();
    loadBookingStatus();
    loadWorkoutTypes();// 🔥 important
  }

  // =========================
  // LOAD WORKOUTS (SQLite)
  // =========================
  Future<void> loadWorkouts() async {
    final data = await DBHelper().getWorkouts();

    setState(() {
      workouts = data;
    });
  }

  Future<void> loadWorkoutTypes() async {
    final data = await Supabase.instance.client
        .from('workouts')
        .select();

    setState(() {
      workoutTypes = data;
      if (workoutTypes.isNotEmpty) {
        selectedGoal = workoutTypes[0]['name'];
      }
    });
  }

  // =========================
  // LOAD BOOKING STATUS (Supabase)
  // =========================
  Future<void> loadBookingStatus() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await Supabase.instance.client
        .from('bookings')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data != null) {
      setState(() {
        bookingStatus = data['status'];
      });
    }
  }

  // =========================
  // BOOK TRAINER
  // =========================
  Future<void> bookTrainer() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    await Supabase.instance.client.from('bookings').insert({
      'user_id': user.id,
      'user_name': user.email,
      'goal': "Fitness",
      'status': 'pending',
    });

    await loadBookingStatus(); // 🔥 refresh UI
    show("Booking sent!");
  }

  // =========================
  // CREATE WORKOUT
  // =========================
  Future<void> createWorkout() async {
    if (titleController.text.isEmpty || typeController.text.isEmpty) {
      show("Fill all fields");
      return;
    }

    final now = DateTime.now();

    await DBHelper().insertWorkout({
      "type": typeController.text,
      "duration": 30,
      "sets": 0,
      "reps": 0,
      "notes": titleController.text,
      "date": DateFormat('yyyy-MM-dd').format(now),
    });

    titleController.clear();
    typeController.clear();

    await loadWorkouts();
  }

  // =========================
  // DELETE WORKOUT
  // =========================
  Future<void> deleteWorkout(int id) async {
    await DBHelper().deleteWorkout(id);
    await loadWorkouts();
    show("Deleted");
  }

  void show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // =========================
  // ADD WORKOUT MODAL
  // =========================
  void openAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add New Workout",
                  style:
                  TextStyle(color: Colors.white, fontSize: 18)),

              const SizedBox(height: 15),

              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: input("Workout Name"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: typeController,
                style: const TextStyle(color: Colors.white),
                decoration: input("Type (Cardio / Strength)"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4E157),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    await createWorkout();
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: const Text("Add Workout"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // =========================
  // BOOKING CARD (NEW UI)
  // =========================
  Widget bookingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Trainer Booking",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),


          const Text(
            "Get a professional trainer to guide your workouts",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          // 🔥 DROPDOWN HERE
          DropdownButton<String>(
            value: selectedGoal.isEmpty ? null : selectedGoal,
            isExpanded: true,
            dropdownColor: const Color(0xFF1E1E1E),
            items: workoutTypes.map<DropdownMenuItem<String>>((w) {
              return DropdownMenuItem(
                value: w['name'],
                child: Text(
                  w['name'],
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGoal = value!;
              });
            },
          ),

          const SizedBox(height: 15),

          bookingButton(),
        ],
      ),
    );
  }

  // =========================
  // BOOKING BUTTON LOGIC
  // =========================
  Widget bookingButton() {
    if (bookingStatus == "pending") {
      return statusBox("⏳ Pending Approval", Colors.orange);
    }

    if (bookingStatus == "accepted") {
      return statusBox("✅ Trainer Accepted", Colors.green);
    }

    if (bookingStatus == "declined") {
      return statusBox("❌ Declined", Colors.red);
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
        ),
        onPressed: bookTrainer,
        child: const Text("Book Trainer"),
      ),
    );
  }

  Widget statusBox(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color),
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Workouts"),
        backgroundColor: Colors.black,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4E157),
        onPressed: openAddDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // SUMMARY
            Row(
              children: [
                Expanded(
                  child: summaryBox(
                      "${workouts.length}", "Total Workouts"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: summaryBox(
                      "${workouts.fold<int>(0, (sum, w) {
                        final duration = w['duration'];
                        return sum + (duration is int
                            ? duration
                            : int.tryParse('$duration') ?? 0);
                      })}",
                      "Total Minutes"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔥 NEW BOOKING CARD
            bookingCard(),

            const SizedBox(height: 20),

            // WORKOUT LIST
            Expanded(
              child: workouts.isEmpty
                  ? const Center(
                  child: Text("No workouts yet",
                      style: TextStyle(color: Colors.grey)))
                  : ListView(
                children: workouts.map((w) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          w["notes"] ?? "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold),
                        ),
                        const SizedBox(height: 5),

                        Text(
                          "${w["date"]} • ${w["duration"]} min • ${w["duration"] * 5} cal",
                          style: const TextStyle(
                              color: Colors.grey),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4),
                          decoration: BoxDecoration(
                            color:
                            Colors.green.withOpacity(0.2),
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Text(
                            w["type"] ?? "",
                            style: const TextStyle(
                                color: Colors.green),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () =>
                                deleteWorkout(w['id']),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  InputDecoration input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}