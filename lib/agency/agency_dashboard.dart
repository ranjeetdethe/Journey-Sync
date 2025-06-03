import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_manager/screen3/trip_creation.dart';
import 'package:travel_manager/agency/destination_creation.dart';
import 'package:travel_manager/agency/user_profile_screen.dart';

class AgencyDashboardScreen extends StatefulWidget {
  const AgencyDashboardScreen({super.key});

  @override
  State<AgencyDashboardScreen> createState() => _AgencyDashboardScreenState();
}

class _AgencyDashboardScreenState extends State<AgencyDashboardScreen> {
  String selectedStatus = 'all';

  Stream<QuerySnapshot> getTripRequestsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .asyncMap((tripSnapshot) async {
      final tripIds = tripSnapshot.docs.map((doc) => doc.id).toList();
      if (tripIds.isEmpty) {
        return FirebaseFirestore.instance
            .collection('trip_requests')
            .where('tripId', isEqualTo: 'non-existent-id')
            .snapshots()
            .first;
      }

      Query query = FirebaseFirestore.instance
          .collection('trip_requests')
          .where('tripId', whereIn: tripIds);
      if (selectedStatus != 'all') {
        query = query.where('status', isEqualTo: selectedStatus);
      }
      return await query.snapshots().first;
    });
  }

  Future<Map<String, dynamic>> _fetchTripAndUserData(
      List<DocumentSnapshot> requests) async {
    final tripIds = requests.map((req) => req['tripId'] as String).toSet();
    final userIds = requests.map((req) => req['userId'] as String).toSet();

    final tripsSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where(FieldPath.documentId, whereIn: tripIds.toList())
        .get();
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds.toList())
        .get();

    final tripDataMap = {
      for (var doc in tripsSnapshot.docs)
        doc.id: doc.data() as Map<String, dynamic>
    };
    final userDataMap = {
      for (var doc in usersSnapshot.docs)
        doc.id: doc.data() as Map<String, dynamic>
    };

    final filteredRequests = requests.where((req) {
      final tripId = req['tripId'] as String;
      final userId = req['userId'] as String;
      return tripDataMap.containsKey(tripId) && userDataMap.containsKey(userId);
    }).toList();

    return {
      'filteredRequests': filteredRequests,
      'trips': tripDataMap,
      'users': userDataMap,
    };
  }

  Stream<QuerySnapshot> getBookingsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('trips')
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .asyncMap((tripSnapshot) async {
      final tripIds = tripSnapshot.docs.map((doc) => doc.id).toList();
      if (tripIds.isEmpty) {
        return FirebaseFirestore.instance
            .collection('bookings')
            .where('tripId', isEqualTo: 'non-existent-id')
            .snapshots()
            .first;
      }
      return await FirebaseFirestore.instance
          .collection('bookings')
          .where('tripId', whereIn: tripIds)
          .snapshots()
          .first;
    });
  }

  Future<void> _updateRequestStatus(String requestId, String userIdRequest,
      String tripName, String status) async {
    try {
      // Update the trip request status
      await FirebaseFirestore.instance
          .collection('trip_requests')
          .doc(requestId)
          .update({'status': status});

      // Send a notification to the user
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userIdRequest)
          .collection('notifications')
          .add({
        'title': 'Trip Request $status',
        'message': 'Your request to join $tripName has been $status.',
        'time': Timestamp.now(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip request $status successfully!')),
      );

      // Refresh the screen to reflect the updated status
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to $status request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agency Dashboard',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TripCreationPage(userId: userId)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    minimumSize: const Size(150, 48),
                  ),
                  child: Text(
                    'Create New Trip',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DestinationCreationPage(userId: userId)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                    minimumSize: const Size(150, 48),
                  ),
                  child: Text(
                    'Create New Destination',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip Requests',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color.fromRGBO(27, 30, 40, 1),
                  ),
                ),
                DropdownButton<String>(
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'Approved', child: Text('Approved')),
                    DropdownMenuItem(
                        value: 'Rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: StreamBuilder<QuerySnapshot>(
                  stream: getTripRequestsStream(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color.fromRGBO(255, 112, 41, 1)),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Error loading trip requests.',
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () => setState(() {}),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color.fromRGBO(255, 112, 41, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No trip requests.',
                          style: GoogleFonts.inter(
                              fontSize: 16, color: Colors.grey[600]),
                        ),
                      );
                    }

                    final requests = snapshot.data!.docs;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _fetchTripAndUserData(requests),
                      builder: (context, futureSnapshot) {
                        if (futureSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Color.fromRGBO(255, 112, 41, 1)),
                          );
                        }
                        if (futureSnapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading trip/user data.',
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.red),
                            ),
                          );
                        }

                        final filteredRequests =
                            futureSnapshot.data!['filteredRequests'] as List;
                        final tripDataMap =
                            futureSnapshot.data!['trips']! as Map;
                        final userDataMap =
                            futureSnapshot.data!['users']! as Map;

                        if (filteredRequests.isEmpty) {
                          return Center(
                            child: Text(
                              'No valid trip requests found.',
                              style: GoogleFonts.inter(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index].data()
                                as Map<String, dynamic>;
                            final requestId = filteredRequests[index].id;
                            final tripId = request['tripId'] as String;
                            final userIdRequest = request['userId'] as String;

                            final tripData = tripDataMap[tripId] ?? {};
                            final userData = userDataMap[userIdRequest] ?? {};

                            final tripName =
                                tripData['tripName'] ?? 'Unknown Trip';
                            final userName =
                                userData['firstName'] ?? 'Unknown User';
                            final status = request['status'] ?? 'Pending';

                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Trip: $tripName',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: const Color.fromRGBO(
                                                  27, 30, 40, 1),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          status,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: status == 'Approved'
                                                ? Colors.green
                                                : status == 'Pending'
                                                    ? Colors.orange
                                                    : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'User: $userName',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    if (status == 'Pending') ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                _updateRequestStatus(
                                                    requestId,
                                                    userIdRequest,
                                                    tripName,
                                                    'Approved'),
                                            child: Text(
                                              'Approve',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                _updateRequestStatus(
                                                    requestId,
                                                    userIdRequest,
                                                    tripName,
                                                    'Rejected'),
                                            child: Text(
                                              'Reject',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (status != 'Pending') ...[
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UserProfileScreen(
                                                  userId: userIdRequest,
                                                  tripId: tripId,
                                                  requestId: requestId,
                                                  tripName: tripName,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'View Profile',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: const Color.fromRGBO(
                                                  255, 112, 41, 1),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analytics',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: const Color.fromRGBO(27, 30, 40, 1),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: getBookingsStream(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                          color: Color.fromRGBO(255, 112, 41, 1));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading bookings.',
                          style: GoogleFonts.inter(
                              fontSize: 16, color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text(
                        'No bookings yet.',
                        style: GoogleFonts.inter(
                            fontSize: 16, color: Colors.grey[600]),
                      );
                    }
                    final bookings = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Bookings: ${bookings.length}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(27, 30, 40, 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pending: ${bookings.where((b) => b['status'] == 'pending').length}',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
