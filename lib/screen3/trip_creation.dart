import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_manager/ChatModule/chat_messages_page.dart';

class TripCreationPage extends StatefulWidget {
  final String userId;
  const TripCreationPage({super.key, required this.userId});

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

  bool _isLoading = false;

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
      setState(() {
        _isLoading = true;
      });
      try {
        final tripName = _tripNameController.text.trim();
        final from = _fromController.text.trim();
        final destination = _destinationController.text.trim();
        final date = _dateController.text.trim();
        final numberOfPeople = int.parse(_numberOfPeopleController.text.trim());
        final budget = double.parse(_budgetController.text.trim());

        DateTime parsedDate = DateTime.parse(date);

        DocumentReference tripRef =
            await FirebaseFirestore.instance.collection('trips').add({
          'tripName': tripName,
          'from': from,
          'destination': destination,
          'date': Timestamp.fromDate(parsedDate),
          'numberOfPeople': numberOfPeople,
          'budget': budget,
          'createdAt': FieldValue.serverTimestamp(),
          'creatorId': widget.userId,
        });

        await FirebaseFirestore.instance.collection('chat_groups').add({
          'tripId': tripRef.id,
          'tripName': tripName,
          'creatorId': widget.userId,
          'members': [widget.userId],
          'admins': [widget.userId],
          'maxMembers': numberOfPeople,
          'createdAt': Timestamp.now(),
        });

        _tripNameController.clear();
        _fromController.clear();
        _destinationController.clear();
        _dateController.clear();
        _numberOfPeopleController.clear();
        _budgetController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip Created Successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MessagesPage(userId: widget.userId),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating trip: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color.fromRGBO(255, 112, 41, 1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
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
                          decoration: _buildInputDecoration(
                              "Trip Name", Icons.drive_file_rename_outline),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter a trip name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _fromController,
                          decoration: _buildInputDecoration(
                              "From (Origin)", Icons.location_on_outlined),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter an origin location'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _destinationController,
                          decoration: _buildInputDecoration(
                              "Destination", Icons.location_on),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please enter a destination'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dateController,
                          decoration: _buildInputDecoration(
                              "Trip Date", Icons.calendar_today),
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
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Please select a date'
                              : null,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _numberOfPeopleController,
                          decoration: _buildInputDecoration(
                              "Number of People", Icons.people),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter the number of people';
                            int? number = int.tryParse(value);
                            if (number == null || number < 1)
                              return 'Enter at least 1 person';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _budgetController,
                          decoration: _buildInputDecoration(
                              "Budget (Approximate)",
                              Icons.currency_rupee_sharp),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter an approximate budget';
                            double? budget = double.tryParse(value);
                            if (budget == null || budget <= 0)
                              return 'Enter a valid budget greater than 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(255, 112, 41, 1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Create Trip',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
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
