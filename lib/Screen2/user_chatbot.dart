import 'package:flutter/material.dart';
import 'package:travel_manager/Screen2/chatscreen.dart';

class UserChatBot extends StatelessWidget {
  const UserChatBot({super.key});
  @override
  Widget build(BuildContext context) {
    return const ChatScreen(
      senderUserEmail: 'abhishek@gmail.com',
      senderUserId: 'user123',
      senderType: 'user',
      recipientName: 'Abhishek Dere',
      recipientPhone: '9325128750',
      userId: '',
      tripId: '',
      tripName: '',
    );
  }
}
