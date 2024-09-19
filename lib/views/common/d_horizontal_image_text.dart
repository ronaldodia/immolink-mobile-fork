import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class DHorizontalImageText extends StatelessWidget {
  const DHorizontalImageText({
    super.key,
    required this.image,
    required this.title,
    required this.textColor,
    this.backgroundColor = Colors.white,  // Fond blanc par défaut
    this.borderColor = Colors.grey,       // Couleur de la bordure par défaut
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final Color borderColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, left: TSizes.spaceBtwItems),
        child: Container(
          width: 110,  // Largeur réduite
          height: 0,
          padding: const EdgeInsets.only(left: 4, top: 0),  // Padding réduit en haut et en bas
          decoration: BoxDecoration(
            color: backgroundColor,  // Fond blanc
            borderRadius: BorderRadius.circular(4),  // Coins arrondis
            border: Border.all(color: borderColor, width: 1),  // Bordure grise
          ),
          child: Row(
            children: [
              /// Icône circulaire
              Container(
                width: 32,  // Largeur réduite à 32
                height: 32, // Hauteur réduite à 32
                padding: const EdgeInsets.all(4),  // Padding interne réduit
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: SvgPicture.network(
                    image,
                    height: 40,
                    width: 40,
                    colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),)
                    // colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn)
                  ),
                ),
              /// Texte
              const SizedBox(width: 4),  // Espacement réduit
              Expanded(  // Ajoute la flexibilité au texte pour éviter les débordements
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
