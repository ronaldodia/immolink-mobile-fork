import 'package:flutter/material.dart';

class FilterResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> properties;

  const FilterResultScreen({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Results'),
      ),
      body: ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return ListTile(
            leading: property['image'] != null
                ? Image.network(property['image'], fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported),
            title: Text(property['name_fr'] ?? 'Nom indisponible'),
            subtitle: Text('${property['price']} USD'),
          );
        },
      ),
    );
  }
}
