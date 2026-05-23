import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_manager/Screen2/home_screen.dart';

// Constants for Firestore collections
const String kTripRequestsCollection = 'trip_requests';
const String kChatGroupsCollection = 'chat_groups';
const String kMessagesCollection = 'messages';
const String kUsersCollection = 'users';

class MessagesPage extends StatelessWidget {
  final String userId;

  const MessagesPage({super.key, required this.userId});

  // Function to add 10 default trip requests and corresponding chat groups
  Future<void> addDefaultTripData(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // List of 10 default trip data entries
    final List<Map<String, dynamic>> defaultTrips = [
      {
        'tripId': 'TRIP001',
        'tripName': 'Goa Beach Adventure',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP002',
        'tripName': 'Manali Ski Trip',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP003',
        'tripName': 'Jaipur Heritage Tour',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP004',
        'tripName': 'Kerala Backwaters',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP005',
        'tripName': 'Ladakh Road Trip',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP006',
        'tripName': 'Mysore Palace Visit',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP007',
        'tripName': 'Rishikesh Rafting',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP008',
        'tripName': 'Agra Taj Mahal Tour',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP009',
        'tripName': 'Darjeeling Hill Escape',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP010',
        'tripName': 'Andaman Island Hopping',
        'userId': userId,
        'status': 'Accepted',
        'createdAt': Timestamp.now()
      },
    ];

    // Corresponding chat group data for each trip
    final List<Map<String, dynamic>> defaultChatGroups = [
      {
        'tripId': 'TRIP001',
        'tripName': 'Goa Beach Adventure',
        'description': 'Explore sunny beaches!',
        'admins': [userId],
        'members': [userId, 'user2', 'user3'],
        'maxMembers': 10,
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP002',
        'tripName': 'Manali Ski Trip',
        'description': 'Ski in the Himalayas',
        'admins': [userId],
        'members': [userId, 'user4'],
        'maxMembers': 8,
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP003',
        'tripName': 'Jaipur Heritage Tour',
        'description': 'Discover royal history',
        'admins': [userId],
        'members': [userId, 'user5', 'user6', 'user7'],
        'maxMembers': 12,
        'createdAt': Timestamp.now()
      },
      {
        'tripId': 'TRIP004',
        'tripName': 'Kerala Backwaters',
        'description': 'Cruise serene waters',
        'admins': [userId],
        'members': [userId, 'user8'],
        'maxMembers': 6,
        'createdAt': Timestamp.now()
      },
    ];

    try {
      // Add default trip requests to batch
      for (var trip in defaultTrips) {
        final docRef = firestore.collection(kTripRequestsCollection).doc();
        batch.set(docRef, trip);
      }

      // Add default chat groups to batch
      for (var chatGroup in defaultChatGroups) {
        final docRef = firestore.collection(kChatGroupsCollection).doc();
        batch.set(docRef, chatGroup);
      }

      // Commit the batch to Firestore
      await batch.commit();
      print(
          'Successfully added 10 default trips and chat groups for user: $userId');
    } catch (e) {
      print('Error adding default trip data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call addDefaultTripData when the page loads (for demo purposes)
    addDefaultTripData(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('     My Trips & Chat Groups'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to MyHomePage with the Home tab selected
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
            .collection(kTripRequestsCollection)
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'Accepted')
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
              final tripId = request['tripId'] as String? ?? '';
              final tripName = request['tripName'] as String? ?? 'Unnamed Trip';

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(kChatGroupsCollection)
                    .where('tripId', isEqualTo: tripId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (chatSnapshot.hasError) {
                    return const Center(
                        child: Text('Error loading chat group'));
                  }

                  if (!chatSnapshot.hasData ||
                      chatSnapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final chatGroup = chatSnapshot.data!.docs.first;
                  final chatData = chatGroup.data() as Map<String, dynamic>;
                  final isAdmin = (chatData['admins'] as List<dynamic>?)
                          ?.contains(userId) ??
                      false;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        chatData['tripName'] as String? ?? 'Unnamed Trip',
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
                              'Members: ${(chatData['members'] as List<dynamic>?)?.length ?? 0}/${chatData['maxMembers'] ?? 0}'),
                          if (isAdmin) const Text('Role: Admin'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.deepPurple),
                        onPressed: () async {
                          String senderEmail = '';
                          try {
                            final userDoc = await FirebaseFirestore.instance
                                .collection(kUsersCollection)
                                .doc(userId)
                                .get();
                            senderEmail =
                                userDoc.data()?['email'] as String? ?? '';
                          } catch (e) {
                            print('Error fetching user email: $e');
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupChatScreen(
                                userId: userId,
                                tripId: tripId,
                                tripName: tripName,
                                chatGroupId: chatGroup.id,
                                isAdmin: isAdmin,
                                senderUserEmail: senderEmail,
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

class GroupChatScreen extends StatefulWidget {
  final String userId;
  final String tripId;
  final String tripName;
  final String chatGroupId;
  final bool isAdmin;
  final String senderUserEmail;

  const GroupChatScreen({
    super.key,
    required this.userId,
    required this.tripId,
    required this.tripName,
    required this.chatGroupId,
    required this.isAdmin,
    required this.senderUserEmail,
  });

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Send a text message to the group
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .collection(kMessagesCollection)
          .add({
        'senderId': widget.userId,
        'senderEmail': widget.senderUserEmail,
        'text': _messageController.text.trim(),
        'timestamp': Timestamp.now(),
      });
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  // Scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripName,
            style: TextStyle(fontSize: 24, color: Colors.black)),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsScreen(
                    chatGroupId: widget.chatGroupId,
                    userId: widget.userId,
                    isAdmin: widget.isAdmin,
                    tripName: widget.tripName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(kChatGroupsCollection)
                  .doc(widget.chatGroupId)
                  .collection(kMessagesCollection)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!.docs;
                _scrollToBottom();

                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == widget.userId;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color.fromRGBO(255, 112, 41, 1)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['senderEmail'] as String? ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 12,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['text'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                color: isMe ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('hh:mm a, MMM d').format(
                                (message['timestamp'] as Timestamp?)
                                        ?.toDate() ??
                                    DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black54,
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color.fromRGBO(255, 112, 41, 1)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupSettingsScreen extends StatefulWidget {
  final String chatGroupId;
  final String userId;
  final bool isAdmin;
  final String tripName;

  const GroupSettingsScreen({
    super.key,
    required this.chatGroupId,
    required this.userId,
    required this.isAdmin,
    required this.tripName,
  });

  get tripId => null;

  @override
  _GroupSettingsScreenState createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _addMemberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial group data
    FirebaseFirestore.instance
        .collection(kChatGroupsCollection)
        .doc(widget.chatGroupId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['tripName'] as String? ?? '';
        _descController.text = data['description'] as String? ?? '';
      }
    });
  }

  // Add a member to the group
  Future<void> _addMember() async {
    final newMemberId = _addMemberController.text.trim();
    if (newMemberId.isEmpty) return;

    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .get();
      final data = groupDoc.data() as Map<String, dynamic>;
      final members = (data['members'] as List<dynamic>?)?.cast<String>() ?? [];
      final maxMembers = data['maxMembers'] as int? ?? 0;

      if (members.contains(newMemberId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User already in group')),
        );
        return;
      }
      if (members.length >= maxMembers) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group is full')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .update({
        'members': FieldValue.arrayUnion([newMemberId]),
      });
      _addMemberController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding member: $e')),
      );
    }
  }

  // Remove a member from the group
  Future<void> _removeMember(String memberId) async {
    if (memberId == widget.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot remove yourself as admin')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .update({
        'members': FieldValue.arrayRemove([memberId]),
        'admins': FieldValue.arrayRemove([memberId]), // Also remove from admins
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing member: $e')),
      );
    }
  }

  // Make a member an admin
  Future<void> _makeAdmin(String memberId) async {
    try {
      await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .update({
        'admins': FieldValue.arrayUnion([memberId]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member made admin successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making admin: $e')),
      );
    }
  }

  // Revoke admin rights from a member
  Future<void> _revokeAdmin(String memberId) async {
    if (memberId == widget.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot revoke your own admin rights')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .update({
        'admins': FieldValue.arrayRemove([memberId]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin rights revoked successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error revoking admin: $e')),
      );
    }
  }

  // Exit the group
  Future<void> _exitGroup() async {
    try {
      await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .update({
        'members': FieldValue.arrayRemove([widget.userId]),
        'admins': FieldValue.arrayRemove([widget.userId]),
      });
      await FirebaseFirestore.instance
          .collection(kTripRequestsCollection)
          .where('userId', isEqualTo: widget.userId)
          .where('tripId', isEqualTo: widget.tripId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      Navigator.pop(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have left the group')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exiting group: $e')),
      );
    }
  }

  // Edit group details
  Future<void> _editGroupDetails() async {
    if (_nameController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection(kChatGroupsCollection)
          .doc(widget.chatGroupId)
          .update({
        'tripName': _nameController.text.trim(),
        'description': _descController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group details updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating group details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Settings'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(kChatGroupsCollection)
            .doc(widget.chatGroupId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading group info'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Group not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final members =
              (data['members'] as List<dynamic>?)?.cast<String>() ?? [];
          final admins =
              (data['admins'] as List<dynamic>?)?.cast<String>() ?? [];
          final maxMembers = data['maxMembers'] as int? ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Info
                const Text(
                  'Group Info',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: widget.isAdmin,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: widget.isAdmin,
                ),
                if (widget.isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: _editGroupDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Changes',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                const SizedBox(height: 16),
                // Participants
                const Text(
                  'Participants',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (widget.isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _addMemberController,
                          decoration: InputDecoration(
                            labelText: 'Add Member (User ID)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add,
                            color: Color.fromRGBO(255, 112, 41, 1)),
                        onPressed: _addMember,
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final memberId = members[index];
                    final isAdmin = admins.contains(memberId);
                    return ListTile(
                      title: Text(memberId),
                      subtitle: Text(isAdmin ? 'Admin' : 'Member'),
                      trailing: widget.isAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.person_add,
                                        color: Colors.green),
                                    onPressed: () => _makeAdmin(memberId),
                                  ),
                                if (isAdmin && memberId != widget.userId)
                                  IconButton(
                                    icon: const Icon(Icons.person_remove,
                                        color: Colors.orange),
                                    onPressed: () => _revokeAdmin(memberId),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () => _removeMember(memberId),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Exit Group
                Center(
                  child: ElevatedButton(
                    onPressed: _exitGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Exit Group',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
