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

  factory JadwalResponse.fromJson(Map<String, dynamic> json) {
    List<ScheduleData> parseData(dynamic data) {
      if (data == null) return [];

      if (data is List) {
        return data.map((x) => ScheduleData.fromJson(x)).toList();
      } else if (data is Map<String, dynamic>) {
        // Single schedule object
        return [ScheduleData.fromJson(data)];
      }

      return [];
    }

    return JadwalResponse(
      message: json["message"] ?? "",
      data: parseData(json["data"]),
    );
  }

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
  int quantity;
  Data? film; // Tambahkan ini

  ScheduleData({
    required this.filmId,
    required this.startTime,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.quantity,
    this.film,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    // Safe parsing for film_id
    int parseFilmId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Safe parsing for id
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Safe parsing for quantity
    int parseQuantity(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Safe parsing for DateTime
    DateTime parseDateTime(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Failed to parse DateTime from string: $value');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return ScheduleData(
      filmId: parseFilmId(json["film_id"]),
      startTime: parseDateTime(json["start_time"]),
      updatedAt: parseDateTime(json["updated_at"]),
      createdAt: parseDateTime(json["created_at"]),
      id: parseId(json["id"]),
      quantity: parseQuantity(json["quantity"] ?? 0),
      film: json["film"] != null ? Data.fromJson(json["film"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "film_id": filmId,
    "start_time": startTime.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
    "quantity": quantity,
    "film": film?.toJson(),
  };
}
