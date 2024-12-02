import 'package:flutter/material.dart';

class PopularPackagesScreen extends StatefulWidget {
  const PopularPackagesScreen({super.key});

  @override
  _PopularPackagesScreenState createState() => _PopularPackagesScreenState();
}

class _PopularPackagesScreenState extends State<PopularPackagesScreen> {
  final List<Package> _popularPackages = [
    Package(
      name: "Niladri Reservoir",
      dates: "16 July-28 July",
      price: "\$789",
      rating: 4.8,
      joined: 24,
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Package(
      name: "Niladri Reservoir",
      dates: "16 July-28 July",
      price: "\$789",
      rating: 4.8,
      joined: 24,
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Package(
      name: "Niladri Reservoir",
      dates: "16 July-28 July",
      price: "\$789",
      rating: 4.8,
      joined: 24,
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Package(
      name: "Niladri Reservoir",
      dates: "16 July-28 July",
      price: "\$789",
      rating: 4.8,
      joined: 24,
      imageUrl: "assets/images/Rectangle 838.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Popular Packages"),
      ),
      body: Column(
        children: [
          _buildTitle(),
          Expanded(
            child: ListView.builder(
              itemCount: _popularPackages.length,
              itemBuilder: (context, index) {
                Package package = _popularPackages[index];
                return _buildPackageCard(package);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        "All Popular Trip Packages",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                package.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              package.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 4),
                Text(package.dates),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star),
                const SizedBox(width: 4),
                Text(package.rating.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://www.pixelstalk.net/wp-content/uploads/images6/Travel-HD-Wallpaper-Free-download.jpg"),
                ),
                const SizedBox(width: 4),
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://www.pixelstalk.net/wp-content/uploads/images6/Travel-HD-Wallpaper-Free-download.jpg"),
                ),
                const SizedBox(width: 4),
                Text("${package.joined} People Joined"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  package.price,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle the booking functionality here
                  },
                  child: const Text("Book Now"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Package {
  final String name;
  final String dates;
  final String price;
  final double rating;
  final int joined;
  final String imageUrl;

  Package({
    required this.name,
    required this.dates,
    required this.price,
    required this.rating,
    required this.joined,
    required this.imageUrl,
  });
}
