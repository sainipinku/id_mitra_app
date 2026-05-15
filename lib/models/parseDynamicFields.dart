import 'package:flutter/material.dart';

List<DynamicField> generateFields(Map<String, dynamic> data) {
  List<DynamicField> fields = [];

  data.forEach((key, value) {
    if (value == null ||
        key == "confidence_score" ||
        key == "detected_document_type") {
      return;
    }

    /// If Map type (name, phones, emails etc.)
    if (value is Map<String, dynamic>) {
      String primaryValue = value["primary"]?.toString() ?? "";

      List<String> alternatives = [];

      if (value["alternatives"] is List) {
        alternatives = List<String>.from(value["alternatives"]);
      }

      if (value["secondary"] is List) {
        alternatives.addAll(List<String>.from(value["secondary"]));
      }

      /// If primary empty but alternatives exist
      if (primaryValue.isEmpty && alternatives.isNotEmpty) {
        primaryValue = alternatives.first;
      }

      if (primaryValue.isNotEmpty) {
        fields.add(
          DynamicField(
            key: key,
            label: formatLabel(key),
            selectedValue: primaryValue,
            alternatives: alternatives,
          ),
        );
      }
    }

    /// If simple string
    else if (value is String && value.trim().isNotEmpty) {
      fields.add(
        DynamicField(
          key: key,
          label: formatLabel(key),
          selectedValue: value,
          alternatives: [],
        ),
      );
    }

    /// If list (like services)
    else if (value is List && value.isNotEmpty) {
      for (var item in value) {
        if (item is String && item.trim().isNotEmpty) {
          fields.add(
            DynamicField(
              key: key,
              label: formatLabel(key),
              selectedValue: item,
              alternatives: [],
            ),
          );
        }
      }
    }
  });

  return fields;
}



String formatLabel(String key) {
  return key
      .replaceAll("_", " ")
      .toUpperCase();
}


class DynamicField {
  final String key; // original json key
  final String label;
  String selectedValue;
  final List<String> alternatives;

  DynamicField({
    required this.key,
    required this.label,
    required this.selectedValue,
    required this.alternatives,
  });
}

