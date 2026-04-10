class StudentFormFieldsModel {
  final List<StudentFormField> studentFormFields;
  final List<StudentFormField> availableStudentFormFields;
  final String schoolName;

  StudentFormFieldsModel({
    required this.studentFormFields,
    required this.availableStudentFormFields,
    required this.schoolName,
  });

  /// Handles both:
  /// 1. Inertia response: { "props": { "school": { "student_form_fields": [...], "available_student_form_fields": [...] } } }
  /// 2. Direct API response: { "data": { "student_form_fields": [...], "available_student_form_fields": [...] } }
  factory StudentFormFieldsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> school = {};

    if (json.containsKey('props')) {
      // Inertia web response
      school = json["props"]?["school"] ?? {};
    } else if (json.containsKey('data')) {
      // Direct API response
      school = json["data"] ?? {};
    } else {
      school = json;
    }

    final List current   = school["student_form_fields"] ?? [];
    final List available = school["available_student_form_fields"] ?? [];

    return StudentFormFieldsModel(
      schoolName: school["name"] ?? '',
      studentFormFields:
          current.map((e) => StudentFormField.fromJson(e)).toList(),
      availableStudentFormFields:
          available.map((e) => StudentFormField.fromJson(e)).toList(),
    );
  }
}

class StudentFormField {
  final String name;
  final String label;
  final String group;
  final String groupLabel;
  final String type;
  final bool required;
  final int order;

  StudentFormField({
    required this.name,
    required this.label,
    required this.group,
    required this.groupLabel,
    required this.type,
    required this.required,
    required this.order,
  });

  factory StudentFormField.fromJson(Map<String, dynamic> json) {
    return StudentFormField(
      name:       json["name"]        ?? '',
      label:      json["label"]       ?? '',
      group:      json["group"]       ?? '',
      groupLabel: json["group_label"] ?? '',
      type:       json["type"]        ?? 'text',
      required:   json["required"]    ?? false,
      order:      json["order"]       ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "name":        name,
    "label":       label,
    "group":       group,
    "group_label": groupLabel,
    "type":        type,
    "required":    required,
    "order":       order,
  };
}
