import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Notification> _notifications = [
    Notification(
      title: "Super Offer",
      description: "Get 60% off in our first booking",
      time: "Sun, 12:40pm",
      imageUrl: "https://example.com/user1.jpg",
    ),
    Notification(
      title: "Super Offer",
      description: "Get 60% off in our first booking",
      time: "Mon, 11:50pm",
      imageUrl: "https://example.com/user2.jpg",
    ),
    Notification(
      title: "Super Offer",
      description: "Get 60% off in our first booking",
      time: "Tue, 10:56pm",
      imageUrl: "https://example.com/user3.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                Notification notification = _notifications[index];
                return _buildNotificationItem(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTab("Recent"),
          _buildTab("Earlier"),
          _buildTab("Archived"),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: text == "Recent" ? Colors.blue : Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Notification notification) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(notification.imageUrl),
      ),
      title: Text(notification.title),
      subtitle: Text(notification.description),
      trailing: Text(notification.time),
    );
  }
}

class Notification {
  final String title;
  final String description;
  final String time;
  final String imageUrl;

  Notification({
    required this.title,
    required this.description,
    required this.time,
    required this.imageUrl,
  });
}
