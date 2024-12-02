import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_manager/Screen2/notification_screen.dart';
import 'package:travel_manager/Screen2/sender_list.dart';
import 'package:travel_manager/Screen2/view_all.dart';
import 'package:travel_manager/Screens/ProfileScreen.dart';
import 'package:travel_manager/screen3/join_trip.dart';
import 'package:travel_manager/screen3/trip_creation.dart';

class MyHomePage extends StatefulWidget {
  final String userId; // Pass user ID to the home page
  const MyHomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  late final List<Widget> _pages = [
    HomePageContent(userId: widget.userId),
    const TripCreationPage(),
    const TripListPage(),
    MessagingScreen(),
    ProfileScreen(userId: widget.userId),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create Trip"),
          BottomNavigationBarItem(
              icon: Icon(Icons.join_left_sharp), label: "Join Trip"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final String userId;
  const HomePageContent({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 20.0, top: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const NotificationScreen();
                    }));
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(247, 247, 249, 1),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.grey),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ProfileScreen(userId: userId);
                    }));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromRGBO(247, 247, 249, 1),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 15,
                          backgroundImage:
                              AssetImage('assets/image2/Ellipse 22.png'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Ranjeet",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: const Color.fromRGBO(27, 30, 40, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Header Text
            Text(
              "Discover the wonders",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Text(
                  " ",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                Text(
                  " Together!",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    color: const Color.fromRGBO(255, 112, 41, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Best Destination Header
            Row(
              children: [
                Text(
                  "Best Destination",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: const Color.fromRGBO(27, 30, 40, 1),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BrowsePackagesPage()),
                    );
                  },
                  child: Text(
                    "View all",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: const Color.fromRGBO(255, 100, 33, 1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Grid View for Cards
            GridView.builder(
              shrinkWrap:
                  true, // Allows the GridView to be inside a SingleChildScrollView
              physics:
                  const NeverScrollableScrollPhysics(), // Disables scrolling within GridView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 16.0, // Spacing between columns
                mainAxisSpacing: 16.0, // Spacing between rows
                childAspectRatio: 0.7, // Adjust card width/height ratio
              ),
              itemCount: 10, // Number of items in the grid
              itemBuilder: (context, index) {
                return DestinationCard(
                  imagePath: destinations[index]["imagePath"],
                  title: destinations[index]["title"],
                  rating: destinations[index]["rating"],
                  location: destinations[index]["location"],
                  reviews: destinations[index]["reviews"],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final double rating;
  final String location;
  final String reviews;

  const DestinationCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.rating,
    required this.location,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detail screen on card tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(
              title: title,
              imagePath: imagePath,
              rating: rating,
              location: location,
              reviews: reviews,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: SizedBox(
          width: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  imagePath,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.yellow[700]),
                        const SizedBox(width: 4),
                        Text(
                          "$rating",
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const Spacer(),
                        const CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(""),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reviews,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location,
                      style:
                          GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DestinationDetailScreen extends StatelessWidget {
  final String title;
  final String imagePath;
  final double rating;
  final String location;
  final String reviews;

  const DestinationDetailScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.location,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(imagePath),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text("Rating: $rating"),
            const SizedBox(height: 8),
            Text("Location: $location"),
            const SizedBox(height: 8),
            Text("Reviews: $reviews"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 100, 33, 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'View Package',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for destinations data (You can replace it with actual data)
final List<Map<String, dynamic>> destinations = [
  {
    "imagePath": "assets/des_img/Image 2.png",
    "title": "Plus Valley",
    "rating": 4.7,
    "location": "Pune",
    "reviews": "+50",
  },
  {
    "imagePath": "assets/des_img/Image 9.png",
    "title": "Karjat",
    "rating": 4.7,
    "location": "Karjat",
    "reviews": "+65",
  },
  {
    "imagePath": "assets/des_img/Image 11.png",
    "title": "Diveagar",
    "rating": 4.9,
    "location": "Kokan",
    "reviews": "+90",
  },
  {
    "imagePath": "assets/des_img/Image 4.png",
    "title": "Sinhagad Fort",
    "rating": 4.8,
    "location": "Pune",
    "reviews": "+100",
  },
  {
    "imagePath": "assets/des_img/Image 13.png",
    "title": "Tamini Ghat",
    "rating": 4.6,
    "location": "Pune",
    "reviews": "+30",
  },

  {
    "imagePath": "assets/des_img/Image 5.png",
    "title": "Lonavala",
    "rating": 4.5,
    "location": "Pune",
    "reviews": "+70",
  },
  {
    "imagePath": "assets/des_img/Image 6.png",
    "title": "Raigad",
    "rating": 4.7,
    "location": "Raigad",
    "reviews": "+40",
  },
  {
    "imagePath": "assets/des_img/Image 10.png",
    "title": "Bhimashankar",
    "rating": 4.6,
    "location": "Pune",
    "reviews": "+60",
  },

  {
    "imagePath": "assets/des_img/Image 8.png",
    "title": "Khandala",
    "rating": 4.4,
    "location": "Pune",
    "reviews": "+55",
  },
  {
    "imagePath": "assets/des_img/Image 7.png",
    "title": "Rajgad",
    "rating": 4.6,
    "location": "Rajgad",
    "reviews": "+80",
  },
  // Add more destinations here
];
