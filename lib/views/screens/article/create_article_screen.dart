import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immolink_mobile/controllers/articles/article_form_controller.dart';
import 'package:immolink_mobile/controllers/communes/commune_controller.dart';
import 'package:immolink_mobile/controllers/communes/district_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/models/Commune.dart';
import 'package:immolink_mobile/utils/config.dart';
import 'package:immolink_mobile/utils/image_constants.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class CreateArticleScreen extends StatelessWidget {
  final ArticleFormController articleController = Get.put(ArticleFormController());
  final CategoryController categoryController = Get.put(CategoryController());
  // final DistrictController districtController = Get.put(DistrictController());
  final CommuneController communeController = Get.put(CommuneController());

  CreateArticleScreen({super.key});

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<List<File>> pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    return pickedFiles != null ? pickedFiles.map((e) => File(e.path)).toList() : [];
  }

  final StepStyle _stepStyle = StepStyle(
    connectorThickness: 10,
    color:Colors.green,
    connectorColor: Colors.green,
    indexStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
    border: Border.all(
      color: Colors.green,
      width: 2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer une annonce'), backgroundColor: Colors.white,),
      backgroundColor: Colors.white,
      body: Obx(() {
        return Stepper(
          currentStep: articleController.currentStep.value,
          onStepContinue: () {
            if (articleController.currentStep.value < 3) {
              articleController.currentStep.value++;
            } else {
              articleController.submitForm();
            }
          },
          onStepCancel: () {
            if (articleController.currentStep.value > 0) {
              articleController.currentStep.value--;
            }
          },
          steps: [
            Step(
              title: const Text("Type d'Annonce"),
              stepStyle: _stepStyle,
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
                      spacing: 10,
                      children: categoryController.categories.map((category) {
                        return ElevatedButton(
                          onPressed: () {
                            categoryController.selectCategory(category['name']);
                            articleController.categoryId.value = category['id'];
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: categoryController.selectedCategory.value == category['name']
                                ? Colors.green
                                : Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.network(
                                category['image'], // Chemin de l'image SVG
                                height: 20, // Hauteur de l'icône
                                width: 20,  // Largeur de l'icône
                                colorFilter: categoryController.selectedCategory.value == category['name']
                                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                                    : const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                              ),
                              const SizedBox(height: TSizes.spaceBtwItems),
                              Text(category['name'], style: TextStyle(color: categoryController.selectedCategory.value == category['name'] ? Colors.white : Colors.green),),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text('Choisir une proposition :'),
                  Obx(() {
                    final isBoutique =
                        categoryController.selectedCategory.value.toLowerCase() == 'boutique' ||
                            categoryController.selectedCategory.value.toLowerCase() == 'store' ||  categoryController.selectedCategory.value.toLowerCase() == 'محل' ;
                    return Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            categoryController.setPurpose('Rent');
                            articleController.purpose.value = 'Rent';
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: categoryController.purpose.value == 'Rent'
                                ? Colors.green
                                : Colors.white,
                          ),
                          child:  Text('Rent', style: TextStyle(color: categoryController.purpose.value == 'Rent' ? Colors.white : Colors.green)),
                        ),
                        const SizedBox(width: 10),
                        if (!isBoutique)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: categoryController.purpose.value == 'Sell'
                                  ? Colors.green
                                  : Colors.white,
                            ),
                            onPressed: () => categoryController.setPurpose('Sell'),
                            child:  Text('Sell',  style: TextStyle(color: categoryController.purpose.value == 'Sell' ? Colors.white : Colors.green)),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  const Text(
                    "Sélectionnez une zone",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Obx(
                        () => DropdownButton<Commune>(
                      isExpanded: true,
                      value: communeController.selectedCommune.value,
                      items: communeController.communes.map((commune) {
                        return DropdownMenuItem(
                          value: commune,
                          child: Text(commune.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        communeController.selectedCommune.value = value;
                        communeController.selectedDistrict.value = null; // Reset district
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Label pour le quartier
                  Obx(
                        () {
                      final districts = communeController.selectedCommune.value?.districts ?? [];
                      if (districts.isEmpty) {
                        return const SizedBox(); // Cacher si aucun quartier disponible
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sélectionnez un quartier",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<District>(
                            isExpanded: true,
                            value: communeController.selectedDistrict.value ??
                                (districts.isNotEmpty ? districts.first : null),
                            items: districts.map((district) {
                              return DropdownMenuItem(
                                value: district,
                                child: Text(district.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              communeController.selectedDistrict.value = value;
                            },
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
              isActive: articleController.currentStep.value >= 0,
            ),
            Step(
              title: const Text('Informations générales'),
              stepStyle: _stepStyle.copyWith(
                connectorColor: Colors.orange,
                gradient: const LinearGradient(
                  colors: <Color>[Colors.yellow, Colors.yellow],
                ),
                border: Border.all(
                  color: Colors.yellow,
                  width: 2,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champs pour la latitude et la longitude
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Titre', suffixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onChanged: (value) => articleController.nameAr.value = value,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) => articleController.description.value = value,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    onChanged: (value) => articleController.price.value = value,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre de Chambre'),
                    onChanged: (value) => articleController.bedroom.value = value,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems,),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nombre de Toilette'),
                    onChanged: (value) => articleController.bathroom.value = value,
                  ),const SizedBox(height: TSizes.spaceBtwItems,),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Surface m²'),
                    onChanged: (value) => articleController.area.value = value,
                  ),
                ],
              ),
              isActive: articleController.currentStep.value >= 1,
            ),
            Step(
              title: const Text('Image & Gallerie'),
              stepStyle: _stepStyle.copyWith(
                connectorColor: Colors.red,
                gradient: const LinearGradient(
                  colors: <Color>[
                    Colors.red,
                    Colors.red,
                  ],
                ),
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image en avant
                  const SizedBox(height: 8),
                  Obx(() {
                    return Column(
                      children: [
                        if (articleController.uploadImage.isNotEmpty)
                          Stack(
                            children: [
                              Image.network(
                                '${Config.initUrl}${articleController.uploadImage.value}',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    articleController.removeImage();
                                  },
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: TSizes.fontSizeSm,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.8)
                          ),
                          onPressed: articleController.isLoadingImage.value
                              ? null
                              : () async {
                            final file = await pickImage(); // Implémentez la méthode pickImage()
                            if (file != null) {
                              await articleController.uploadImageFile(file);
                            }
                          },
                          child: Row(
                            children: [
                             articleController.isLoadingImage.value
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Icon(Icons.upload, color: Colors.black54,),
                            const Text('Ajouter une image ', style: TextStyle(color: Colors.black54),),
                            ],
                          ),
                        ),

                      ],
                    );
                  }),

                  const SizedBox(height: TSizes.spaceBtwItems),
                const Divider(),

                  const SizedBox(height: TSizes.spaceBtwItems),
                  Obx(() {
                    return Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: articleController.uploadGallery
                              .map(
                                (image) => Stack(
                              children: [
                                Image.network(
                                  '${Config.initUrl}${image['thumbnail']!}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      articleController.removeImageFromGallery(image);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                              .toList(),
                        ),
                        const SizedBox(height: TSizes.fontSizeSm,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.8)
                          ),
                          onPressed: articleController.isLoadingGallery.value
                              ? null
                              : () async {
                            final files = await pickMultipleImages(); // Implémentez la méthode pickMultipleImages()
                            if (files != null && files.isNotEmpty) {
                              await articleController.uploadGalleryImages(files);
                            }
                          },

                          child: Row(
                            children: [
                              articleController.isLoadingGallery.value
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Icon(Icons.upload, color: Colors.black54,),
                              const Text('Images de gallerie', style: TextStyle(color: Colors.black54,),),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                      ],
                    );
                  }),

                ],
              ),
              isActive: articleController.currentStep.value >= 2,
            ),

            Step(
              title: const Text('Localisation'),
              stepStyle: _stepStyle.copyWith(
                connectorColor: Colors.green,
                gradient: const LinearGradient(
                  colors: <Color>[Colors.green, Colors.green],
                ),
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(1.0),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showMapModal(context, articleController),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Afficher la carte',
                          style: TextStyle(color: Colors.lightGreen),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.map,
                          color: Colors.green,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              isActive: articleController.currentStep.value >= 3,
            ),




          ],
        );
      }),
    );
  }

  void _showMapModal(BuildContext context, ArticleFormController controller) {

    bool isArabic = Get.locale?.languageCode == 'ar';
    showModalBottomSheet(
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
                            final arabicName = controller.addressData[moughataa]['arabicName'];
                            final saxonName = controller.addressData[moughataa]['name'];
                            return DropdownMenuItem(
                              value: moughataa,
                              child: Text(isArabic ? arabicName : saxonName),
                            );
                          }).toList(),
                        )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: controller.selectedLotissement.value.isEmpty
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
                          zoom: 18,
                        ),
                        polygons: Set<Polygon>.of(controller.polygons),
                        onMapCreated: (GoogleMapController mapController) {
                          controller.currentLocation.listen((location) {
                            mapController.animateCamera(
                              CameraUpdate.newLatLng(location),
                            );

                          });

                        },
                          onTap: (LatLng location) {
                            controller.setCurrentLocation(location);
                          }
                      );
                    }),
                  ),


                  Obx(() {
                    if (controller.locationData.isEmpty) {
                      return const Text('Aucune donnée de localisation disponible.');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.locationData.length,
                      itemBuilder: (_, index) {
                        final location = controller.locationData[index];
                        final properties = location['properties'];
                        final geometry = location['geometry']['coordinates'];
                        final surface = _calculateSurface(geometry).toStringAsFixed(2);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Moughataa: ${properties['moughataa'] ?? 'N/A'}'),
                                Text('Lotissement: ${properties['lts'] ?? 'N/A'}'),
                                Text('Surface: $surface m²'),
                              ],
                            ),
                          ),
                        );
                      },
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
    // Calcul approximatif de surface en m² pour un polygone
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
    return total * 111319.9 * 111319.9; // Conversion en mètres carrés
  }


}
