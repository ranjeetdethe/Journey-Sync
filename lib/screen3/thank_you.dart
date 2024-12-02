import 'package:flutter/material.dart';

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the previous screen
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thank You Text
              const Text(
                'Thank You Incubators Family',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8), // Small spacing

              // Additional Thank You Message

              const SizedBox(height: 20), // Spacing between text and images

              // Images Grid
              Wrap(
                spacing: screenWidth * 0.05,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildImageCard(
                      'assets/images/shashisir.jpg', 'Shashi Sir', screenWidth),
                  _buildImageCard(
                      'assets/images/sachinSir.jpg', 'Sachin Sir', screenWidth),
                  _buildImageCard(
                      'assets/images/akshaysir.jpg', 'Akshay Sir', screenWidth),
                  _buildImageCard(
                      'assets/images/pramodsir.jpg', 'Pramod Sir', screenWidth),
                ],
              ),
              const SizedBox(height: 20), // Spacing between images and names

              // Names Column
              const Text(
                'Mentors:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Shiv Dada  ', style: TextStyle(fontSize: 20)),
              const Text('Prajwal Dada', style: TextStyle(fontSize: 20)),
              const Text('Rahul Dada', style: TextStyle(fontSize: 20)),
              const Text('Partik Dada', style: TextStyle(fontSize: 20)),

              const SizedBox(
                height: 20,
              ),
              const Text(
                'Thank You for your support and guidance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath, String name, double screenWidth) {
    final cardSize =
        screenWidth * 0.4; // Adjust card size based on screen width

    return SizedBox(
      width: cardSize,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: cardSize,
              height: cardSize,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
