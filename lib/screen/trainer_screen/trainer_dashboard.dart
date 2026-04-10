import 'package:flutter/material.dart';
import 'workout_screen.dart';
import 'recommendation_screen.dart';
import 'trainer_profile_page.dart';
import 'user_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {

  List<Map<String, dynamic>> users = [];

  List<Map<String, dynamic>> bookings = [];
  final supabase = Supabase.instance.client;

  String trainerId = ""; // 🔥 will store trainer id
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  // =========================
  // LOAD BOOKINGS
  // =========================
  Future<void> loadBookings() async {

    // 🔥 TEMP: get first trainer (for testing)
    final trainer = await supabase
        .from('trainers')
        .select()
        .limit(1)
        .maybeSingle();

    if (trainer == null) return;

    trainerId = trainer['id'];

    final data = await supabase
        .from('bookings')
        .select()
        .eq('trainer_id', trainerId)
        .eq('status', 'pending');

    setState(() {
      bookings = List<Map<String, dynamic>>.from(data);
    });
  }

  // =========================
  // ACCEPT BOOKING
  // =========================
  Future<void> acceptBooking(Map booking) async {
    await supabase
        .from('bookings')
        .update({'status': 'accepted'})
        .eq('id', booking['id']);

    // 🔥 move to users list
    setState(() {
      users.add({
        "name": booking["user_name"],
        "goal": booking["goal"],
        "progress": 0,
        "active": true,
      });
    });

    await loadBookings();

    show("User accepted");
  }

  // =========================
  // DECLINE BOOKING
  // =========================
  Future<void> declineBooking(Map booking) async {
    await supabase
        .from('bookings')
        .update({'status': 'declined'})
        .eq('id', booking['id']);

    await loadBookings();

    show("Booking declined");
  }

  @override
  Widget build(BuildContext context) {

    final filteredUsers = users.where((u) {
      return u["name"].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: confirmLogout,
        ),
        title: const Text("Trainer Dashboard"),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TrainerProfilePage()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  SizedBox(width: 5),
                  Text("Trainer"),
                ],
              ),
            ),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserForm()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text("Welcome back, Trainer 👋",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              const Text("Manage your clients and bookings",
                  style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 15),

              // SEARCH
              TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search users...",
                  filled: true,
                  fillColor: Colors.grey[900],
                  prefixIcon:
                  const Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // BOOKINGS
              // =========================
              const Text("Pending Bookings",
                  style: TextStyle(color: Colors.white, fontSize: 18)),

              const SizedBox(height: 10),

              bookings.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text("No pending bookings",
                      style: TextStyle(color: Colors.grey)),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  return bookingCard(bookings[index]);
                },
              ),

              const SizedBox(height: 20),

              // =========================
              // USERS
              // =========================
              const Text("Users",
                  style: TextStyle(color: Colors.white, fontSize: 18)),

              const SizedBox(height: 10),

              filteredUsers.isEmpty
                  ? const Text("No users found",
                  style: TextStyle(color: Colors.grey))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return userCard(filteredUsers[index]);
                },
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // BOOKING CARD
  // =========================
  Widget bookingCard(Map booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking["user_name"] ?? "",
                      style: const TextStyle(color: Colors.white)),
                  Text(booking["goal"] ?? "",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  onPressed: () => acceptBooking(booking),
                  child: const Text("Accept"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => confirmDecline(booking),
                  child: const Text("Decline"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void confirmDecline(Map booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Decline Booking"),
        content: Text("Decline ${booking["user_name"]}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await declineBooking(booking);
              Navigator.pop(context);
            },
            child:
            const Text("Decline", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // =========================
  // USER CARD
  // =========================
  Widget userCard(Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user["name"],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(user["goal"],
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WorkoutScreen(userName: user["name"]),
                      ),
                    );
                  },
                  child: const Text("Workout Plan"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const RecommendationScreen(),
                      ),
                    );
                  },
                  child: const Text("Recommendation"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: () => deleteWithReason(user),
                  child: const Text("Delete"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void deleteWithReason(Map user) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Delete ${user["name"]}?"),
            TextField(
              controller: reasonController,
              decoration:
              const InputDecoration(labelText: "Reason"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                show("Please enter reason");
                return;
              }

              setState(() {
                users.remove(user);
              });

              Navigator.pop(context);
              show("User deleted");
            },
            child:
            const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child:
            const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}