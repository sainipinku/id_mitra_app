

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';
import 'package:idmitra/helpers/helpers.dart';


Widget nameTextField({
  required TextEditingController controller,
  IconData? icon,String? hintName,String? validatorTxt,bool isRequired = true,bool readOnly = true
}) {
  return AppTextField(
    enabled: readOnly,
    controller: controller,
    hintText: hintName ?? 'Enter a name',
    icon: icon,
    validator: isRequired
        ? (value) {
      if (value == null || value.trim().length < 3) {
        return validatorTxt ?? 'Name must contain at least 3 letters';
      }
      return null;
    }: null,
  );
}
Widget descriptionTextField({
  required TextEditingController controller,
  IconData? icon,String? hintName,String? validatorTxt,bool isRequired = true,required int mxLine
}) {
  return AppTextField(
    controller: controller,
    hintText: hintName ?? 'Enter a name',
    icon: icon,
    mxLine: mxLine,
    validator: isRequired
        ? (value) {
      if (value == null || value.trim().length < 3) {
        return validatorTxt ?? 'Name must contain at least 3 letters';
      }
      return null;
    }: null,
  );
}

Widget phoneNumberTextField({
  required TextEditingController controller,String? hintName,
  bool isRequired = true,
}) {
  return AppTextField(
    controller: controller,
    hintText: hintName ?? 'Please enter your phone number',
    keyboardType: TextInputType.number,
    icon: isRequired
        ? Icons.call : null,
    inputFormatters: [
      LengthLimitingTextInputFormatter(10),
      FilteringTextInputFormatter.digitsOnly,
    ],
    validator: isRequired
        ? (value) {
      if (value == null || value.length != 10) {
        return 'Enter a valid phone number';
      }
      return null;
    }
        : null,
  );
}

Widget emailTextField({
  required TextEditingController controller,
  bool isRequired = true,
  Function(String)? onChanged,
}) {
  return AppTextField(
    controller: controller,
    hintText: 'Please enter your email id',
    keyboardType: TextInputType.emailAddress,
    icon: Icons.email,
    onChanged: onChanged,
    validator: isRequired
        ? (value) {
      if (value == null || !Helpers().isEmail(value)) {
        return 'Enter a valid email address';
      }
      return null;
    }
        : null,
  );
}
Widget gstTextField({
  required TextEditingController controller,
  bool isRequired = true,
  Function(String)? onChanged,
}) {
  return AppTextField(
    controller: controller,
    hintText: 'Please enter your GSTN No.',
    keyboardType: TextInputType.emailAddress,
    onChanged: onChanged,
    validator: isRequired
        ? (value) {
      if (value == null || value.isEmpty) {
        return 'GST number is required';
      }
      if (!Helpers().isValidGST(value)) {
        return 'Enter a valid GST number';
      }
      return null;
    }
        : null,
  );
}
Widget websiteTextField({
  required TextEditingController controller,
  bool isRequired = true,
  Function(String)? onChanged,
}) {
  return AppTextField(
    controller: controller,
    hintText: 'Please enter your Website',
    keyboardType: TextInputType.emailAddress,
    onChanged: onChanged,
    validator: isRequired
        ? (value) {
      if (value == null || value.isEmpty) {
        return 'Website is required';
      }
      if (!Helpers().isValidWebsite(value)) {
        return 'Enter a valid website URL';
      }
      return null;
    }
        : null,
  );
}
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool enabled;
  final EdgeInsets scrollPadding;
  final Function(String)? onChanged;
  final int? mxLine;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.enabled = true,
    this.scrollPadding = EdgeInsets.zero,
    this.onChanged,this.mxLine
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: mxLine,

      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      scrollPadding: scrollPadding,
      cursorColor: AppTheme.graySubTitleColor,
      style: MyStyles.regularText(
        size: 14,
        color: AppTheme.graySubTitleColor,
      ),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.whiteColor,
        contentPadding: const EdgeInsets.all(12),
        hintText: hintText,
        prefixIcon: icon != null
            ? Icon(icon, size: 22, color: AppTheme.graySubTitleColor)
            : null,
        enabledBorder: appBorder(AppTheme.backBtnBgColor, 15),
        focusedBorder: appBorder(AppTheme.backBtnBgColor, 15),
        errorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
        focusedErrorBorder: appBorder(AppTheme.errorMessageBackgroundColor, 15),
        hintStyle: MyStyles.regularText(
          size: 14,
          color: AppTheme.graySubTitleColor,
        ),
      ),
    );
  }
  OutlineInputBorder appBorder(Color color, double radius) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}


