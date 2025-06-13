import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/config.dart';

class GalleryPanel extends StatefulWidget {
  final List gallery;
  final int initialIndex;

  const GalleryPanel(
      {super.key, required this.gallery, required this.initialIndex});

  @override
  _GalleryPanelState createState() => _GalleryPanelState();
}

class _GalleryPanelState extends State<GalleryPanel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.gallery.length,
            itemBuilder: (context, index) {
              final image = widget.gallery[index];
              // print('URL IMAGE: ${image.original}');
              return Image.network(
                image.original,
                fit: BoxFit.contain,
              );
            },
          ),
          // Bouton de fermeture superposé en haut à droite
          Positioned(
            top: 30, // Ajuste selon tes besoins
            right: 20, // Ajuste selon tes besoins
            child: IconButton(
              icon: const Icon(Icons.close, size: 30, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
