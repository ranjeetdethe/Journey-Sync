import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId; // Accept userId to fetch data

  const EditProfileScreen({super.key, required this.userId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          final userData = userDoc.data() as Map<String, dynamic>;
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _mobileNumberController.text = userData['mobileNumber'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user data.')),
      );
    }
  }

  // Save profile changes
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'location': _locationController.text,
          'mobileNumber': _mobileNumberController.text,
          'email':
              _emailController.text, // Make sure to update the email as well
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: _saveProfile, // Save profile changes
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter first name'
                      : null,
                ),
                _buildTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter last name' : null,
                ),
                _buildTextField(
                  label: 'Location',
                  controller: _locationController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter location' : null,
                ),
                _buildTextField(
                  label: 'Mobile Number',
                  controller: _mobileNumberController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter mobile number'
                      : null,
                ),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  validator: (value) => value == null ||
                          value.isEmpty ||
                          !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)
                      ? 'Enter a valid email address'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function for creating TextFields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}
