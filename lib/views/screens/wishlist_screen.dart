import 'package:flutter/material.dart';
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
                  category: 'House',
                  price: 120000,
                  name: 'Modern Villa',
                  location: 'Nouadhibou, Mauritania',
                  onTap: (){
                    print('CARD');
                  },
                  onFavoriteTap: () {
                    print('FAVORITE BUTTON');
                  },
                ),
                // const SizedBox(height: 4,),
                PropertyCardWidget(
                  image: TImages.featured1,
                  isFeatured: true,
                  favoriteIcon: Icons.favorite,
                  status: 'sell',
                  category: 'House',
                  price: 120000,
                  name: 'Modern Villa',
                  location: 'Nouadhibou, Mauritania',
                  onTap: (){
                    print('CARD');
                  },
                  onFavoriteTap: () {
                    print('FAVORITE BUTTON');
                  },
                ),
                // const SizedBox(height: 4,),
                PropertyCardWidget(
                  image: TImages.featured1,
                  isFeatured: true,
                  favoriteIcon: Icons.favorite,
                  status: 'sell',
                  category: 'House',
                  price: 120000,
                  name: 'Modern Villa',
                  location: 'Nouadhibou, Mauritania',
                  onTap: (){
                    print('CARD');
                  },
                  onFavoriteTap: () {
                    print('FAVORITE BUTTON');
                  },
                ),
                // const SizedBox(height: 4,),
              ]
          )
      ),
    );
  }
}
