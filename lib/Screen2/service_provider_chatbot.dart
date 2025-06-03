import 'package:flutter/material.dart';
import 'package:travel_manager/Screen2/chatscreen.dart';

class ServiceProviderChatBot extends StatelessWidget {
  const ServiceProviderChatBot({super.key});
  @override
  Widget build(BuildContext context) {
    return const ChatScreen(
      senderUserEmail: 'provider@example.com',
      senderUserId: 'provider456',
      senderType: 'serviceProvider',
      recipientName: 'Ranjeet Dethe',
      recipientPhone: '+91 8999073518',
      userId: '',
      tripId: '',
      tripName: '',
    );
  }
}
