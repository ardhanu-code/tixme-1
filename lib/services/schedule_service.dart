import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tixme/endpoint/base_url.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _getAuthHeaders(String token) {
    return {..._headers, 'Authorization': 'Bearer $token'};
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  Future<JadwalResponse> getSchedules(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/schedules'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return JadwalResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch schedules');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<List<ScheduleData>> getSchedulesByFilmId(
    int filmId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/schedules?film_id=$filmId'),
        headers: _getAuthHeaders(token),
      );

      print('Schedule API Response Status: ${response.statusCode}');
      print('Schedule API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle different response formats
        if (responseData['data'] != null) {
          if (responseData['data'] is List) {
            return (responseData['data'] as List)
                .map((item) => ScheduleData.fromJson(item))
                .toList();
          } else if (responseData['data'] is Map) {
            // Single schedule
            return [ScheduleData.fromJson(responseData['data'])];
          }
        } else if (responseData is List) {
          // Direct list response
          return responseData
              .map((item) => ScheduleData.fromJson(item))
              .toList();
        }

        // If no valid data found, return empty list
        return [];
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch schedules');
      }
    } catch (e) {
      print('Schedule API Error: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<JadwalResponse> getScheduleById(int scheduleId) async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/schedules/$scheduleId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return JadwalResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch schedule');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<JadwalResponse> createSchedule({
    required int filmId,
    required DateTime startTime,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/schedules'),
        headers: _getAuthHeaders(token),
        body: json.encode({
          'film_id': filmId,
          'start_time': _formatDateTime(startTime),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return JadwalResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create schedule');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<JadwalResponse> updateSchedule({
    required int scheduleId,
    int? filmId,
    DateTime? startTime,
    required String token,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (filmId != null) updateData['film_id'] = filmId;
      if (startTime != null)
        updateData['start_time'] = _formatDateTime(startTime);

      final response = await http.put(
        Uri.parse('${Endpoint.baseUrl}/schedules/$scheduleId'),
        headers: _getAuthHeaders(token),
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        return JadwalResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update schedule');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<void> deleteSchedule(int scheduleId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${Endpoint.baseUrl}/schedules/$scheduleId'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete schedule');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }
}
