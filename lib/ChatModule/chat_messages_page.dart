import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_manager/Screen2/chatscreen.dart'; // Or use ChatMessagesPage

class MessagesPage extends StatelessWidget {
  final String userId;

  const MessagesPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips & Chat Groups'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('trip_requests')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'Accepted') // Only show accepted trips
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your trips...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading trips'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No trips joined yet'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final tripId = request['tripId'];
              final tripName = request['tripName'];

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chat_groups')
                    .where('tripId', isEqualTo: tripId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!chatSnapshot.hasData ||
                      chatSnapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final chatGroup = chatSnapshot.data!.docs.first.data()
                      as Map<String, dynamic>;
                  final isAdmin =
                      (chatGroup['admins'] as List).contains(userId);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        chatGroup['tripName'] ?? 'Unnamed Trip',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trip ID: $tripId'),
                          Text(
                              'Members: ${chatGroup['members'].length}/${chatGroup['maxMembers']}'),
                          if (isAdmin) const Text('Role: Admin'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.deepPurple),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                // Or ChatMessagesPage
                                userId: userId,
                                tripId: tripId,
                                tripName: tripName,
                                senderUserEmail: '', // Fill as needed
                                senderUserId: userId,
                                senderType: isAdmin ? 'admin' : 'member',
                                recipientPhone: '', // Fill as needed
                                recipientName: '', // Fill as needed
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
