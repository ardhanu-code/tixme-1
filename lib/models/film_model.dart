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

  factory FilmListResponse.fromJson(Map<String, dynamic> json) =>
      FilmListResponse(
        message: json["message"],
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
      );

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

  factory FilmDetailResponse.fromJson(Map<String, dynamic> json) =>
      FilmDetailResponse(
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data.toJson(),
  };
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    genre: json["genre"],
    director: json["director"],
    writer: json["writer"],
    stats: json["stats"],
    imageUrl: json["image_url"] ?? '',
    imagePath: json["image_path"] ?? '',
  );

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
