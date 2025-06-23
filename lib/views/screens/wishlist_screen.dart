import 'package:flutter/material.dart';
import 'package:immolink_mobile/models/Category.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';
import 'package:immolink_mobile/views/common/d_search_bar_widget.dart';
import 'package:immolink_mobile/views/common/property_card_widget.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Wishlist'), backgroundColor: Colors.white,),
      body:  SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PropertyCardWidget(
                  image: TImages.featured1,
                  isFeatured: true,
                  favoriteIcon: Icons.favorite,
                  status: 'sell',
                  category: Category(
                    id: 1,
                    nameFr: 'Maison',
                    nameAr: 'منزل',
                    nameEn: 'House',
                    slug: 'house',
                  ),
                  price: 120000,
                  name: 'Modern Villa',
                  location: 'Nouadhibou, Mauritania',
                  onTap: () {
                    print('CARD');
                  },
                  onFavoriteTap: () {
                    print('FAVORITE BUTTON');
                  },
                ),
                const SizedBox(height: 4),
                PropertyCardWidget(
                  image: TImages.featured1,
                  isFeatured: true,
                  favoriteIcon: Icons.favorite,
                  status: 'sell',
                  category: Category(
                    id: 2,
                    nameFr: 'Appartement',
                    nameAr: 'شقة',
                    nameEn: 'Apartment',
                    slug: 'apartment',
                  ),
                  price: 85000,
                  name: 'Luxury Apartment',
                  location: 'Nouakchott, Mauritania',
                  onTap: () {
                    print('CARD');
                  },
                  onFavoriteTap: () {
                    print('FAVORITE BUTTON');
                  },
                ),
                const SizedBox(height: 4),
                // const SizedBox(height: 4,),
                PropertyCardWidget(
                  image: TImages.featured1,
                  isFeatured: true,
                  favoriteIcon: Icons.favorite,
                  status: 'sell',
                  category: Category(
                    id: 3,
                    nameFr: 'Bureau',
                    nameAr: 'مكتب',
                    nameEn: 'Office',
                    slug: 'office',
                  ),
                  price: 150000,
                  name: 'Office Space',
                  location: 'Nouakchott, Mauritania',
                  onTap: () {
                    print('CARD');
                  },
                  onFavoriteTap: () {
                    print('FAVORITE BUTTON');
                  },
                ),
              ]
          )
      ),
    );
  }
}