import 'package:flutter/material.dart';
import 'package:travel_manager/screen3/view_package.dart';

class BrowsePackagesPage extends StatelessWidget {
  const BrowsePackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample package data
    final List<Map<String, dynamic>> packages = [
      // Sample package data for destinations near Pune

      {
        'packageName': 'Lonavala Weekend Gateway',
        'destination': 'Lonavala',
        'duration': '2 Days',
        'price': '₹ 1500',
        'rating': 4.2,
      },
      {
        'packageName': 'Historical Pune Experience',
        'destination': 'Pune City Tour',
        'duration': '1 Day',
        'price': '₹ 500',
        'rating': 4.5,
      },
      {
        'packageName': 'Adventure at Lavasa',
        'destination': 'Lavasa',
        'duration': '3 Days',
        'price': '₹ 2500',
        'rating': 4.6,
      },
      {
        'packageName': 'Cultural Retreat in Mahabaleshwar',
        'destination': 'Mahabaleshwar',
        'duration': '4 Days',
        'price': '₹ 4000',
        'rating': 4.7,
      },
      {
        'packageName': 'Hill Station Escape to Panchgani',
        'destination': 'Panchgani',
        'duration': '3 Days',
        'price': '₹ 3000',
        'rating': 4.4,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Packages'),
        backgroundColor: const Color.fromRGBO(255, 100, 33, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package['packageName'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Destination: ${package['destination']}'),
                    Text('Duration: ${package['duration']}'),
                    Text('Price: ${package['price']}'),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Color.fromRGBO(255, 100, 33, 1), size: 24),
                        const SizedBox(width: 4),
                        Text('${package['rating']}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewPackageScreen(
                              packageName: package['packageName'],
                              destination: package['destination'],
                              duration: package['duration'],
                              price: package['price'],
                              rating: package['rating'],
                            ),
                          ),
                        );
                      },
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
          },
        ),
      ),
    );
  }
}
