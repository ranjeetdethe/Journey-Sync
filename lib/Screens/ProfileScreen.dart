import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_manager/Screen2/home_screen.dart';
import 'package:travel_manager/Screens/editProfile.dart';
import 'package:travel_manager/Screens/loginScreen.dart';
import 'package:travel_manager/screen3/about_us.dart';
import 'package:travel_manager/screen3/previous_trips.dart';
import 'package:travel_manager/screen3/trip_requests.dart'; // Import your request page

class ProfileScreen extends StatefulWidget {
  final String userId; // User's document ID in Firestore

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      throw 'User not found';
    } catch (e) {
      throw 'Failed to fetch user data';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(userId: widget.userId),
              ),
            );
          },
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditProfileScreen(userId: widget.userId),
                ),
              ).then((_) {
                setState(() {
                  _userData =
                      _fetchUserData(); // Refresh the user data after editing
                });
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final userData = snapshot.data!;
          final userName = userData['firstName'] ?? 'Unknown User';
          final userEmail = userData['email'] ?? 'No Email';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile image and name
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/images/profilePic.jpg'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(userEmail),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Reward points, travel trips, and bucket list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Reward Points', '50'),
                    _buildStatCard('Travel Trips', '0'),
                    _buildStatCard('Bucket List', '0'),
                  ],
                ),
                const SizedBox(height: 32),
                // Profile options
                Expanded(
                  child: ListView(
                    children: [
                      _buildOption(
                        'Trip Requests',
                        Icons.request_page,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripRequestScreen(
                                  userId: widget.userId), // Pass userId
                            ),
                          );
                        },
                      ),
                      _buildOption(
                        'Previous Trips',
                        Icons.history,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PreviousTripScreen(userId: widget.userId)),
                          );
                        },
                      ),
                      _buildOption(
                        'About Us',
                        Icons.info,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AboutUsScreen()),
                          );
                        },
                      ),
                      _buildOption(
                        'Logout',
                        Icons.logout,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildOption(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
