import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_manager/Screen2/home_screen.dart';
import 'package:travel_manager/ChatModule/chat_messages_page.dart';

class TripListPage extends StatelessWidget {
  const TripListPage({super.key, required this.userId});

  final String userId;

  void _joinTrip(
      BuildContext context,
      String tripName,
      String tripId,
      String userId,
      int numberOfPeople,
      String destination,
      String date) async {
    try {
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

      final currentRequests = await FirebaseFirestore.instance
          .collection('trip_requests')
          .where('tripId', isEqualTo: tripId)
          .where('status', isEqualTo: 'Accepted')
          .get();

      if (currentRequests.docs.length >= numberOfPeople) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('This trip has reached its maximum capacity.')));
        return;
      }

      await FirebaseFirestore.instance.collection('trip_requests').add({
        'tripId': tripId,
        'tripName': tripName,
        'userId': userId,
        'destination': destination, // Add destination
        'date': date, // Add date
        'requestedAt': Timestamp.now(),
        'status': 'Pending',
      });

      final chatGroupQuery = await FirebaseFirestore.instance
          .collection('chat_groups')
          .where('tripId', isEqualTo: tripId)
          .get();

      if (chatGroupQuery.docs.isNotEmpty) {
        final chatGroupDoc = chatGroupQuery.docs.first;
        final members = List<String>.from(chatGroupDoc['members']);
        if (!members.contains(userId) && members.length < numberOfPeople) {
          members.add(userId);
          await chatGroupDoc.reference.update({'members': members});
        }
      } else if (currentRequests.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('chat_groups').add({
          'tripId': tripId,
          'tripName': tripName,
          'creatorId': userId,
          'members': [userId],
          'maxMembers': numberOfPeople,
          'createdAt': Timestamp.now(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request to join $tripName sent!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MessagesPage(userId: userId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join $tripName: $e')),
      );
    }
  }

  Future<void> _cleanupExpiredTrips(QuerySnapshot snapshot) async {
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      final trip = doc.data() as Map<String, dynamic>;
      final tripDate = trip['date'] is Timestamp
          ? (trip['date'] as Timestamp).toDate()
          : DateTime.parse(trip['date'] as String);

      if (tripDate.isBefore(now)) {
        batch.delete(doc.reference);
      }
    }

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips List'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
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
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading trips.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No upcoming trips available'));
          }

          _cleanupExpiredTrips(snapshot.data!);

          final trips = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final tripDoc = trips[index];
              final trip = tripDoc.data() as Map<String, dynamic>;
              final tripId = tripDoc.id;

              final tripDate = trip['date'] is Timestamp
                  ? DateFormat('yyyy-MM-dd')
                      .format((trip['date'] as Timestamp).toDate())
                  : trip['date'] as String;

              final date = trip['date'] is Timestamp
                  ? (trip['date'] as Timestamp).toDate()
                  : DateTime.parse(trip['date'] as String);

              if (date.isBefore(DateTime.now())) {
                return const SizedBox.shrink();
              }

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
                      Text('From: ${trip['from'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16)),
                      Text('Destination: ${trip['destination']}',
                          style: const TextStyle(fontSize: 16)),
                      Text('Date: $tripDate',
                          style: const TextStyle(fontSize: 16)),
                      Text(
                          'Number of People: ${trip['numberOfPeople'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16)),
                      Text(
                          'Budget: INR ${trip['budget']?.toStringAsFixed(2) ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _joinTrip(
                          context,
                          trip['tripName'] ?? 'Trip',
                          tripId,
                          userId,
                          trip['numberOfPeople'] ?? 1,
                          trip['destination'] ?? 'Unknown',
                          tripDate,
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
