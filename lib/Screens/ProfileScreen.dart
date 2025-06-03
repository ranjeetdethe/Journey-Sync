import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_manager/Screen2/home_screen.dart';
import 'package:travel_manager/Screens/editProfile.dart';
import 'package:travel_manager/Screens/loginScreen.dart';
import 'package:travel_manager/agency/agency_dashboard.dart';
import 'package:travel_manager/screen3/about_us.dart';
import 'package:travel_manager/screen3/previous_trips.dart';
import 'package:travel_manager/screen3/trip_requests.dart';

// Reward Points Screen
class RewardPointsScreen extends StatelessWidget {
  final String userId;

  const RewardPointsScreen({super.key, required this.userId});

  Future<int> _calculateRewardPoints() async {
    try {
      QuerySnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Calculate points: 10 points per completed trip
      int completedTrips = tripSnapshot.docs.length;
      return completedTrips * 10;
    } catch (e) {
      throw 'Failed to fetch reward points: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Points'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<int>(
        future: _calculateRewardPoints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final points = snapshot.data ?? 0;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your Reward Points',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '$points Points',
                  style: const TextStyle(fontSize: 32, color: Colors.green),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Earned from your completed trips',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Redeem your points for discounts on future trips!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class BucketListScreen extends StatefulWidget {
  final String userId;

  const BucketListScreen({super.key, required this.userId});

  @override
  _BucketListScreenState createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  late Future<List<String>> _userBucketListFuture;
  List<Map<String, String>> _popularDestinations = [];
  List<Map<String, String>> _filteredDestinations = [];
  bool _isLoadingPopularDestinations = true;
  bool _isActionLoading = false; // For add/remove loading state
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userBucketListFuture = _fetchUserBucketList();
    _fetchPopularDestinations();
    _searchController.addListener(_filterDestinations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> _fetchUserBucketList() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        return List<String>.from(userDoc['bucketList'] ?? []);
      }
      return [];
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch bucket list: $e';
      });
      return [];
    }
  }

  Future<void> _fetchPopularDestinations() async {
    try {
      setState(() {
        _isLoadingPopularDestinations = true;
        _errorMessage = null;
      });

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('popular_destinations')
          .get();

      setState(() {
        _popularDestinations = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] as String,
            'image': data['imageUrl'] as String,
          };
        }).toList();
        _filteredDestinations = _popularDestinations;
        _isLoadingPopularDestinations = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch popular destinations: $e';
        _isLoadingPopularDestinations = false;
      });
    }
  }

  void _filterDestinations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDestinations = _popularDestinations
          .where((destination) =>
              destination['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _addToBucketList(String destination) async {
    setState(() {
      _isActionLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'bucketList': FieldValue.arrayUnion([destination]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$destination added to your bucket list!')),
      );
      setState(() {
        _userBucketListFuture = _fetchUserBucketList();
        _isActionLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to bucket list: $e')),
      );
      setState(() {
        _isActionLoading = false;
      });
    }
  }

  Future<void> _removeFromBucketList(String destination) async {
    setState(() {
      _isActionLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'bucketList': FieldValue.arrayRemove([destination]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$destination removed from your bucket list!')),
      );
      setState(() {
        _userBucketListFuture = _fetchUserBucketList();
        _isActionLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from bucket list: $e')),
      );
      setState(() {
        _isActionLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bucket List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _userBucketListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snapshot.error}'),
                  TextButton(
                    onPressed: () => setState(() {
                      _userBucketListFuture = _fetchUserBucketList();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userBucketList = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Popular Destinations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const Text(
                'Your Bucket List',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              userBucketList.isEmpty
                  ? const Center(child: Text('Your bucket list is empty.'))
                  : Column(
                      children: userBucketList.map((destination) {
                        return ListTile(
                          title: Text(destination),
                          trailing: _isActionLoading
                              ? const CircularProgressIndicator()
                              : IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeFromBucketList(destination),
                                ),
                        );
                      }).toList(),
                    ),
            ],
          );
        },
      ),
    );
  }
}

// Updated ProfileScreen
class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userData;
  late Future<int> _rewardPoints;
  late Future<int> _bucketListCount;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
    _rewardPoints = _calculateRewardPoints();
    _bucketListCount = _fetchBucketListCount();
  }

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

  Future<int> _calculateRewardPoints() async {
    try {
      QuerySnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('userId', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'completed')
          .get();
      return tripSnapshot.docs.length * 10; // 10 points per completed trip
    } catch (e) {
      return 0;
    }
  }

  Future<int> _fetchBucketListCount() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        return (userDoc['bucketList'] as List<dynamic>?)?.length ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
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
                  _userData = _fetchUserData();
                  _rewardPoints = _calculateRewardPoints();
                  _bucketListCount = _fetchBucketListCount();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FutureBuilder<int>(
                      future: _rewardPoints,
                      builder: (context, snapshot) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RewardPointsScreen(userId: widget.userId),
                              ),
                            );
                          },
                          child: _buildStatCard(
                            'Reward Points',
                            snapshot.data?.toString() ?? '0',
                          ),
                        );
                      },
                    ),
                    _buildStatCard('Travel Trips', '0'),
                    FutureBuilder<int>(
                      future: _bucketListCount,
                      builder: (context, snapshot) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BucketListScreen(userId: widget.userId),
                              ),
                            );
                          },
                          child: _buildStatCard(
                            'Bucket List',
                            snapshot.data?.toString() ?? '0',
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                              builder: (context) =>
                                  TripRequestScreen(userId: widget.userId),
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
                                  PreviousTripScreen(userId: widget.userId),
                            ),
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
                              builder: (context) => const AboutUsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildOption(
                        'Continue as Agency',
                        Icons.person,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AgencyDashboardScreen(),
                            ),
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
                              builder: (context) => const LoginPage(),
                            ),
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
