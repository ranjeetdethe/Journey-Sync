import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_manager/Screen2/home_screen.dart'; // For date formatting

class TripListPage extends StatelessWidget {
  const TripListPage({super.key});

  void _joinTrip(BuildContext context, String tripName, String tripId,
      String userId) async {
    try {
      // Check if the user has already requested this trip
      final existingRequest = await FirebaseFirestore.instance
          .collection('trip_requests')
          .where('tripId', isEqualTo: tripId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You have already requested to join this trip.')));
        return;
      }

      // Add trip request to Firestore
      await FirebaseFirestore.instance.collection('trip_requests').add({
        'tripId': tripId,
        'tripName': tripName,
        'userId': userId,
        'requestedAt': Timestamp.now(),
        'status': 'Pending', // Initial status is 'Pending'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request to join $tripName sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join $tripName: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const String userId = "user123"; // Replace with actual logged-in user ID

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips List'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(userId: userId),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .orderBy('date', descending: false) // Sort trips by date ascending
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading trips.'));
          }

          final trips = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final tripDoc = trips[index];
              final trip = tripDoc.data() as Map<String, dynamic>;
              final tripId = tripDoc.id;

              // Handle 'date' field properly
              final tripDate = trip['date'] is Timestamp
                  ? DateFormat('yyyy-MM-dd')
                      .format((trip['date'] as Timestamp).toDate())
                  : trip['date'] as String;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip['tripName'] ?? 'Unnamed Trip',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'From: ${trip['from'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Destination: ${trip['destination']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Date: $tripDate',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Number of People: ${trip['numberOfPeople'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Budget: INR ${trip['budget']?.toStringAsFixed(2) ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _joinTrip(
                          context,
                          trip['tripName'] ?? 'Trip',
                          tripId,
                          userId,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(255, 112, 41, 1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: const Text(
                          'Join Trip',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
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
