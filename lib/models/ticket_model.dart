// To parse this JSON data, do
//
//     final ticketResponse = ticketResponseFromJson(jsonString);

import 'dart:convert';

TicketResponse ticketResponseFromJson(String str) =>
    TicketResponse.fromJson(json.decode(str));

String ticketResponseToJson(TicketResponse data) => json.encode(data.toJson());

class TicketResponse {
  String message;
  TicketData data;

  TicketResponse({required this.message, required this.data});

  factory TicketResponse.fromJson(Map<String, dynamic> json) => TicketResponse(
    message: json["message"],
    data: TicketData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data.toJson()};
}

class TicketData {
  int userId;
  int scheduleId;
  int quantity;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  TicketData({
    required this.userId,
    required this.scheduleId,
    required this.quantity,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) => TicketData(
    userId: json["user_id"],
    scheduleId: json["schedule_id"],
    quantity: json["quantity"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "schedule_id": scheduleId,
    "quantity": quantity,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
  };
}
