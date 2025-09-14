import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Map<String, dynamic>> futureUser;
  late Future<List<dynamic>> futureBookings;

  @override
  void initState() {
    super.initState();
    futureUser = ApiService().getUserDetails(widget.userId);
    futureBookings = ApiService().getUserBookings(widget.userId);
  }

  void refreshBookings() {
    setState(() {
      futureBookings = ApiService().getUserBookings(widget.userId);
    });
  }

  void _confirmCancel(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await ApiService().cancelBooking(bookingId);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking cancelled successfully!')),
                  );
                  refreshBookings();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to cancel booking.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'User Details',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text('Username: ${user['username']}', style: const TextStyle(fontSize: 16)),
                          Text('User ID: ${user['id']}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(child: Text('User not found.'));
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: futureBookings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final booking = snapshot.data![index];
                        final formattedTime = DateFormat('MMMM d, yyyy - h:mm a').format(DateTime.parse(booking['start_time']));
                        final isCancelled = booking['status'] == 'cancelled';
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          // Change the color based on status
                          color: isCancelled ? Colors.red[50] : null,
                          child: ListTile(
                            title: Text(
                              booking['movie_title'],
                              style: TextStyle(
                                decoration: isCancelled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text(
                              '${booking['cinema_name']} at $formattedTime\nSeats: ${booking['seats']}',
                            ),
                            trailing: isCancelled
                                ? const Text(
                                    'Cancelled',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _confirmCancel(context, booking['booking_id']);
                                    },
                                  ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No booking history found.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}