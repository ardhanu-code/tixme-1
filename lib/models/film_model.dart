import 'dart:convert';

// ===============================
// Decode dari JSON String
// ===============================
FilmListResponse filmListResponseFromJson(String str) =>
    FilmListResponse.fromJson(json.decode(str));

String filmListResponseToJson(FilmListResponse data) =>
    json.encode(data.toJson());

FilmDetailResponse filmDetailResponseFromJson(String str) =>
    FilmDetailResponse.fromJson(json.decode(str));

String filmDetailResponseToJson(FilmDetailResponse data) =>
    json.encode(data.toJson());

// ===============================
// FilmListResponse - untuk /films (List<Data>)
// ===============================
class FilmListResponse {
  String message;
  List<Data> data;

  FilmListResponse({required this.message, required this.data});

  factory FilmListResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing FilmListResponse from JSON: $json');

      final response = FilmListResponse(
        message: json["message"] ?? "",
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
      );

      print(
        'Successfully parsed FilmListResponse with ${response.data.length} films',
      );
      return response;
    } catch (e, stackTrace) {
      print('Error parsing FilmListResponse: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

// ===============================
// FilmDetailResponse - untuk /films/{id} (Data tunggal)
// ===============================
class FilmDetailResponse {
  String message;
  Data data;

  FilmDetailResponse({required this.message, required this.data});

  factory FilmDetailResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing FilmDetailResponse from JSON: $json');

      final response = FilmDetailResponse(
        message: json["message"] ?? "",
        data: Data.fromJson(json["data"]),
      );

      print(
        'Successfully parsed FilmDetailResponse for film: ${response.data.title}',
      );
      return response;
    } catch (e, stackTrace) {
      print('Error parsing FilmDetailResponse: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

// ===============================
// Data - Film object
// ===============================
class Data {
  int id;
  String title;
  String description;
  String genre;
  String director;
  String writer;
  String stats;
  String imageUrl;
  String imagePath;

  Data({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.director,
    required this.writer,
    required this.stats,
    required this.imageUrl,
    required this.imagePath,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    try {
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

      // Debug logging
      print('Parsing Data from JSON: $json');

      final data = Data(
        id: parseId(json["id"]),
        title: parseString(json["title"]),
        description: parseString(json["description"]),
        genre: parseString(json["genre"]),
        director: parseString(json["director"]),
        writer: parseString(json["writer"]),
        stats: parseString(json["stats"]),
        imageUrl: parseString(json["image_url"]),
        imagePath: parseString(json["image_path"]),
      );

      print('Successfully parsed Data: ${data.id} - ${data.title}');
      return data;
    } catch (e, stackTrace) {
      print('Error parsing Data: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "genre": genre,
    "director": director,
    "writer": writer,
    "stats": stats,
    "image_url": imageUrl,
    "image_path": imagePath,
  };
}
