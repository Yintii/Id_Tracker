import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:id_tracker_app/services/current_user.dart';
import 'package:id_tracker_app/services/incident.dart';
import 'incident_detail_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PendingIncidentsPage extends StatefulWidget {
  @override
  _PendingIncidentsPageState createState() => _PendingIncidentsPageState();
}

class _PendingIncidentsPageState extends State<PendingIncidentsPage> {
  final String? _baseUrl = dotenv.env['API_BASE_URL'];
  List<Incident> _incidents = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    final token = CurrentUser().token;

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/incidents/pending"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _incidents = data.map((json) => Incident.fromJson(json)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load incidents: ${response.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pending Incidents")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  itemCount: _incidents.length,
                  itemBuilder: (context, index) {
                    final inc = _incidents[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(inc.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Reporter ID: ${inc.userId}"),
                            Text("Patron ID: ${inc.patronId}"),
                            Text("Occurred: ${inc.dateOccurred.toLocal()}"),
                            Text("Status: ${inc.status}"),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncidentDetailPage(incident: inc),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
