import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tixme/endpoint/base_url.dart';
import 'package:tixme/services/session_service.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';

class AuthService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Login user
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/login'),
        headers: _headers,
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        AuthPreferences.saveToken(token ?? '');
        return LoginResponse.fromJson(json.decode(response.body));
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } on FormatException {
      throw Exception('Invalid response format');
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Silakan periksa koneksi Anda.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // Register user
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/register'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RegisterResponse.fromJson(json.decode(response.body));
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } on FormatException {
      throw Exception('Invalid response format');
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Silakan periksa koneksi Anda.',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
