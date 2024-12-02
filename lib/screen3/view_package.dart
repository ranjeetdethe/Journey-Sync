import 'package:flutter/material.dart';

class ViewPackageScreen extends StatelessWidget {
  final String packageName;
  final String destination;
  final String duration;
  final String price;
  final double rating;

  const ViewPackageScreen({
    super.key,
    required this.packageName,
    required this.destination,
    required this.duration,
    required this.price,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(packageName),
        backgroundColor: const Color.fromRGBO(255, 100, 33, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              packageName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(255, 100, 33, 1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Destination: $destination',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Duration: $duration',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Price: $price',
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              children: [
                const Icon(Icons.star,
                    color: Color.fromRGBO(255, 100, 33, 1), size: 24),
                const SizedBox(width: 4),
                Text(
                  '$rating',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle the action to book or inquire about the package
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking request sent!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 100, 33, 1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
