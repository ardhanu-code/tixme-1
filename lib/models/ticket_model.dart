import 'dart:convert';

TicketResponse ticketResponseFromJson(String str) =>
    TicketResponse.fromJson(json.decode(str));

class TicketResponse {
  final String message;
  final List<TicketData> data;

  TicketResponse({required this.message, required this.data});

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing TicketResponse from JSON: $json');

      final response = TicketResponse(
        message: json["message"] ?? "",
        data: List<TicketData>.from(
          (json["data"] ?? []).map((x) => TicketData.fromJson(x)),
        ),
      );

      print(
        'Successfully parsed TicketResponse with ${response.data.length} tickets',
      );
      return response;
    } catch (e, stackTrace) {
      print('Error parsing TicketResponse: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class TicketData {
  final int id;
  final int userId;
  final int scheduleId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TicketScheduleData schedule;

  TicketData({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.schedule,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing TicketData from JSON: $json');

      // Safe parsing for integers
      int parseId(dynamic value) {
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

      final ticketData = TicketData(
        id: parseId(json["id"]),
        userId: parseId(json["user_id"]),
        scheduleId: parseId(json["schedule_id"]),
        quantity: parseId(json["quantity"]),
        createdAt: parseDateTime(json["created_at"]),
        updatedAt: parseDateTime(json["updated_at"]),
        schedule: TicketScheduleData.fromJson(json["schedule"] ?? {}),
      );

      print('Successfully parsed TicketData: ${ticketData.id}');
      return ticketData;
    } catch (e, stackTrace) {
      print('Error parsing TicketData: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class TicketScheduleData {
  final int id;
  final int filmId;
  final DateTime startTime;
  final TicketFilmData film;

  TicketScheduleData({
    required this.id,
    required this.filmId,
    required this.startTime,
    required this.film,
  });

  factory TicketScheduleData.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing TicketScheduleData from JSON: $json');

      // Safe parsing for integers
      int parseId(dynamic value) {
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

      final scheduleData = TicketScheduleData(
        id: parseId(json["id"]),
        filmId: parseId(json["film_id"]),
        startTime: parseDateTime(json["start_time"]),
        film: TicketFilmData.fromJson(json["film"] ?? {}),
      );

      print('Successfully parsed TicketScheduleData: ${scheduleData.id}');
      return scheduleData;
    } catch (e, stackTrace) {
      print('Error parsing TicketScheduleData: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class TicketFilmData {
  final int id;
  final String title;
  final String imageUrl;

  TicketFilmData({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory TicketFilmData.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing TicketFilmData from JSON: $json');

      // Safe parsing for id
      int parseId(dynamic value) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        if (value is double) return value.toInt();
        return 0;
      }

      // Safe parsing for strings
      String parseString(dynamic value) {
        if (value is String) return value;
        if (value != null) return value.toString();
        return '';
      }

      final filmData = TicketFilmData(
        id: parseId(json["id"]),
        title: parseString(json["title"]),
        imageUrl: parseString(json["image_url"]),
      );

      print(
        'Successfully parsed TicketFilmData: ${filmData.id} - ${filmData.title}',
      );
      return filmData;
    } catch (e, stackTrace) {
      print('Error parsing TicketFilmData: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }
}
