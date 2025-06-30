import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:tixme/endpoint/base_url.dart';
import 'package:tixme/services/session_service.dart';

import '../models/film_model.dart';

class FilmService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _getAuthHeaders(String token) {
    return {..._headers, 'Authorization': 'Bearer $token'};
  }

  Future<FilmListResponse> getFilms() async {
    try {
      final token = await AuthPreferences.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Unauthenticated: Token is null');
      }

      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/films'),
        headers: _getAuthHeaders(token),
      );
      print('RESPONSE BODY: ${response.body}');
      if (response.statusCode == 200) {
        return FilmListResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch films');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<FilmDetailResponse> getFilmById(int filmId) async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/films/$filmId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return FilmDetailResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch film');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<FilmDetailResponse> createFilm({
    required String title,
    required String description,
    required String genre,
    dynamic director,
    dynamic writer,
    dynamic stats,
    dynamic imageUrl,
    dynamic imagePath,
    required String token,
  }) async {
    try {
      String? imageBase64;

      if (imagePath != null && imagePath is String && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          imageBase64 = await _imageToBase64(imageFile);
        }
      }

      final Map<String, dynamic> filmData = {
        'title': title,
        'description': description,
        'genre': genre,
        'director': director,
        'writer': writer,
        'stats': stats,
      };

      if (imageBase64 != null) {
        filmData['image_base64'] = imageBase64;
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        filmData['image_url'] = imageUrl;
      }

      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/films'),
        headers: _getAuthHeaders(token),
        body: json.encode(filmData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FilmDetailResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create film');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<FilmDetailResponse> updateFilm({
    required int id,
    required String title,
    required String description,
    required String genre,
    dynamic director,
    dynamic writer,
    dynamic stats,
    dynamic imageUrl,
    dynamic imagePath,
    required String token,
  }) async {
    try {
      String? imageBase64;

      if (imagePath != null && imagePath is String && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          imageBase64 = await _imageToBase64(imageFile);
        }
      }

      final Map<String, dynamic> filmData = {
        'title': title,
        'description': description,
        'genre': genre,
        'director': director,
        'writer': writer,
        'stats': stats,
      };

      if (imageBase64 != null) {
        filmData['image_base64'] = imageBase64;
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        filmData['image_url'] = imageUrl;
      }

      final response = await http.put(
        Uri.parse('${Endpoint.baseUrl}/films/$id'),
        headers: _getAuthHeaders(token),
        body: json.encode(filmData),
      );

      if (response.statusCode == 200) {
        return FilmDetailResponse.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update film');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<void> deleteFilm(int filmId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${Endpoint.baseUrl}/films/$filmId'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete film');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<List<Data>> getNowPlayingFilms() async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/films'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final parsed = FilmListResponse.fromJson(json.decode(response.body));
        return parsed.data
            .where((film) => film.stats.toLowerCase() == 'now showing')
            .toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch now playing films',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<List<Data>> getComingSoonFilms() async {
    try {
      final response = await http.get(
        Uri.parse('${Endpoint.baseUrl}/films'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final parsed = FilmListResponse.fromJson(json.decode(response.body));
        return parsed.data
            .where((film) => film.stats.toLowerCase() == 'coming soon')
            .toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to fetch coming soon films',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }

  Future<String> _imageToBase64(File imageFile) async {
    try {
      Uint8List bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to convert image to base64: ${e.toString()}');
    }
  }

  Future<String> uploadImage(File imageFile, String token) async {
    try {
      String base64Image = await _imageToBase64(imageFile);

      final response = await http.post(
        Uri.parse('${Endpoint.baseUrl}/upload-image'),
        headers: _getAuthHeaders(token),
        body: json.encode({'image_base64': base64Image}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData['image_url'] ?? '';
      } else {
        throw Exception(responseData['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      rethrow;
    }
  }
}
