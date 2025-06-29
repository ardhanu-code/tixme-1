// To parse this JSON data, do
//
//     final jadwalResponse = jadwalResponseFromJson(jsonString);

import 'dart:convert';

import 'package:tixme/models/film_model.dart';

JadwalResponse jadwalResponseFromJson(String str) =>
    JadwalResponse.fromJson(json.decode(str));

String jadwalResponseToJson(JadwalResponse data) => json.encode(data.toJson());

class JadwalResponse {
  String message;
  List<ScheduleData> data;

  JadwalResponse({required this.message, required this.data});

  factory JadwalResponse.fromJson(Map<String, dynamic> json) => JadwalResponse(
    message: json["message"],
    data: List<ScheduleData>.from(
      (json["data"] ?? []).map((x) => ScheduleData.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ScheduleData {
  int filmId;
  DateTime startTime;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  Data? film; // Tambahkan ini

  ScheduleData({
    required this.filmId,
    required this.startTime,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    this.film,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) => ScheduleData(
        filmId: int.parse(json["film_id"].toString()),
        startTime: DateTime.parse(json["start_time"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        id: int.parse(json["id"].toString()),
        film: json["film"] != null ? Data.fromJson(json["film"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "film_id": filmId,
        "start_time": startTime.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "id": id,
        "film": film?.toJson(),
      };
}