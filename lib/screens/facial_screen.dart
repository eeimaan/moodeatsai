import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:moodeatsai/screens/recommended_recipe_screen.dart';
import 'package:moodeatsai/widgets/widgets.dart';
import 'package:page_transition/page_transition.dart';

class FacialScreen extends StatefulWidget {
  final String imagePath;
  final List<String> allergies;

  const FacialScreen(
      {Key? key, required this.imagePath, required this.allergies})
      : super(key: key);

  @override
  State<FacialScreen> createState() => _FacialScreenState();
}

class _FacialScreenState extends State<FacialScreen> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
    ),
  );

  final List<String> _expressions = [];
  final ValueNotifier<bool> _detectingExpressions = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _detectExpressions();
  }

  Future<void> _detectExpressions() async {
    final imageFile = File(widget.imagePath);
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces[0];

        if (face.smilingProbability != null) {
          if (face.smilingProbability! > 0.7) {
            _expressions.add('happy');
          } else if (face.smilingProbability! < 0.2) {
            _expressions.add('sad');
          } 
          // else {
          //   _expressions.add('neutral');
          // }
        }

        if (face.leftEyeOpenProbability != null &&
            face.rightEyeOpenProbability != null) {
          if (face.leftEyeOpenProbability! < 0.3 &&
              face.rightEyeOpenProbability! < 0.3) {
            _expressions.add('cry');
          } else if (face.leftEyeOpenProbability! > 0.7 &&
              face.rightEyeOpenProbability! > 0.7) {
            _expressions.add('angry');
          }
        }
      }
    } catch (e) {
      log('Failed to process image: $e');
    }

    _detectingExpressions.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.file(
              File(widget.imagePath),
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: _detectingExpressions,
            builder: (context, isDetecting, _) {
              if (isDetecting) {
                return const CupertinoActivityIndicator();
              } else {
                return _expressions.isNotEmpty
                    ? Column(
                        children: [
                          Text(
                            'Detected Expressions: ${_expressions.first}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            width: 250,
                            child: CustomButton(
                              text: 'See recommended recipes',
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: RecommendedRecipeScreen(
                                      title:
                                          ' Recipes for your ${_expressions.first} mood ',
                                      allergies: widget.allergies,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        ' No face Expressions Detected ',
                        style: TextStyle(fontSize: 16),
                      );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}
