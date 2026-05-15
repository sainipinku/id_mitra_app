// To parse this JSON data, do
//
//     final stateModel = stateModelFromJson(jsonString);

import 'dart:convert';

StateModel stateModelFromJson(String str) => StateModel.fromJson(json.decode(str));

String stateModelToJson(StateModel data) => json.encode(data.toJson());

class StateModel {
  bool? status;
  String? message;
  List<States>? list;

  StateModel({
    this.status,
    this.message,
    this.list,
  });

  StateModel copyWith({
    bool? status,
    String? message,
    List<States>? list,
  }) =>
      StateModel(
        status: status ?? this.status,
        message: message ?? this.message,
        list: list ?? this.list,
      );

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
    status: json["status"],
    message: json["message"],
    list: json["list"] == null ? [] : List<States>.from(json["list"]!.map((x) => States.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
  };
}

class States {
  int? id;
  int? countryId;
  String? name;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  States({
    this.id,
    this.countryId,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  States copyWith({
    int? id,
    int? countryId,
    String? name,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic deletedAt,
  }) =>
      States(
        id: id ?? this.id,
        countryId: countryId ?? this.countryId,
        name: name ?? this.name,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  factory States.fromJson(Map<String, dynamic> json) => States(
    id: json["id"],
    countryId: json["country_id"],
    name: json["name"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "country_id": countryId,
    "name": name,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
