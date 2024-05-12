import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moodeatsai/constants/constants.dart';
import 'package:moodeatsai/db_services/recipe_dbservice.dart';
import 'package:moodeatsai/provider/provider.dart';
import 'package:moodeatsai/widgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moodeatsai/screens/screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final allergiesModel = Provider.of<AllergiesModel>(context);
    final allergies = allergiesModel.selectedAllergies;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recipe Generator'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 34,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const DateReminderScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    AppImages.facialIcon,
                    height: 150,
                    width: 150,
                  ),
                ),
                const SizedBox(height: 16.0),
                CustomButton(
                  text: 'Start Camera',
                  onPressed: () async {
                    try {
                      final XFile? image = await _imagePicker.pickImage(
                          source: ImageSource.camera);
                      if (image != null) {
                        log('Image captured: ${image.path}');
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: FacialScreen(
                                imagePath: image.path,
                                allergies:
                                    allergiesModel.selectedAllergies.toList()),
                          ),
                        );
                      } else {
                        log('No image captured.');
                      }
                    } catch (e) {
                      log('Failed to capture image: $e');
                    }
                  },
                  buttonColor: Colors.deepOrange,
                  textColor: Colors.white,
                  fontSize: 16.0,
                  icon: Icons.camera_alt,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Generate a recipe based on your facial expression!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 50.0),
                CustomButton(
                  text: 'Add Allergies',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          nameController: nameController,
                        );
                      },
                    );
                  },
                  buttonColor: Colors.deepOrange,
                  textColor: Colors.white,
                  fontSize: 16.0,
                ),
                // CustomButton(
                //   text: 'Add Recipes',
                //   onPressed: () {
                //     RecipeDbservice.addRecipe(
                //       instruction:
                //           'Cook bacon until crispy. In a bowl, mix together cooked quinoa, crumbled bacon, diced avocado, cherry tomatoes, chopped green onions, and shredded cheddar cheese. Drizzle with ranch dressing and toss to coat.',
                //       ingredient:
                //           'Quinoa, bacon, avocado, cherry tomatoes, green onions, cheddar cheese, ranch dressing',
                //       time: '15 minutes',
                //       name: 'Avocado Quinoa Salad',
                //       mood: 'angry',
                //       category: 'all',
                //     );
                //   },
                //   buttonColor: Colors.deepOrange,
                //   textColor: Colors.white,
                //   fontSize: 16.0,
                // ),
                const SizedBox(height: 16.0),
                Text(
                  allergies.isEmpty
                      ? 'No allergies added yet.'
                      : 'Your added allergies:',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                if (allergies.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: allergies
                          .map((allergy) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  '- $allergy',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final TextEditingController nameController;

  const CustomDialog({
    Key? key,
    required this.nameController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allergiesModel = Provider.of<AllergiesModel>(context);
    final allergies = [
      'Milk',
      'Egg',
      'Fish',
      'Wheat',
    ];

    return Dialog(
      surfaceTintColor: AppColors.backgroundColor,
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.close,
                  color: AppColors.darkYellow,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Tap to add allergy items',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: allergies.length,
              itemBuilder: (context, index) {
                final allergy = allergies[index];
                final isSelected =
                    allergiesModel.selectedAllergies.contains(allergy);

                return ListTile(
                  title: Text(
                    allergy,
                    style: TextStyle(
                      color: isSelected ? Colors.grey : Colors.black,
                      decoration:
                          isSelected ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  onTap: () {
                    if (!isSelected) {
                      allergiesModel.addAllergy(allergy);
                    } else {
                      allergiesModel.removeAllergy(allergy);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),
            // CustomButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   text: 'Cancel',
            //   buttonColor: Colors.grey,
            //   textColor: Colors.white,
            // ),
          ],
        ),
      ),
    );
  }
}
