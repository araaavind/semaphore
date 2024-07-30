import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppTextField<T> extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextStyle? style;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final int? errorMaxLines;
  final Color? validBorderColor;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.style,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.suffixIcon,
    this.errorMaxLines,
    this.validBorderColor,
  });

  @override
  State<AppTextField<T>> createState() => _AppTextFieldState<T>();
}

class _AppTextFieldState<T> extends State<AppTextField<T>> {
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
        errorMaxLines: widget.errorMaxLines,
        hintText: widget.hintText,
        hintStyle: context.theme.textTheme.bodyMedium,
        focusedBorder: widget.validBorderColor != null
            ? context.theme.inputDecorationTheme.focusedBorder!.copyWith(
                borderSide: BorderSide(
                  color: widget.validBorderColor!,
                  width: 2,
                ),
              )
            : null,
        suffixIcon: widget.suffixIcon ??
            (widget.isPassword
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
                : null),
      ),
      style: widget.style ?? context.theme.textTheme.bodyMedium,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: widget.isPassword && !_passwordVisible,
      autovalidateMode: widget.autovalidateMode,
    );
  }
}
