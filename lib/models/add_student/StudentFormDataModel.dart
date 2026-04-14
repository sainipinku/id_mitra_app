class StudentFormDataModel {
  final List<SessionOption> sessions;
  final List<ClassOption> classes;
  final List<HouseOption> houses;

  StudentFormDataModel({
    required this.sessions,
    required this.classes,
    required this.houses,
  });

  factory StudentFormDataModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return StudentFormDataModel(
      sessions: (data['sessions'] as List? ?? [])
          .map((e) => SessionOption.fromJson(e))
          .toList(),
      classes: (data['classes'] as List? ?? [])
          .map((e) => ClassOption.fromJson(e))
          .toList(),
      houses: (data['houses'] as List? ?? [])
          .map((e) => HouseOption.fromJson(e))
          .toList(),
    );
  }
}

class SessionOption {
  final int value;
  final String label;
  SessionOption({required this.value, required this.label});
  factory SessionOption.fromJson(Map<String, dynamic> json) =>
      SessionOption(value: json['value'], label: json['label'] ?? '');
}

class ClassOption {
  final int id;
  final String name;
  final String nameWithPrefix;
  final List<SectionOption> sections;
  final List<int> sectionsIds;
  ClassOption({required this.id, required this.name, required this.nameWithPrefix, this.sections = const [], this.sectionsIds = const []});
  factory ClassOption.fromJson(Map<String, dynamic> json) => ClassOption(
        id: json['id'],
        name: json['name'] ?? '',
        nameWithPrefix: json['name_withprefix'] ?? json['name'] ?? '',
        sections: (json['sections'] as List? ?? [])
            .map((s) => SectionOption.fromJson(s))
            .toList(),
        sectionsIds: (json['sections_ids'] as List? ?? [])
            .map((e) => e as int)
            .toList(),
      );
}

class SectionOption {
  final int id;
  final String name;
  SectionOption({required this.id, required this.name});
  factory SectionOption.fromJson(Map<String, dynamic> json) =>
      SectionOption(id: json['id'], name: json['name'] ?? '');
}

class HouseOption {
  final int id;
  final String name;
  HouseOption({required this.id, required this.name});
  factory HouseOption.fromJson(Map<String, dynamic> json) =>
      HouseOption(id: json['id'], name: json['name'] ?? '');
}
