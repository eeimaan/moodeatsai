import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class RecipeDbservice {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addRecipe({
    required String instruction,
    required String ingredient,
    required String time,
    required String name,
    required String mood,
    required String category,
  }) async {
    try {
      await _firestore.collection('recipe').doc(const Uuid().v4()).set({
        'instruction': instruction,
        'ingredient': ingredient,
        'time': time,
        'name': name,
        'mood': mood,
        'category': category,
      });
    } catch (e) {
      print('Error adding recipe: $e');
      throw e;
    }
  }
  static Future<List<DocumentSnapshot>> fetchBookmarkedRecipes() async {
    final userData = await FirebaseFirestore.instance
        .collection('save_recipe')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    // Check if the document exists and if the "bookmarks" field exists
    if (userData.exists && userData.data()!.containsKey('bookmarks')) {
      final bookmarkIds = List<String>.from(userData.get('bookmarks') ?? []);

      final List<DocumentSnapshot> bookmarkedRecipes = [];
      for (final id in bookmarkIds) {
        final docSnapshot =
            await FirebaseFirestore.instance.collection('recipe').doc(id).get();
        if (docSnapshot.exists) {
          bookmarkedRecipes.add(docSnapshot);
        }
      }

      return bookmarkedRecipes;
    } else {
      return [];
    }
  }



  
}
