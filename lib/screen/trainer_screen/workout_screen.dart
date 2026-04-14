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

  List plans = [];
  bool isLoadingPlan = true;

  String selectedGoal = "";
  List workoutTypes = [];

  List trainers = [];
  String? selectedTrainerId;
  String? selectedTrainerName;

  List<Map<String, dynamic>> workouts = [];

  // 🔥 NEW: MULTIPLE BOOKINGS
  List<Map<String, dynamic>> userBookings = [];

  @override
  void initState() {
    super.initState();
    loadWorkouts();
    loadWorkoutTypes();
    loadBookings();
    loadWorkoutPlan();
  }

  Future<void> loadTrainers() async {
    if (selectedGoal.isEmpty) return;

    final data = await Supabase.instance.client
        .from('trainers')
        .select()
        .eq('type', selectedGoal.toLowerCase());

    setState(() {
      trainers = data;
      selectedTrainerId = null; // reset selection
    });
  }

  Future<void> loadWorkoutPlan() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await Supabase.instance.client
        .from('workout_plans')
        .select()
        .eq('user_name', user.email ?? "");

    setState(() {
      plans = data;
      isLoadingPlan = false;
    });
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

  // =========================
  // LOAD WORKOUT TYPES (Supabase)
  // =========================
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
  // LOAD USER BOOKINGS
  // =========================
  Future<void> loadBookings() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await Supabase.instance.client
        .from('bookings')
        .select()
        .eq('user_id', user.id);

    setState(() {
      userBookings = List<Map<String, dynamic>>.from(data);
    });
  }

  // =========================
  // GET STATUS BY TYPE
  // =========================
  String? getBookingStatus(String goal) {
    final booking = userBookings.firstWhere(
          (b) =>
      b['goal'] == goal &&
          b['trainer_id'] == selectedTrainerId,
      orElse: () => {},
    );

    return booking.isEmpty ? null : booking['status'];


  }

  // =========================
  // BOOK TRAINER
  // =========================
  Future<void> bookTrainer() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      if (selectedTrainerId == null) {
        show("Please select a trainer");
        return;
      }

      await Supabase.instance.client.from('bookings').insert({
        'user_id': user.id,
        'user_name': user.email,
        'goal': selectedGoal.toLowerCase(),
        'trainer_id': selectedTrainerId,
        'trainer_name': selectedTrainerName, // ✅ ADD THIS
        'status': 'pending',
      });

      await loadBookings();

      show("Booking sent!");
    } catch (e) {
      print("ERROR: $e");
      show("Error booking trainer");
    }
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
  // BOOKING CARD
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
              loadTrainers(); // 🔥 IMPORTANT
            },
          ),

          const SizedBox(height: 10),

// 🔥 TRAINER LIST
          trainers.isEmpty
              ? const Text(
            "No trainers available",
            style: TextStyle(color: Colors.grey),
          )
              : Column(
            children: trainers.map((t) {
              final isSelected = selectedTrainerId == t['id'];

              return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTrainerId = t['id'];
                      selectedTrainerName = t['name']; // ✅ ADD THIS
                    });
                  },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4E157)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        t['name'],
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFD4E157)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
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
    final status = getBookingStatus(selectedGoal);

    if (status == "pending") {
      return statusBox("⏳ Pending Approval", Colors.orange);
    }

    if (status == "accepted") {
      return statusBox("✅ Trainer Accepted", Colors.green);
    }

// 🔥 allow retry if declined
    if (status == "declined") {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: bookTrainer,
          child: const Text("Book Again"),
        ),
      );
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

  Widget workoutPlanCard() {
    if (isLoadingPlan) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // SAME as your cards
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Workout Plan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          if (plans.isEmpty)
            const Text(
              "No workout plan yet",
              style: TextStyle(color: Colors.grey),
            )
          else ...[
            Text(
              plans.last['title'] ?? "",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              plans.last['description'] ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
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

            Row(
              children: [
                Expanded(
                  child: summaryBox("${workouts.length}", "Total Workouts"),
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

            bookingCard(),

            const SizedBox(height: 20),


            const SizedBox(height: 20),

            const SizedBox(height: 20),

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

  // =========================
  // ADD WORKOUT DIALOG
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