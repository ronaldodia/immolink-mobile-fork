import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/articles/article_form_controller.dart';
import 'package:immolink_mobile/controllers/home/categories_controller.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class CreateArticleScreen extends StatelessWidget {
  final ArticleFormController articleController = Get.put(ArticleFormController());
  final CategoryController categoryController = Get.put(CategoryController());

  CreateArticleScreen({super.key});

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
              title: const Text('Informations générales'),
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
                ],
              ),
              isActive: articleController.currentStep.value >= 0,
            ),
            Step(
              title: const Text('Détails de localisation'),
              stepStyle: _stepStyle.copyWith(
                connectorColor: Colors.orange,
                gradient: const LinearGradient(
                  colors: <Color>[
                    Colors.yellow,
                    Colors.yellow,
                  ],
                ),
                border: Border.all(
                  color: Colors.yellow,
                  width: 2,
                ),
              ),
              content: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    onChanged: (value) => articleController.locationLatitude.value = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    onChanged: (value) => articleController.locationLongitude.value = value,
                  ),
                ],
              ),
              isActive: articleController.currentStep.value >= 1,
            ),
            Step(
              title: const Text('Détails supplémentaires'),
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
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Prix'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => articleController.price.value = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Surface (m²)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => articleController.area.value = value,
                  ),
                ],
              ),
              isActive: articleController.currentStep.value >= 2,
            ),
            Step(
              title: const Text('Résumé'),
              stepStyle: _stepStyle.copyWith(
                connectorColor: Colors.green,
                gradient: const LinearGradient(
                  colors: <Color>[
                    Colors.green,
                    Colors.green,
                  ],
                ),
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vérifiez vos informations :'),
                  Text('Catégorie : ${categoryController.selectedCategory.value}'),
                  Text('Purpose : ${categoryController.purpose.value}'),
                  Text('Latitude : ${articleController.locationLatitude.value}'),
                  Text('Longitude : ${articleController.locationLongitude.value}'),
                  Text('Prix : ${articleController.price.value}'),
                  ElevatedButton(
                    onPressed: () => articleController.goToStep(0),
                    child: const Text('Modifier'),
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
}
