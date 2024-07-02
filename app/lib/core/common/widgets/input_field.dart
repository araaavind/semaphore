import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextStyle? style;

  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: context.theme.textTheme.bodyMedium,
      ),
      style: style ?? context.theme.textTheme.bodyMedium,
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText is missing';
        }
        return null;
      },
      obscureText: isPassword,
    );
  }
}
