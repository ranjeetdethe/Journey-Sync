import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TripRequestScreen extends StatelessWidget {
  final String userId; // The logged-in user's ID

  const TripRequestScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Requests'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Simple static card added before the list
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kokan Trip',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Diveagar',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Date: 2024-11-30',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Status: Pending',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.hourglass_empty, color: Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // StreamBuilder for dynamic trip requests
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trip_requests')
                  .where('userId',
                      isEqualTo: userId) // Filter requests by the current user
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // Show a loading spinner while waiting for data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show an error message if the query fails
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Error loading trip requests.'));
                }

                final tripRequests = snapshot.data?.docs ?? [];

                // If no requests are found, show a message
                if (tripRequests.isEmpty) {
                  return const Center(child: Text(''));
                }

                // Display the list of trip requests
                return ListView.builder(
                  shrinkWrap: true, // To avoid taking unnecessary space
                  itemCount: tripRequests.length,
                  itemBuilder: (context, index) {
                    final request =
                        tripRequests[index].data() as Map<String, dynamic>;

                    // Get the request status and set color based on the status
                    String status = request['status'] ?? 'Unknown';
                    Color statusColor = _getStatusColor(status);

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
                            // Trip name
                            Text(
                              request['tripName'] ?? 'Unnamed Trip',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Destination
                            Text(
                              'Destination: ${request['destination'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            // Date
                            Text(
                              'Date: ${request['date'] ?? 'Unknown Date'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            // Status and icon (if Pending)
                            Row(
                              children: [
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Icon shown only for Pending status
                                status == 'Pending'
                                    ? const Icon(Icons.hourglass_empty,
                                        color: Colors.amber)
                                    : const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to return color based on trip status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
