// import 'package:flutter/material.dart';

// class TripCreationPage extends StatefulWidget {
//   const TripCreationPage({super.key});

//   @override
//   _TripCreationPageState createState() => _TripCreationPageState();
// }

// class _TripCreationPageState extends State<TripCreationPage> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for input fields
//   final _tripNameController = TextEditingController();
//   final _destinationController = TextEditingController();
//   final _dateController = TextEditingController();
//   final _numberOfPeopleController = TextEditingController();
//   final _budgetController = TextEditingController();

//   @override
//   void dispose() {
//     _tripNameController.dispose();
//     _destinationController.dispose();
//     _dateController.dispose();
//     _numberOfPeopleController.dispose();
//     _budgetController.dispose();
//     super.dispose();
//   }

//   void _createTrip() {
//     if (_formKey.currentState!.validate()) {
//       // Process to create trip or navigate further
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Trip Created Successfully!')),
//       );
//       // Here you can add logic to save the trip details
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Trip'),
//         backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Trip Details",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromRGBO(255, 112, 41, 1),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _tripNameController,
//                 decoration: const InputDecoration(
//                   labelText: "Trip Name",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.drive_file_rename_outline),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a trip name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _destinationController,
//                 decoration: const InputDecoration(
//                   labelText: "Destination",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.location_on),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a destination';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _dateController,
//                 decoration: const InputDecoration(
//                   labelText: "Trip Date",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.calendar_today),
//                 ),
//                 onTap: () async {
//                   DateTime? pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime(2101),
//                   );
//                   if (pickedDate != null) {
//                     _dateController.text =
//                         pickedDate.toString().substring(0, 10);
//                   }
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please select a date';
//                   }
//                   return null;
//                 },
//                 readOnly: true,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _numberOfPeopleController,
//                 decoration: const InputDecoration(
//                   labelText: "Number of People",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.people),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter the number of people';
//                   }
//                   if (int.tryParse(value) == null) {
//                     return 'Enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _budgetController,
//                 decoration: const InputDecoration(
//                   labelText: "Budget (Approximate)",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.attach_money),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an approximate budget';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Enter a valid amount';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _createTrip,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromRGBO(255, 112, 41, 1),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 50, vertical: 15),
//                   ),
//                   child: const Text(
//                     'Create Trip',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
