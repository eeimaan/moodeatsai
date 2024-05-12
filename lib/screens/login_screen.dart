import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:moodeatsai/constants/constants.dart';
import 'package:moodeatsai/db_services/auth_service.dart';
import 'package:moodeatsai/provider/provider.dart';
import 'package:moodeatsai/widgets/widgets.dart';
import 'package:provider/provider.dart';

import 'package:moodeatsai/screens/screens.dart';
import 'package:page_transition/page_transition.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.sizeOf(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Image.asset(
                      AppImages.logo,
                      height: 150,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        AppImages.waveHey,
                        height: 20,
                        width: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Hey,',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    AppText.welcomeText,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTextField(
                    hintText: 'Email',
                    controller: emailController,
                    validator: (input) {
                      if (input == null || input.isEmpty) {
                        return 'Please enter an email address';
                      } else if (!isValidEmail(input)) {
                        return 'Invalid email address';
                      }
                      return null;
                    },
                    obscureText: false,
                  ),
                 Consumer<PasswordIconToggleProvider>(
  builder: (context, value, child) => CustomTextField(
    validator: (input) {
      if (input == null || input.isEmpty) {
        return 'Please enter a password';
      } else if (input.length < 6) {
        return 'Password must be at least 6 characters long';
      }
      return null;
    },
    obscureText: !value.isVisible, // Adjusted this line
    controller: passwordController,
    hintText: 'Password',
    suffixIcon: InkWell(
      onTap: () {
        Provider.of<PasswordIconToggleProvider>(context, listen: false)
          .toggleVisibility(); // Adjusted this line
      },
      child: Icon(
        value.isVisible
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
        color: Colors.black,
      ),
    ),
  ),
),

                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: CustomButton(
                        text: 'Login',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context).unfocus();
                            try {
                              DbServiceAuth.loginUser(
                                  context,
                                  emailController.text,
                                  passwordController.text);
                            } catch (e) {
                       log('Login failed: $e');
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const RegisterScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Donot have account?',
                          ),
                          Text(
                            ' Register Now',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
