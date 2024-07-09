import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthField<T> extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextStyle? style;
  final AutovalidateMode? autovalidateMode;

  const AuthField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.style,
    this.autovalidateMode,
  });

  @override
  State<AuthField<T>> createState() => _AuthFieldState<T>();
}

class _AuthFieldState<T> extends State<AuthField<T>> {
  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: context.theme.textTheme.bodyMedium,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: _passwordVisible
                    ? Icon(
                        Icons.visibility_outlined,
                        color: context.theme.colorScheme.outline,
                      )
                    : Icon(
                        Icons.visibility_off_outlined,
                        color: context.theme.colorScheme.outline,
                      ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
      style: widget.style ?? context.theme.textTheme.bodyMedium,
      validator: (value) {
        if (value!.isEmpty) {
          return '${widget.hintText} is missing';
        }
        if (widget.isPassword && value.length < 8) {
          return 'Password must be atleast 8 characters long';
        }
        return null;
      },
      obscureText: widget.isPassword && !_passwordVisible,
      autovalidateMode: widget.autovalidateMode,
    );
  }
}
