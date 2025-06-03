import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final String tripId;
  final String requestId;
  final String tripName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.tripId,
    required this.requestId,
    required this.tripName,
  });

  Future<void> _approveRequest(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('trip_requests')
          .doc(requestId)
          .update({'status': 'approved'});

      final tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();
      final tripData = tripSnapshot.data()!;
      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'currentParticipants': tripData['currentParticipants'] + 1,
      });

      final chatSnapshot = await FirebaseFirestore.instance
          .collection('chat_groups')
          .where('tripId', isEqualTo: tripId)
          .get();
      if (chatSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('chat_groups')
            .doc(chatSnapshot.docs.first.id)
            .update({
          'members': FieldValue.arrayUnion([userId]),
        });
      }

      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': userId,
        'title': 'Trip Request Approved',
        'message': 'Your request to join $tripName has been approved.',
        'time': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve request: $e')),
      );
    }
  }

  Future<void> _rejectRequest(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('trip_requests')
          .doc(requestId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
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
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(255, 112, 41, 1),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading user profile.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'User not found.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'Unknown';
          final userEmail = userData['email'] ?? 'No email';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: userData['profilePicture'] != null
                        ? NetworkImage(userData['profilePicture'])
                        : const AssetImage('assets/image2/Ellipse 22.png')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    userName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: const Color.fromRGBO(27, 30, 40, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    userEmail,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Trip Request: $tripName',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: const Color.fromRGBO(27, 30, 40, 1),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _approveRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: Text(
                        'Approve',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _rejectRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: Text(
                        'Reject',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
