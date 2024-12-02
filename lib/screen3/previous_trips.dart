import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PreviousTripScreen extends StatelessWidget {
  final String userId; // The logged-in user's ID

  const PreviousTripScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Trips'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
      ),
      body: StreamBuilder(
        // Firestore query to get completed trips filtered by the logged-in user
        stream: FirebaseFirestore.instance
            .collection('trip_requests')
            .where('userId', isEqualTo: userId) // Filter requests by user
            .where('status', isEqualTo: 'Completed') // Filter completed trips
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Show a loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show an error message if the query fails
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading previous trips.'));
          }

          final previousTrips = snapshot.data?.docs ?? [];

          // If no trips are found, show a message
          if (previousTrips.isEmpty) {
            return const Center(child: Text('No previous trips found.'));
          }

          // Display the list of previous trips
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: previousTrips.length,
            itemBuilder: (context, index) {
              final trip = previousTrips[index].data() as Map<String, dynamic>;

              // Ensure that the 'date' field is a Firestore Timestamp and convert it to DateTime
              Timestamp timestamp = trip['date'];
              DateTime dateTime =
                  timestamp.toDate(); // Convert Timestamp to DateTime

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip name
                      Text(
                        trip['tripName'] ?? 'Unnamed Trip',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Destination
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trip['destination'] ?? 'Unknown Destination',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Date (Formatted)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(dateTime)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Status: Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
