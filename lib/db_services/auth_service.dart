// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodeatsai/screens/bottom_navigation_screen.dart';
import 'package:page_transition/page_transition.dart';

class DbServiceAuth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Future<DocumentSnapshot> fetchUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return userData;
  }

  static Future<void> registerUser(
    BuildContext context,
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
        });

        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const BottomNavigationScreen(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showAlertDialog(context, 'Email Already In Use',
            'The email is already registered. Please use a different email.');
      } else {
        _showAlertDialog(context, 'Registration Error', e.message ?? '');
      }
    } catch (e) {
      log('Error registering user: $e');
      _showAlertDialog(context, 'Registration Error',
          'An unexpected error occurred. Please try again later.');
    }
  }

  static Future<void> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const BottomNavigationScreen(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle authentication exceptions
      if (e.code == 'user-not-found') {
        _showAlertDialog(context, 'User Not Found',
            'No user found for that email. Please sign up first.');
      } else if (e.code == 'wrong-password') {
        _showAlertDialog(context, 'Incorrect Password',
            'The password you entered is incorrect.');
      } else {
        _showAlertDialog(context, 'Login Error', e.message ?? '');
      }
    } catch (e) {
      // Handle other exceptions
      log('Error logging in user: $e');
      _showAlertDialog(context, 'Login Error',
          'An unexpected error occurred. Please try again later.');
    }
  }

  // Method to show an alert dialog
  static void _showAlertDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
