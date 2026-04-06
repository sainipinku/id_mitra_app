// To parse this JSON data, do
//
//     final cityModel = cityModelFromJson(jsonString);

import 'dart:convert';

CityModel cityModelFromJson(String str) => CityModel.fromJson(json.decode(str));

String cityModelToJson(CityModel data) => json.encode(data.toJson());

class CityModel {
    bool? status;
    String? message;
    List<City>? list;

    CityModel({
        this.status,
        this.message,
        this.list,
    });

    CityModel copyWith({
        bool? status,
        String? message,
        List<City>? list,
    }) =>
        CityModel(
            status: status ?? this.status,
            message: message ?? this.message,
            list: list ?? this.list,
        );

    factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        status: json["status"],
        message: json["message"],
        list: json["list"] == null ? [] : List<City>.from(json["list"]!.map((x) => City.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    };
}

class City {
    int? id;
    int? stateId;
    String? name;
    int? status;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;

    City({
        this.id,
        this.stateId,
        this.name,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    City copyWith({
        int? id,
        int? stateId,
        String? name,
        int? status,
        DateTime? createdAt,
        DateTime? updatedAt,
        dynamic deletedAt,
    }) =>
        City(
            id: id ?? this.id,
            stateId: stateId ?? this.stateId,
            name: name ?? this.name,
            status: status ?? this.status,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
            deletedAt: deletedAt ?? this.deletedAt,
        );

    factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"],
        stateId: json["state_id"],
        name: json["name"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "state_id": stateId,
        "name": name,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
    };
}
