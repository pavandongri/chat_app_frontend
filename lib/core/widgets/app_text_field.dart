import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.onChanged,
    this.autofocus = false,
    this.filled,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  /// Overrides the themed opaque fill — pass `false` so a glass/blurred
  /// container behind the field (e.g. `GlassCard`) shows through instead
  /// of being hidden under the default solid fill. Leave unset to keep the
  /// standard themed input.
  final bool? filled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: filled,
        fillColor: filled == false ? Colors.transparent : null,
      ),
    );
  }
}
