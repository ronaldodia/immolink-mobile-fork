import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immolink_mobile/controllers/articles/article_form_controller.dart';
import 'package:immolink_mobile/controllers/communes/commune_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/utils/config.dart';

class CreateArticleScreen extends StatefulWidget {
  const CreateArticleScreen({super.key});

  @override
  State<CreateArticleScreen> createState() => _CreateArticleScreenState();
}

class _CreateArticleScreenState extends State<CreateArticleScreen> {
  final ArticleFormController articleController =
      Get.put(ArticleFormController());
  final CategoryController categoryController = Get.put(CategoryController());
  final CommuneController communeController = Get.put(CommuneController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'fr';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une annonce'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        return Stepper(
          type: StepperType.vertical,
          currentStep: articleController.currentStep.value,
          onStepContinue: () {
            if (articleController.currentStep.value < 4) {
              articleController.currentStep.value++;
            } else {
              if (_formKey.currentState!.validate()) {
                articleController.submitForm();
              }
            }
          },
          onStepCancel: () {
            if (articleController.currentStep.value > 0) {
              articleController.currentStep.value--;
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(articleController.currentStep.value == 4
                      ? 'Valider'
                      : 'Suivant'),
                ),
                if (articleController.currentStep.value > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Précédent'),
                  ),
              ],
            );
          },
          steps: [
            // ÉTAPE 1 : Catégorie & Type d'annonce
            Step(
              title: const Text("Catégorie & Type d'annonce"),
              isActive: articleController.currentStep.value >= 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choisissez une catégorie :'),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (categoryController.isLoading.value) {
                      return const CircularProgressIndicator();
                    }
                    return Wrap(
                      spacing: 8,
                      children: categoryController.categories.map((category) {
                        final selected =
                            categoryController.selectedCategory.value ==
                                category.getName(locale);
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (category.icon != null &&
                                  category.icon!.endsWith('.svg'))
                                SvgPicture.network(category.icon!,
                                    height: 20, width: 20)
                              else if (category.image != null)
                                Image.network(category.image!,
                                    height: 20, width: 20),
                              const SizedBox(width: 4),
                              Text(category.getName(locale)),
                            ],
                          ),
                          selected: selected,
                          onSelected: (_) {
                            categoryController
                                .selectCategory(category.getName(locale));
                            articleController.categoryId.value = category.id;
                          },
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text('Type d\'annonce :'),
                  const SizedBox(height: 8),
                  Obx(() {
                    final selectedCategory =
                        categoryController.selectedCategory.value.toLowerCase();
                    final isBureau =
                        ['bureau', 'office', 'مكتب'].contains(selectedCategory);

                    if (isBureau) {
                      // Force la location pour les bureaux
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (articleController.purpose.value != 'Rent') {
                          articleController.purpose.value = 'Rent';
                        }
                      });
                      return const Chip(
                        label: Text('Location (uniquement)'),
                        avatar: Icon(Icons.business_center),
                        backgroundColor: Color(0xFFE3F2FD),
                      );
                    }

                    final isRent = articleController.purpose.value == 'Rent';
                    return ToggleButtons(
                      isSelected: [isRent, !isRent],
                      onPressed: (index) {
                        articleController.purpose.value =
                            index == 0 ? 'Rent' : 'Sell';
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Location'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Vente'),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            // ÉTAPE 2 : Informations générales
            Step(
              title: const Text('Informations générales'),
              isActive: articleController.currentStep.value >= 1,
              content: Form(
                key: _formKey,
                child: Obx(() {
                  final selectedCategory =
                      categoryController.selectedCategory.value.toLowerCase();
                  final isAppartement = ['appartement', 'apartment', 'شقة']
                      .contains(selectedCategory);
                  final isTerrain =
                      ['terrain', 'land', 'أرض'].contains(selectedCategory);
                  final isBoutique =
                      ['boutique', 'store', 'محل'].contains(selectedCategory);
                  final isBureau =
                      ['bureau', 'office', 'مكتب'].contains(selectedCategory);

                  final showBedrooms = !isTerrain && !isBoutique;
                  final showBathrooms = !isTerrain && !isBoutique && !isBureau;
                  final showSurface = !isAppartement && !isBureau;
                  final bedroomLabel =
                      isBureau ? 'Nombre de pièces' : 'Chambres';

                  return Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Titre'),
                        onChanged: (v) => articleController.nameAr.value = v,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Titre requis' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        onChanged: (v) =>
                            articleController.description.value = v,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Prix'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => articleController.price.value = v,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Prix requis' : null,
                      ),
                      if (showBedrooms) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(labelText: bedroomLabel),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => articleController.bedroom.value = v,
                        ),
                      ],
                      if (showBathrooms) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Salles de bain'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) =>
                              articleController.bathroom.value = v,
                        ),
                      ],
                      if (showSurface) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Surface (m²)'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => articleController.area.value = v,
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ),
            // ÉTAPE 3 : Images
            Step(
              title: const Text('Images'),
              isActive: articleController.currentStep.value >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Image principale ===
                  Text(
                    'Image principale',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final image = articleController.uploadImage.value;
                    final isLoading = articleController.isLoadingImage.value;

                    return GestureDetector(
                      onTap: isLoading
                          ? null
                          : () async {
                              final file = await pickImage();
                              if (file != null) {
                                await articleController.uploadImageFile(file);
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid),
                        ),
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : image.isNotEmpty
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black54,
                                          child: IconButton(
                                            icon: const Icon(Icons.close,
                                                color: Colors.white, size: 18),
                                            onPressed: () =>
                                                articleController.removeImage(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt_outlined,
                                          color: Colors.grey[400], size: 40),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ajouter une image principale',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // === Galerie ===
                  Text(
                    'Galerie d\'images',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final gallery = articleController.uploadGallery;
                    final isLoading = articleController.isLoadingGallery.value;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gallery.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        // "Add more" button
                        if (index == gallery.length) {
                          return GestureDetector(
                            onTap: isLoading
                                ? null
                                : () async {
                                    final files = await pickMultipleImages();
                                    if (files.isNotEmpty) {
                                      await articleController
                                          .uploadGalleryImages(files);
                                    }
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey[300]!,
                                    style: BorderStyle.solid),
                              ),
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_outlined,
                                            color: Colors.grey[400], size: 30),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ajouter',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        }

                        // Gallery item
                        final img = gallery[index];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                img['thumbnail']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 14),
                                  onPressed: () => articleController
                                      .removeImageFromGallery(img),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            // ÉTAPE 4 : Localisation
            Step(
              title: const Text('Localisation'),
              isActive: articleController.currentStep.value >= 3,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    if (articleController.locationData.isEmpty) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Aucune localisation sélectionnée. Utilisez le bouton ci-dessus pour choisir sur la carte.',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final location = articleController.locationData[0];
                    final properties = location['properties'];
                    final geometry = location['geometry']['coordinates'];
                    final surface =
                        _calculateSurface(geometry).toStringAsFixed(2);
                    final lat = double.tryParse(
                            articleController.locationLatitude.value) ??
                        0.0;
                    final lng = double.tryParse(
                            articleController.locationLongitude.value) ??
                        0.0;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aperçu de la localisation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 160,
                              child: lat != 0.0 && lng != 0.0
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(lat, lng),
                                          zoom: 15.0,
                                        ),
                                        markers: {
                                          Marker(
                                            markerId:
                                                const MarkerId('selected'),
                                            position: LatLng(lat, lng),
                                          ),
                                        },
                                        zoomControlsEnabled: false,
                                        scrollGesturesEnabled: false,
                                        tiltGesturesEnabled: false,
                                        rotateGesturesEnabled: false,
                                        myLocationButtonEnabled: false,
                                        mapToolbarEnabled: false,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Coordonnées non disponibles',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                                'Moughataa: ${properties['moughataa'] ?? 'N/A'}'),
                            Text('Lotissement: ${properties['lts'] ?? 'N/A'}'),
                            Text('Surface: $surface m²'),
                            Text('Numero de lot: ${properties['l'] ?? 'N/A'}'),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _showMapModal(context, articleController),
                                icon: const Icon(Icons.fullscreen),
                                label: const Text('Voir sur la carte'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showMapModal(context, articleController),
                      icon: const Icon(Icons.location_on, size: 24),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Sélectionner la localisation sur la carte',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.blue[200],
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ÉTAPE 5 : Récapitulatif
            Step(
              title: const Text('Récapitulatif'),
              isActive: articleController.currentStep.value >= 4,
              content: Obx(() {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Catégorie : ${categoryController.selectedCategory.value}'),
                        Text('Type : ${articleController.purpose.value}'),
                        Text('Titre : ${articleController.nameAr.value}'),
                        Text(
                            'Description : ${articleController.description.value}'),
                        Text('Prix : ${articleController.price.value}'),
                        Text('Chambres : ${articleController.bedroom.value}'),
                        Text('SDB : ${articleController.bathroom.value}'),
                        Text('Surface : ${articleController.area.value} m²'),
                        if (articleController.locationData.isNotEmpty) ...[
                          const Divider(),
                          Text(
                              'Moughataa: ${articleController.locationData[0]['properties']['moughataa'] ?? 'N/A'}'),
                          Text(
                              'Lotissement: ${articleController.locationData[0]['properties']['lts'] ?? 'N/A'}'),
                          Text(
                              'Surface: ${_calculateSurface(articleController.locationData[0]['geometry']['coordinates']).toStringAsFixed(2)} m²'),
                          Text(
                              'Numero de lot: ${articleController.locationData[0]['properties']['l'] ?? 'N/A'}'),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<List<File>> pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    return pickedFiles != null
        ? pickedFiles.map((e) => File(e.path)).toList()
        : [];
  }

  void _showMapModal(BuildContext context, ArticleFormController controller) {
    bool isArabic = Get.locale?.languageCode == 'ar';
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 1.0,
          minChildSize: 0.5,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: controller.selectedMoughataa.value.isEmpty
                                  ? null
                                  : controller.selectedMoughataa.value,
                              hint: const Text('Moughataa'),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectMoughataa(value);
                                }
                              },
                              items: controller.moughataas.map((moughataa) {
                                final arabicName = controller
                                    .addressData[moughataa]['arabicName'];
                                final saxonName =
                                    controller.addressData[moughataa]['name'];
                                return DropdownMenuItem(
                                  value: moughataa,
                                  child:
                                      Text(isArabic ? arabicName : saxonName),
                                );
                              }).toList(),
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<String>(
                              isExpanded: true,
                              value:
                                  controller.selectedLotissement.value.isEmpty
                                      ? null
                                      : controller.selectedLotissement.value,
                              hint: const Text('Lotissement'),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectLotissement(value);
                                }
                              },
                              items: controller.lotissements.map((lotissement) {
                                return DropdownMenuItem(
                                  value: lotissement,
                                  child: Text(lotissement),
                                );
                              }).toList(),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Numéro de lot',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            controller.selectLot(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await controller.fetchFeatures();
                        },
                        child: const Text('Rechercher'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return GoogleMap(
                          mapType: MapType.satellite,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          mapToolbarEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: controller.currentLocation.value,
                            zoom: 19,
                          ),
                          polygons: Set<Polygon>.of(controller.polygons),
                          onMapCreated: (GoogleMapController mapController) {
                            controller.currentLocation.listen((location) {
                              mapController.animateCamera(
                                CameraUpdate.newLatLng(location),
                              );
                            });
                          },
                          onTap: (LatLng location) async {
                            await controller.fetchLocationData(
                                location.latitude, location.longitude);
                            controller.setCurrentLocation(location);
                          });
                    }),
                  ),
                  Obx(() {
                    if (controller.locationData.isEmpty) {
                      return const Text(
                          'Aucune donnée de localisation disponible.');
                    }
                    final location = controller.locationData[0];
                    final properties = location['properties'];
                    final geometry = location['geometry']['coordinates'];
                    final surface =
                        _calculateSurface(geometry).toStringAsFixed(2);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Moughataa: ${properties['moughataa'] ?? 'N/A'}'),
                            Text('Lotissement: ${properties['lts'] ?? 'N/A'}'),
                            Text('Surface: $surface m²'),
                            Text('Numero de lot: ${properties['l'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  }),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer le panneau'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _calculateSurface(List coordinates) {
    if (coordinates.isEmpty) return 0.0;
    double total = 0.0;
    final polygon = coordinates[0][0];
    for (int i = 0; i < polygon.length - 1; i++) {
      final x1 = polygon[i][0];
      final y1 = polygon[i][1];
      final x2 = polygon[i + 1][0];
      final y2 = polygon[i + 1][1];
      total += (x1 * y2 - y1 * x2);
    }
    total = total.abs() / 2.0;
    return total * 111319.9 * 111319.9;
  }
}
