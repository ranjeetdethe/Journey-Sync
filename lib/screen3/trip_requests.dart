import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TripRequestScreen extends StatefulWidget {
  final String userId;

  const TripRequestScreen({super.key, required this.userId});

  @override
  _TripRequestScreenState createState() => _TripRequestScreenState();
}

class _TripRequestScreenState extends State<TripRequestScreen> {
  late Stream<QuerySnapshot> _tripRequestsStream;

  @override
  void initState() {
    super.initState();
    _tripRequestsStream = FirebaseFirestore.instance
        .collection('trip_requests')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();
  }

  void _refreshStream() {
    setState(() {
      _tripRequestsStream = FirebaseFirestore.instance
          .collection('trip_requests')
          .where('userId', isEqualTo: widget.userId)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Requests'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // StreamBuilder for dynamic trip requests
            StreamBuilder<QuerySnapshot>(
              stream: _tripRequestsStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Error loading trip requests.'),
                        TextButton(
                          onPressed: _refreshStream,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final tripRequests = snapshot.data?.docs ?? [];

                // If no requests are found, show a static card
                if (tripRequests.isEmpty) {
                  return Column(
                    children: [
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
                                'Date: 2025-03-15',
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
                                  Icon(Icons.hourglass_empty,
                                      color: Colors.amber),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'No trip requests found. Join a trip to get started!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }

                // Display the list of trip requests
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tripRequests.length,
                  itemBuilder: (context, index) {
                    final request =
                        tripRequests[index].data() as Map<String, dynamic>;

                    String status = request['status'] ?? 'Unknown';
                    Color statusColor = _getStatusColor(status);

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
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
                                request['tripName'] ?? 'Unnamed Trip',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Destination: ${request['destination'] ?? ' '}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Date: ${request['date'] ?? '30 May 2025'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
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
                                  status == 'Pending'
                                      ? const Icon(Icons.hourglass_empty,
                                          color: Colors.amber)
                                      : const SizedBox(),
                                ],
                              ),
                            ],
                          ),
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
