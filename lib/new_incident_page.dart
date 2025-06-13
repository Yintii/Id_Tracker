import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:id_tracker_app/services/current_user.dart';

class NewIncidentPage extends StatefulWidget {
  final String patronId;
  final String patronName;

  NewIncidentPage({required this.patronId, required this.patronName});

  @override
  _NewIncidentPageState createState() => _NewIncidentPageState();
}

class _NewIncidentPageState extends State<NewIncidentPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _baseUrl = 'https://b6d4-2603-8001-58f0-7770-7462-3dc3-ab69-e46f.ngrok-free.app';

  String? _incidentType;
  bool _submitting = false;
  String? _errorMessage;
  String? _successMessage;

  final List<String> _incidentTypes = ['Dine&Dash', 'Violent Behavior', 'Theft'];

  Future<void> _submitIncident() async {
    if (!_formKey.currentState!.validate() || _incidentType == null) {
      setState(() {
        _errorMessage = 'Please select an incident type and provide details.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final int? userID = CurrentUser().userId;
    final String? token = CurrentUser().token;

    if (userID == null || token == null) {
      setState(() {
        _errorMessage = 'Missing user credentials.';
        _submitting = false;
      });
      return;
    }

    final url = Uri.parse("$_baseUrl/patrons/${widget.patronId}/create_incident");

    debugPrint("userID: $userID - is an int ${userID is int}");
    debugPrint("patronID: ${widget.patronId} is an int ${widget.patronId is int}");


    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "user_id": userID,
          "patron_id": int.parse(widget.patronId),
          "type": _incidentType,
          "description": _commentController.text.trim(),
          "status": "Pending", // you can define default status
          "date_occurred": DateTime.now().toUtc().toIso8601String(), // ISO 8601 for Go `time.Time`
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = "Incident reported successfully.";
          _commentController.clear();
          _incidentType = null;
        });
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['error']?.toString() ?? 'Unknown error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Incident: ${widget.patronName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _submitting
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Type'),
                      value: _incidentType,
                      items: _incidentTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _incidentType = value);
                      },
                      validator: (value) =>
                          value == null ? 'Please choose an incident type' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Comments',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Please enter some comments'
                          : null,
                    ),
                    SizedBox(height: 20),
                    if (_errorMessage != null)
                      Text(_errorMessage!,
                          style: TextStyle(color: Colors.red)),
                    if (_successMessage != null)
                      Text(_successMessage!,
                          style: TextStyle(color: Colors.green)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitIncident,
                      child: Text('Submit Incident'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
