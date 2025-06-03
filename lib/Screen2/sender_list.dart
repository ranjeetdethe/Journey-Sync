import 'package:flutter/material.dart';
import 'package:travel_manager/Screen2/chatscreen.dart';

class MessagingScreen extends StatelessWidget {
  // List of chat names
  final List<String> chatNames = [
    'Mumbai Trip',
    'Goa Holiday',
    'Kerala Travel',
    'Delhi Adventure'
  ];

  MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Implement more options logic
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit button logic
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for chats & messages",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chatNames.length, // Use the length of chatNames list
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chatNames[index]), // Display each chat name
                  trailing: const Text("09:46"),
                  onTap: () {
                    // Navigate to the Chat screen with dynamic data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          senderUserEmail: 'abhishek@gmail.com',
                          senderUserId: 'user123',
                          senderType: 'user',
                          recipientName: chatNames[
                              index], // Pass the chat name dynamically
                          recipientPhone: '9325128750', userId: '',
                          tripName: '', tripId: '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
