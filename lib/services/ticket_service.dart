import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tixme/endpoint/base_url.dart';

class TicketService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _getAuthHeaders(String token) {
    return {..._headers, 'Authorization': 'Bearer $token'};
  }

  // Get user tickets by status
  Future<Map<String, dynamic>> getUserTickets(
    String token, {
    String? status,
  }) async {
    try {
      String url = '${Endpoint.baseUrl}/tickets';
      if (status != null) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch tickets');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  // Get ticket by ID
  Future<Map<String, dynamic>> getTicketById(int ticketId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/tickets/$ticketId'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch ticket');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  // Cancel ticket
  Future<Map<String, dynamic>> cancelTicket(
    int scheduleId,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${Endpoint.baseUrl}/tickets/$scheduleId'),
        headers: _getAuthHeaders(token),
        body: json.encode({'status': 'cancelled'}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to cancel ticket');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> bookTicket({
    required int scheduleId,
    required int quantity,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/tickets'),
        headers: _getAuthHeaders(token),
        body: json.encode({'schedule_id': scheduleId, 'quantity': quantity}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to book ticket');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTicketSchedule({
    required int ticketId,
    required int newScheduleId,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${Endpoint.baseUrl}/tickets/$ticketId'),
        headers: _getAuthHeaders(token),
        body: json.encode({'schedule_id': newScheduleId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengubah jadwal tiket');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Format respon tidak valid');
      }
      rethrow;
    }
  }
}
