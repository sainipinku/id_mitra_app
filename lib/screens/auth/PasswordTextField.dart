import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/text_filed.dart';
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool isRequired;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.isRequired = true,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hintText: 'Enter your password',
      icon: Icons.lock,
      obscureText: isObscure,
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.graySubTitleColor,
        ),
        onPressed: () {
          setState(() {
            isObscure = !isObscure;
          });
        },
      ),

      validator: widget.isRequired
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Minimum 6 characters required';
        }
        return null;
      }
          : null,
    );
  }
}