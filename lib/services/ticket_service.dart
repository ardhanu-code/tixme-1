import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tixme/endpoint/base_url.dart';
import 'package:tixme/models/ticket_model.dart';

class TicketService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _getAuthHeaders(String token) {
    return {..._headers, 'Authorization': 'Bearer $token'};
  }

  // Get user tickets
  Future<List<TicketData>> getUserTickets(String token) async {
    try {
      print('Fetching tickets from: ${Endpoint.baseUrl}/tickets');

      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/tickets'),
        headers: _getAuthHeaders(token),
      );

      print('Ticket API Response Status: ${response.statusCode}');
      print('Ticket API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Parsed ticket data: $responseData');

        // Handle different response formats
        if (responseData['data'] != null) {
          if (responseData['data'] is List) {
            final tickets = <TicketData>[];
            for (var item in responseData['data']) {
              try {
                tickets.add(TicketData.fromJson(item));
              } catch (e) {
                print('Error parsing ticket item: $e');
                print('Item data: $item');
              }
            }
            return tickets;
          } else if (responseData['data'] is Map) {
            // Single ticket
            try {
              return [TicketData.fromJson(responseData['data'])];
            } catch (e) {
              print('Error parsing single ticket: $e');
              return [];
            }
          }
        } else if (responseData is List) {
          // Direct list response
          final tickets = <TicketData>[];
          for (var item in responseData) {
            try {
              tickets.add(TicketData.fromJson(item));
            } catch (e) {
              print('Error parsing ticket item: $e');
              print('Item data: $item');
            }
          }
          return tickets;
        }

        return [];
      } else {
        final errorData = json.decode(response.body);
        print('Ticket API Error: $errorData');
        throw Exception(errorData['message'] ?? 'Failed to fetch tickets');
      }
    } catch (e) {
      print('Ticket Service Error: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  // Get ticket by ID
  Future<TicketData> getTicketById(int ticketId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/tickets/$ticketId'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return TicketData.fromJson(responseData['data']);
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
  Future<void> cancelTicket(int ticketId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${Endpoint.baseUrl}/tickets/$ticketId'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
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

  // Book ticket
  Future<TicketData> bookTicket({
    required int scheduleId,
    required int quantity,
    required String token,
  }) async {
    try {
      print('Booking ticket for schedule: $scheduleId, quantity: $quantity');

      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/tickets'),
        headers: _getAuthHeaders(token),
        body: json.encode({'schedule_id': scheduleId, 'quantity': quantity}),
      );

      print('Book ticket response status: ${response.statusCode}');
      print('Book ticket response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return TicketData.fromJson(responseData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to book ticket');
      }
    } catch (e) {
      print('Book ticket error: $e');
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  // Update ticket schedule
  Future<TicketData> updateTicketSchedule({
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
        final responseData = json.decode(response.body);
        return TicketData.fromJson(responseData['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update ticket schedule',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }
}
