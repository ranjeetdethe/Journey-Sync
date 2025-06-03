import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_manager/Screen2/chatlist.dart';
import 'package:travel_manager/Screen2/notification_screen.dart';
import 'package:travel_manager/Screen2/view_all.dart';
import 'package:travel_manager/Screens/ProfileScreen.dart';
import 'package:travel_manager/screen3/join_trip.dart';
import 'package:travel_manager/screen3/trip_creation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class MyHomePage extends StatefulWidget {
  final String userId;
  const MyHomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _pages = [
    HomePageContent(userId: widget.userId),
    TripCreationPage(userId: widget.userId),
    TripListPage(userId: widget.userId),
    ChatListScreen(userId: widget.userId),
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
        selectedItemColor: const Color.fromRGBO(255, 112, 41, 1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Create Trip"),
          BottomNavigationBarItem(
              icon: Icon(Icons.join_left_sharp), label: "Join Trip"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final String userId;
  const HomePageContent({super.key, required this.userId});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String? _selectedLocation;

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color.fromRGBO(255, 112, 41, 1),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 20.0, top: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('destinations')
                        .orderBy('createdAt', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text(
                          "Select a location for weather",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: const Color.fromRGBO(27, 30, 40, 1),
                          ),
                        );
                      }
                      final dest = snapshot.data!.docs.first.data()
                          as Map<String, dynamic>;
                      final location = dest['location'] ?? 'Unknown';
                      return Text(
                        "",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color.fromRGBO(27, 30, 40, 1),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ProfileScreen(userId: widget.userId);
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
              Text(
                "Current Weather",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: const Color.fromRGBO(27, 30, 40, 1),
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('destinations')
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    developer.log('Firestore error: ${snapshot.error}');
                    return const WeatherWidget(location: "Unknown");
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    developer.log('No data or empty snapshot');
                    return const WeatherWidget(location: "Unknown");
                  }
                  final destinations = snapshot.data!.docs;
                  // Deduplicate locations from Firestore
                  final uniqueLocations = <String>{};
                  for (var doc in destinations) {
                    final dest = doc.data() as Map<String, dynamic>;
                    final location = dest['location'] ?? 'Unknown';
                    uniqueLocations.add(location);
                  }
                  // Add hardcoded locations as fallback
                  const additionalLocations = [
                    "Mumbai, India",
                    "Delhi, India",
                    "Bangalore, India",
                    "Chennai, India",
                    "Kolkata, India",
                    "Hyderabad, India",
                    "Jaipur, India",
                    "Goa, India",
                    "Agra, India",
                    "Varanasi, India"
                  ];
                  uniqueLocations.addAll(additionalLocations);
                  developer.log('Unique locations: $uniqueLocations');

                  // Convert to DropdownMenuItem list
                  final dropdownItems = uniqueLocations.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(
                        location,
                        style: GoogleFonts.inter(fontSize: 16),
                      ),
                    );
                  }).toList();

                  // Ensure _selectedLocation is valid
                  if (_selectedLocation == null ||
                      !uniqueLocations.contains(_selectedLocation)) {
                    _selectedLocation = uniqueLocations.isNotEmpty
                        ? uniqueLocations.first
                        : "Mumbai, India"; // Default fallback
                    developer
                        .log('Selected location set to: $_selectedLocation');
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        value: _selectedLocation,
                        items: dropdownItems,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLocation = newValue!;
                            developer.log('New location selected: $newValue');
                          });
                        },
                        isExpanded: true,
                        underline: Container(
                          height: 1,
                          color: const Color.fromRGBO(255, 112, 41, 1),
                        ),
                        hint: Text(
                          "Select a location",
                          style: GoogleFonts.inter(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      WeatherWidget(location: _selectedLocation ?? "Unknown"),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Featured Destination Images",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: const Color.fromRGBO(27, 30, 40, 1),
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('destinations')
                    .orderBy('createdAt', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    developer.log('Featured images error: ${snapshot.error}');
                    return Center(
                      child: Text(
                        'Error loading images.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    developer.log('No featured images data');
                    return Center(
                      child: Text(
                        'No featured images available.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  final dest =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final imageUrls =
                      (dest['imageUrls'] as List<dynamic>?)?.cast<String>() ??
                          [];
                  if (imageUrls.isEmpty) {
                    developer.log('No image URLs in data');
                    return Center(
                      child: Text(
                        'No images available for this destination.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DestinationDetailScreen(
                                  title: dest['title'] ?? 'Unknown',
                                  imageUrls: imageUrls,
                                  rating:
                                      (dest['rating'] as num?)?.toDouble() ??
                                          0.0,
                                  location: dest['location'] ?? 'Unknown',
                                  reviews: dest['reviews'] ?? '+0',
                                  description: dest['description'] ?? '',
                                  price: (dest['price'] as num?)?.toDouble() ??
                                      0.0,
                                  category: dest['category'] ?? 'Unknown',
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrls[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                cacheHeight: 240,
                                cacheWidth: 240,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color.fromRGBO(255, 112, 41, 1),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/des_img/Image 2.png',
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('destinations')
                    .orderBy('createdAt', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    developer.log('Best destinations error: ${snapshot.error}');
                    return Center(
                      child: Text(
                        'Error loading destinations.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    developer.log('No best destinations data');
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 112, 41, 1),
                      ),
                    );
                  }
                  final destinations = snapshot.data!.docs;
                  if (destinations.isEmpty) {
                    developer.log('Best destinations empty');
                    return Center(
                      child: Text(
                        'No destinations available.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final dest =
                          destinations[index].data() as Map<String, dynamic>;
                      final imageUrls = (dest['imageUrls'] as List<dynamic>?)
                              ?.cast<String>() ??
                          [];
                      return DestinationCard(
                        imageUrl: imageUrls.isNotEmpty
                            ? imageUrls.first
                            : 'assets/des_img/Image 2.png',
                        title: dest['title'] ?? 'Unknown',
                        rating: (dest['rating'] as num?)?.toDouble() ?? 0.0,
                        location: dest['location'] ?? 'Unknown',
                        reviews: dest['reviews'] ?? '+0',
                        price: (dest['price'] as num?)?.toDouble() ?? 0.0,
                        category: dest['category'] ?? 'Unknown',
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherWidget extends StatefulWidget {
  final String location;
  const WeatherWidget({super.key, required this.location});

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void didUpdateWidget(covariant WeatherWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coordinates = await _getCoordinates(widget.location);
      if (coordinates == null) {
        developer.log('Coordinates not found for: ${widget.location}');
        setState(() {
          _errorMessage = 'Unable to find location';
          _isLoading = false;
        });
        return;
      }

      final latitude = coordinates['latitude'];
      final longitude = coordinates['longitude'];
      developer.log('Fetching weather for lat: $latitude, lon: $longitude');

      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = data['current_weather'];
          _isLoading = false;
        });
      } else {
        developer.log('Weather API error: ${response.statusCode}');
        setState(() {
          _errorMessage =
              'Failed to load weather data (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Weather fetch error: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, double>?> _getCoordinates(String location) async {
    if (location == "Unknown") return null;
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(location)}&format=json&limit=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'TravelManagerApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'latitude': double.parse(data[0]['lat']),
            'longitude': double.parse(data[0]['lon']),
          };
        }
      }
    } catch (e) {
      developer.log('Coordinate fetch error: $e');
    }
    return null;
  }

  String _getWeatherCondition(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  IconData _getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.blur_on;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return Icons.umbrella;
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit;
      case 95:
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(255, 112, 41, 1),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        TextButton(
                          onPressed: _fetchWeather,
                          child: Text(
                            'Retry',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color.fromRGBO(255, 112, 41, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.location,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Color.fromRGBO(27, 30, 40, 1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_weatherData!['temperature']}°C',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Color.fromRGBO(255, 112, 41, 1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getWeatherCondition(
                                _weatherData!['weathercode'] as int),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _getWeatherIcon(_weatherData!['weathercode'] as int),
                        size: 48,
                        color: Color.fromRGBO(255, 112, 41, 1),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final String location;
  final String reviews;
  final double price;
  final String category;

  const DestinationCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.location,
    required this.reviews,
    required this.price,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DestinationDetailScreen(
              title: title,
              imageUrls: [imageUrl],
              rating: rating,
              location: location,
              reviews: reviews,
              description: '',
              price: price,
              category: category,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheHeight: 200,
                  cacheWidth: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 112, 41, 1),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/des_img/Image 2.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.yellow[700]),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      const Spacer(),
                      const CircleAvatar(
                        radius: 10,
                        backgroundImage:
                            AssetImage('assets/image2/Ellipse 22.png'),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reviews,
                        style: GoogleFonts.inter(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$location • $category',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}/Person',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color.fromRGBO(255, 112, 41, 1),
                    ),
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

class DestinationDetailScreen extends StatelessWidget {
  final String title;
  final List<String> imageUrls;
  final double rating;
  final String location;
  final String reviews;
  final String description;
  final double price;
  final String category;

  const DestinationDetailScreen({
    super.key,
    required this.title,
    required this.imageUrls,
    required this.rating,
    required this.location,
    required this.reviews,
    required this.description,
    required this.price,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  imageUrls.isNotEmpty
                      ? imageUrls.first
                      : 'assets/des_img/Image 2.png',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  cacheHeight: 600,
                  cacheWidth: 600,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color.fromRGBO(255, 112, 41, 1),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/des_img/Image 2.png',
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Text(
                    "Details",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: const Color.fromRGBO(27, 30, 40, 1),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$location • $category',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            AssetImage('assets/image2/Ellipse 22.png'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[700], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "${rating.toStringAsFixed(1)} (${reviews.replaceAll('+', '')})",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: const Color.fromRGBO(27, 30, 40, 1),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${price.toStringAsFixed(2)}/Person',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color.fromRGBO(255, 112, 41, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrls[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              cacheHeight: 160,
                              cacheWidth: 160,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color.fromRGBO(255, 112, 41, 1),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/des_img/Image 2.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "About Destination",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: const Color.fromRGBO(27, 30, 40, 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description.isEmpty
                        ? 'No description available.'
                        : description,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Booking initiated for $title")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
