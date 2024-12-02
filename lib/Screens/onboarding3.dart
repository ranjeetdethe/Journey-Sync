import 'package:flutter/material.dart';
import 'package:travel_manager/Screens/loginScreen.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/onboard_3.png'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content overlay
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.03,
            ),
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate directly to the login screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'People don\'t take',
                      style: TextStyle(
                        fontSize: size.width * 0.08, // Responsive font size
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      children: [
                        Text(
                          'trips, trips take',
                          style: TextStyle(
                            fontSize: size.width * 0.08, // Responsive font size
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          ' people',
                          style: TextStyle(
                            fontSize: size.width * 0.09, // Responsive font size
                            fontWeight: FontWeight.w900,
                            color: const Color.fromRGBO(255, 100, 33, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                    Text(
                      'To get the best of your adventure you just need to leave and go where you like. We are waiting for you.',
                      style: TextStyle(
                        fontSize: size.width * 0.04, // Responsive font size
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.05),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the login screen
                        Navigator.pushReplacement(
                          context,
                          _createRoute(const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 100, 33, 1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.4,
                          vertical: size.height * 0.02,
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: size.width * 0.045, // Responsive font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIndicator(size, false),
                        SizedBox(width: size.width * 0.02),
                        _buildIndicator(size, false),
                        SizedBox(width: size.width * 0.02),
                        _buildIndicator(size, true),
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to build an indicator
  Widget _buildIndicator(Size size, bool isActive) {
    return Container(
      width: size.width * 0.02,
      height: size.width * 0.02,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
      ),
    );
  }

  // Custom Route with Slide Transition
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide in from the right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
