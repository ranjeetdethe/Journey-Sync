import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreenn extends StatefulWidget {
  final String senderUserEmail;
  final String senderUserId;
  final String senderType; // 'user' or 'serviceProvider'
  final String recipientName;
  final String recipientPhone;

  const ChatScreenn({
    super.key,
    required this.senderUserEmail,
    required this.senderUserId,
    required this.senderType,
    required this.recipientName,
    required this.recipientPhone,
  });

  @override
  State createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreenn> {
  final TextEditingController _messageController = TextEditingController();
  final CollectionReference _messages =
      FirebaseFirestore.instance.collection('messages');
  final ScrollController _scrollController = ScrollController();

  bool isNightTheme = false;

  Future<void> _makeCall(String number) async {
    try {
      final Uri callUri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        log('Cannot launch call to $number. Uri: $callUri');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to make a call to $number")),
        );
      }
    } catch (e) {
      log('Error attempting to make a call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An error occurred while trying to call $number")),
      );
    }
  }

  void _showCallPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Call ${widget.recipientName}",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Phone: ${widget.recipientPhone}",
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _makeCall(widget.recipientPhone);
              },
              child: Text(
                "Call",
                style: GoogleFonts.inter(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the colors based on the theme
    final Color backgroundColor =
        isNightTheme ? const Color(0xFF1E1E2C) : Colors.white;
    final Color appBarColor = isNightTheme
        ? const Color(0xFFD9D9D9)
        : const Color.fromRGBO(255, 100, 33, 1);
    final Color iconColor =
        isNightTheme ? const Color(0xFFE3B505) : const Color(0xFFD9D9D9);
    final Color topColor =
        isNightTheme ? const Color(0xFF1E1E2C) : const Color(0xFFB1D7F0);
    final Color bottomColor =
        isNightTheme ? const Color(0xFF282846) : const Color(0xFFFFF5D1);
    final Color textFieldColor =
        isNightTheme ? const Color(0xFF393955) : const Color(0xFFF6F6F6);
    final Color inputTextColor = isNightTheme ? Colors.white : Colors.black;
    final Color messageTextColor = isNightTheme ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios,
              color: isNightTheme ? Colors.white : Colors.black),
        ),
        title: Row(
          children: [
            Text(
              widget.recipientName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isNightTheme ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: _showCallPopup,
          ),
          IconButton(
            icon: Icon(isNightTheme ? Icons.video_call : Icons.video_call,
                color: Colors.white),
            onPressed: () {
              setState(() {
                isNightTheme = !isNightTheme;
              });
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [topColor, bottomColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: StreamBuilder(
                  stream: _messages
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching messages.'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No messages available.'));
                    }

                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());

                    return ListView(
                      reverse: true,
                      controller: _scrollController,
                      children: snapshot.data!.docs.map((doc) {
                        bool isSender = doc['senderId'] == widget.senderUserId;
                        return Align(
                          alignment: isSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: isSender
                                    ? LinearGradient(colors: [
                                        const Color(0xFFD9D9D9),
                                        isNightTheme
                                            ? const Color(0xFFD9D9D9)
                                            : const Color(0xFFD9D9D9)
                                      ])
                                    : LinearGradient(colors: [
                                        const Color(0xFFF6F6F6),
                                        isNightTheme
                                            ? const Color(0xFFD9D9D9)
                                            : const Color(0xFFD9D9D9)
                                      ]),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    width: 2, color: const Color(0xFFD9D9D9)),
                              ),
                              child: Text(
                                doc['message'],
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: messageTextColor),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              color: textFieldColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: inputTextColor),
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(
                            color: isNightTheme ? Colors.grey : Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.orange),
                    onPressed: () async {
                      if (_messageController.text.trim().isNotEmpty) {
                        await _messages.add({
                          'message': _messageController.text.trim(),
                          'senderId': widget.senderUserId,
                          'senderType': widget.senderType,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        _messageController.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
