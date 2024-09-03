import 'package:flutter/material.dart';

class AgencyCardWidget extends StatelessWidget {
  final String image;
  final String name;
  final int properties;
  final double rating;

  const AgencyCardWidget({
    super.key,
    required this.image,
    required this.name,
    required this.properties,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'agence
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            // Nom de l'agence
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            // Nombre de propriétés
            Text(
              '$properties properties',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            // Évaluations
            Row(
              children: [
                // Générer 5 étoiles
                ...List.generate(5, (index) {
                  // Si l'index est inférieur à la note, on affiche une étoile pleine, sinon une étoile vide
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
                const SizedBox(width: 8), // Espacement entre les étoiles et le texte
                // Afficher la note
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}