// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class ChatScreen extends StatefulWidget {
  final String userId;
  final String tripId;
  final String tripName;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.tripId,
    required this.tripName,
    required String senderUserEmail, // Not used in current code
    required String senderUserId, // Not used, redundant with userId
    required String senderType, // Not used in current code
    required String recipientPhone, // Not used in current code
    required String recipientName, // Not used in current code
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('chat_groups')
          .where('tripId', isEqualTo: widget.tripId)
          .get()
          .then((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          final chatGroupId = snapshot.docs.first.id;
          await FirebaseFirestore.instance
              .collection('chat_groups')
              .doc(chatGroupId)
              .collection('messages')
              .add({
            'senderId': widget.userId,
            'text': _messageController.text.trim(),
            'timestamp': Timestamp.now(),
          });
        }
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Function to handle search action
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {}); // Trigger rebuild to filter messages
                },
              )
            : Text(widget.tripName),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _stopSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chat_groups')
                  .where('tripId', isEqualTo: widget.tripId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> groupSnapshot) {
                if (!groupSnapshot.hasData ||
                    groupSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Chat group not found'));
                }

                final chatGroupId = groupSnapshot.data!.docs.first.id;

                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chat_groups')
                      .doc(chatGroupId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error loading messages'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    final messages = snapshot.data!.docs;
                    final searchQuery = _searchController.text.toLowerCase();

                    // Filter messages based on search query
                    final filteredMessages = _isSearching
                        ? messages.where((doc) {
                            final message = doc.data() as Map<String, dynamic>;
                            final text = (message['text'] as String? ?? '')
                                .toLowerCase();
                            return text.contains(searchQuery);
                          }).toList()
                        : messages;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredMessages.length,
                      itemBuilder: (context, index) {
                        final message = filteredMessages[index].data()
                            as Map<String, dynamic>;
                        final isMe = message['senderId'] == widget.userId;
                        final timestamp = message['timestamp'] as Timestamp?;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color.fromRGBO(255, 112, 41, 1)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['text'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timestamp != null
                                      ? DateFormat('hh:mm a, MMM d')
                                          .format(timestamp.toDate())
                                      : 'Unknown time',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                  ),
                                ),
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
                        borderRadius: BorderRadius.circular(10),
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
