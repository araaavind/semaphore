import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/utils/utils.dart';
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
  final TextInputType? keyboardType;
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
    this.keyboardType,
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
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        errorMaxLines: widget.errorMaxLines,
        hintText: widget.hintText,
        hintStyle: context.theme.textTheme.bodyMedium!.copyWith(
          color: context.theme.colorScheme.onSurface.withOpacity(0.65),
        ),
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
                            MingCute.eye_line,
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(0.65),
                          )
                        : Icon(
                            MingCute.eye_close_line,
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(0.30),
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
