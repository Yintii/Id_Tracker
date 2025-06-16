import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Incident {
  
  final int id;
  final int userId;
  final int patronId;
  final String description;
  final String status;
  final String type;
  final DateTime dateOccurred;
  final DateTime createdAt;
  final int? approvedBy;
  final DateTime? approvedAt;

  Incident({
    required this.id,
    required this.userId,
    required this.patronId,
    required this.description,
    required this.status,
    required this.type,
    required this.dateOccurred,
    required this.createdAt,
    this.approvedBy,
    this.approvedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json){
    return Incident(
      id: json['id'],
      userId: json['user_id'],
      patronId: json['patron_id'],
      description: json['description'],
      status: json['status'],
      type: json['type'],
      dateOccurred: DateTime.parse(json['date_occurred']),
      createdAt: DateTime.parse(json['created_at']),
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
        ? DateTime.parse(json['approved_at'])
        : null,
    );
  }

  Map<String, dynamic> toJson(){
    return{
      "user_id": userId,
      "patron_id": patronId,
      "description": description,
      "status": status,
      "type": type,
      "date_occurred": dateOccurred.toUtc().toIso8601String(),
      "created_at": createdAt.toUtc().toIso8601String(),
      "approved_by": approvedBy,
      "approved_at": approvedAt?.toUtc().toIso8601String(),
    };
  }

  static Future<bool> approveIncident(int id, int approvedBy, String token) async {
    final _baseUrl = dotenv.env['API_BASE_URL'];
    final response = await http.put(
      Uri.parse("$_baseUrl/incidents/$id/approve"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "id": id,
        "approved_by": approvedBy,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteIncident(int id, int approvedBy, String token) async {
    final _baseUrl = dotenv.env['API_BASE_URL'];
    final response = await http.delete(
      Uri.parse('$_baseUrl/incidents/$id'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({
        "id": id,
        "approved_by": approvedBy,
      }),
    );
    return response.statusCode == 200;
  }

}