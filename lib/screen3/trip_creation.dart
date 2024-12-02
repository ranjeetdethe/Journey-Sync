import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TripCreationPage extends StatefulWidget {
  const TripCreationPage({super.key});

  @override
  _TripCreationPageState createState() => _TripCreationPageState();
}

class _TripCreationPageState extends State<TripCreationPage> {
  final _formKey = GlobalKey<FormState>();

  final _tripNameController = TextEditingController();
  final _fromController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _tripNameController.dispose();
    _fromController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _numberOfPeopleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _createTrip() async {
    if (_formKey.currentState!.validate()) {
      try {
        final tripName = _tripNameController.text.trim();
        final from = _fromController.text.trim();
        final destination = _destinationController.text.trim();
        final date = _dateController.text.trim();
        final numberOfPeople = int.parse(_numberOfPeopleController.text.trim());
        final budget = double.parse(_budgetController.text.trim());

        // Parse the date string into a DateTime object
        DateTime parsedDate = DateTime.parse(date);

        // Add trip data to Firebase Firestore
        await FirebaseFirestore.instance.collection('trips').add({
          'tripName': tripName,
          'from': from, // Origin location
          'destination': destination,
          'date': Timestamp.fromDate(parsedDate), // Store as Timestamp
          'numberOfPeople': numberOfPeople,
          'budget': budget,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Clear the text fields after trip creation
        _tripNameController.clear();
        _fromController.clear();
        _destinationController.clear();
        _dateController.clear();
        _numberOfPeopleController.clear();
        _budgetController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip Created Successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating trip: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _tripNameController,
                          decoration: const InputDecoration(
                            labelText: "Trip Name",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.drive_file_rename_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a trip name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _fromController,
                          decoration: const InputDecoration(
                            labelText: "From (Origin)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an origin location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            labelText: "Destination",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a destination';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: "Trip Date",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              _dateController.text =
                                  pickedDate.toString().substring(0, 10);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _numberOfPeopleController,
                          decoration: const InputDecoration(
                            labelText: "Number of People",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.people),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the number of people';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _budgetController,
                          decoration: const InputDecoration(
                            labelText: "Budget (Approximate)",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_rupee_sharp),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an approximate budget';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _createTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(255, 112, 41, 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            child: const Text(
                              'Create Trip',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
