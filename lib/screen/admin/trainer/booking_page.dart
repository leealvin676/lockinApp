import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBookingPage extends StatefulWidget {
  const AdminBookingPage({super.key});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  final supabase = Supabase.instance.client;

  List bookings = [];
  List filteredBookings = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final data = await supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        bookings = data;
        filteredBookings = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void search(String query) {
    final results = bookings.where((b) {
      final user = (b['user_name'] ?? '').toString().toLowerCase();
      final trainer = (b['trainer_name'] ?? '').toString().toLowerCase();
      return user.contains(query.toLowerCase()) ||
          trainer.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredBookings = results;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
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
              "Bookings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: searchController,
              onChanged: search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search user or trainer...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF333333),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBookings.isEmpty
                  ? const Center(
                child: Text(
                  "No bookings yet",
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final b = filteredBookings[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF444444),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          b['user_name'] ?? "Unknown User",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Goal: ${b['goal'] ?? '-'}",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Trainer: ${b['trainer_name'] ?? 'Not assigned'}",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor(b['status']),
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                              child: Text(
                                b['status'],
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}