import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodeatsai/constants/constants.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String name;
  final String time;
  final String ingredient;
  final String instructions;
  final String uid;
  final bool isNavFromRecommended;

  const RecipeDetailScreen(
      {super.key,
      required this.name,
      required this.time,
      required this.ingredient,
      required this.instructions,
      required this.uid,
      required this.isNavFromRecommended});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isBookmarked = false; 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Recipe Details'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        AppImages.recipeIcon1,
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, left: 10),
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                   if (widget.isNavFromRecommended) 
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () {
                        toggleBookmark();
                      },
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color:
                            isBookmarked ? AppColors.darkYellow : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                'time : ${widget.time}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Ingredients'),
                Tab(text: 'Instructions'),
              ],
              labelColor: AppColors.darkYellow,
              unselectedLabelColor: Colors.black,
              indicatorColor: AppColors.darkYellow,
              indicatorWeight: 0.5,
              dividerColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  IngredientsTab(
                    ingredient: widget.ingredient,
                  ),
                  InstructionsTab(
                    instructions: widget.instructions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleBookmark() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      // Handle case where user is not logged in
      return;
    }

    final String userUid = user.uid;
    final DocumentReference recipeRef =
        _firestore.collection('save_recipe').doc(userUid);

    final DocumentSnapshot snapshot = await recipeRef.get();
    List<dynamic> bookmarks = [];

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      bookmarks = data['bookmarks'] ?? [];
    }

    setState(() {
      if (bookmarks.contains(widget.uid)) {
        // Remove from bookmarks
        bookmarks.remove(widget.uid);
        isBookmarked = false;
      } else {
        // Add to bookmarks
        bookmarks.add(widget.uid);
        isBookmarked = true;
      }
    });

    // Update bookmarks in Firestore
    await recipeRef.set({'bookmarks': bookmarks});
  }
}

class NumberedListTile extends StatelessWidget {
  final String text;

  const NumberedListTile({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> lines = text.split(',').map((line) => line.trim()).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: AppColors.brownShade,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines
                .map((line) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_manual_record,
                              size: 12,
                              color: Colors.black // adjust color as needed
                              ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              line,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class NumberedInstructionListTile extends StatelessWidget {
  final String text;

  const NumberedInstructionListTile({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> lines = text.split('.').map((line) => line.trim()).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: AppColors.brownShade,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines.map((line) {
              int index = lines.indexOf(line);
              String nextLine = index < lines.length - 1
                  ? lines[index + 0]
                  : ''; // Get the next line
              bool showIcon =
                  nextLine.isNotEmpty; // Check if the next line is not empty
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (showIcon) // Conditionally show the icon
                      const Icon(
                        Icons.fiber_manual_record,
                        size: 12,
                        color: Colors.black, // Adjust color as needed
                      ),
                    if (showIcon) // Conditionally show the SizedBox
                      const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        line,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class IngredientsTab extends StatelessWidget {
  final String ingredient;
  const IngredientsTab({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          NumberedListTile(text: ingredient),
        ],
      ),
    );
  }
}

class InstructionsTab extends StatelessWidget {
  final String instructions;
  const InstructionsTab({super.key, required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          NumberedInstructionListTile(text: instructions),
        ],
      ),
    );
  }
}
