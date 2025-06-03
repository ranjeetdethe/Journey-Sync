import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: const Color.fromRGBO(27, 30, 40, 1),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: ListView.builder(
          itemCount: notifications
              .length, // Replace with your notification data length
          itemBuilder: (context, index) {
            return NotificationItem(
              title: notifications[index]["title"],
              message: notifications[index]["message"],
              time: notifications[index]["time"],
              isRead: notifications[index]["isRead"],
              onTap: () {
                // Handle tap on notification (e.g., navigate to detail screen)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("Tapped on ${notifications[index]["title"]}")),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color.fromRGBO(247, 247, 249, 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon or Indicator
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isRead ? Colors.grey[300] : Colors.orange.withOpacity(0.2),
              ),
              child: Icon(
                Icons.notifications_active,
                color: isRead ? Colors.grey : Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color.fromRGBO(27, 30, 40, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Optional Action Icon (e.g., delete or mark as read)
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.grey),
              onPressed: () {
                // Handle action (e.g., dismiss notification)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Dismissed $title")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder notification data (replace with your actual data source)
final List<Map<String, dynamic>> notifications = [
  {
    "title": "Trip Invitation",
    "message": "Ranjeet has invited you to join a trip to Lonavala!",
    "time": "2 hours ago",
    "isRead": false,
  },
  {
    "title": "New Message",
    "message": "You have a new message from the trip group.",
    "time": "5 hours ago",
    "isRead": true,
  },
  {
    "title": "Trip Update",
    "message": "The trip to Sinhagad Fort has been rescheduled.",
    "time": "1 day ago",
    "isRead": false,
  },
  // Add more notifications as needed
];
