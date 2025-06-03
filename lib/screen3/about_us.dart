import 'package:flutter/material.dart';
import 'package:social_media_buttons/social_media_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title section
              const Center(
                child: Text(
                  'Welcome to Journey Sync',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description about the app or organization
              const Text(
                'We are dedicated to providing amazing experiences for our users. '
                'Our app connects people with exciting trips, experiences, and much more. We strive to make your life '
                'easier and more enjoyable with the services we provide.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Contact Information section
              const Text(
                'Developed By:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Name: Abhishek Dere',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Phone: 9325128750',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              const Text(
                'Name: Aryan Kulkarani',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Phone: 8925128450',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              const Text(
                'Name: Saniket Kadam',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Phone: 8767994375',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Name: Dinesh Dukare',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Phone: 899674799',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Name: Paurnima Deshmukh',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Phone: 899674799',
                style: TextStyle(fontSize: 16),
              ),

              // Social Media links section
              const Text(
                'Follow Us:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook),
                    onPressed: () {
                      _launchURL('https://www.facebook.com/yourprofile');
                    },
                    color: Colors.blue,
                    iconSize: 30,
                  ),
                  IconButton(
                    icon: const Icon(SocialMediaIcons.twitter),
                    onPressed: () {
                      _launchURL('https://twitter.com/yourprofile');
                    },
                    color: Colors.blue,
                    iconSize: 30,
                  ),
                  IconButton(
                    icon: const Icon(SocialMediaIcons.instagram),
                    onPressed: () {
                      _launchURL('https://www.instagram.com/yourprofile');
                    },
                    color: Colors.purple,
                    iconSize: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     // Navigate to ThankYouScreen
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => ThankYouPage(),
                  //       ),
                  //     );
                  //   },
                  //   child: Image.asset(
                  //     'assets/images/logo.jpg',
                  //     width: 40,
                  //     height: 40,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),

              // Footer section
              const Divider(),
              const Center(
                child: Text(
                  '© 2024 Journey Sync. All Rights Reserved.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to launch the URL for social media
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// A placeholder for ThankYouScreen
class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Thanks'),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Thank You Core2web Family',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'We are grateful for your support and guidance!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
