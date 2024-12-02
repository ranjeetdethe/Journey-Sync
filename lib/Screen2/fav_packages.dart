// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';

class FavoritePlacesScreen extends StatefulWidget {
  const FavoritePlacesScreen({super.key});

  @override
  _FavoritePlacesScreenState createState() => _FavoritePlacesScreenState();
}

class _FavoritePlacesScreenState extends State<FavoritePlacesScreen> {
  List<Place> _favoritePlaces = [
    Place(
      name: "Niladri Reservoir",
      location: "Tekergat, Sunamganj",
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Place(
      name: "Casa Las Tirtugas",
      location: "Av Damero, Mexico",
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Place(
      name: "Aonang Villa Resort",
      location: "Bastola, Islampur",
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Place(
      name: "Rangauti Resort",
      location: "Sylhet, Airport Road",
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Place(
      name: "Kachura Resort",
      location: "Vellima, Island",
      imageUrl: "assets/images/Rectangle 838.png",
    ),
    Place(
      name: "Shakardu Resort",
      location: "Shakardu, Pakistan",
      imageUrl: "assets/images/Rectangle 838.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Places"),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: _favoritePlaces.length,
        itemBuilder: (context, index) {
          Place place = _favoritePlaces[index];
          return _buildPlaceCard(place);
        },
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Image.asset(
                place.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  place.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.red,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class Place {
  final String name;
  final String location;
  final String imageUrl;

  Place({
    required this.name,
    required this.location,
    required this.imageUrl,
  });
}
