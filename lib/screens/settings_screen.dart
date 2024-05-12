import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodeatsai/constants/constants.dart';
import 'package:moodeatsai/db_services/auth_service.dart';
import 'package:moodeatsai/widgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:moodeatsai/screens/screens.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late User? _user;
  late Future<DocumentSnapshot> _userData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _userData = DbServiceAuth.fetchUserData();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: _userData,
          builder: (context, snapshot) {
            if (_user == null) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('No user data found');
            } else {
              final userData = snapshot.data!;
              final userName = userData['name'] ?? 'John Doe';
              final userEmail = _user!.email ?? 'john.doe@example.com';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameWidget(context, 'Name', userName),
                  const SizedBox(height: 8),
                  _buildNameWidget(context, 'Email', userEmail),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: CustomButton(
                        icon: Icons.logout,
                        text: 'Logout',
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          // ignore: use_build_context_synchronously
                          Navigator.pushAndRemoveUntil(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildNameWidget(BuildContext context, String heading, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: AppColors.brownShade,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
