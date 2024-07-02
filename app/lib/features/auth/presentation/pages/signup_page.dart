import 'package:app/core/common/widgets/widgets.dart';
import 'package:app/core/constants/constants.dart';
import 'package:app/core/theme/theme.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const SignupPage());

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Join ',
                  style: context.theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w100,
                  ),
                  children: [
                    TextSpan(
                      text: 'semaphore',
                      style: context.theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              InputField(
                hintText: 'Name',
                controller: nameController,
              ),
              const SizedBox(height: 10),
              InputField(
                hintText: 'Email',
                controller: emailController,
              ),
              const SizedBox(height: 10),
              InputField(
                hintText: 'Password',
                controller: passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              Button(
                text: 'Sign up',
                fixedSize: const Size(160, 50),
                onPressed: () {},
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   LoginPage.route(),
                  //   (route) => false,
                  // );
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: context.theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Log in',
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
