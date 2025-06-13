import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'new_incident_page.dart';


class TodaysPatronsPage extends StatefulWidget {
  @override
  _TodaysPatronsPageState createState() => _TodaysPatronsPageState();
}

class _TodaysPatronsPageState extends State<TodaysPatronsPage> {
  final url = 'b6d4-2603-8001-58f0-7770-7462-3dc3-ab69-e46f.ngrok-free.app';
  List<Map<String, dynamic>> _patrons = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTodaysPatrons();
  }

  Future<void> _fetchTodaysPatrons() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('https://$url/todays_patrons');
      debugPrint('📡 Sending GET request to $uri');

      final response = await http.get(uri);
      debugPrint('📬 Response status: ${response.statusCode}');
      debugPrint('📬 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _patrons = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
        debugPrint('✅ Loaded ${_patrons.length} patrons.');
      } else {
        final Map<String, dynamic>? errorJson =
            jsonDecode(response.body) as Map<String, dynamic>?;
        final errorDetail = errorJson?['error'] ?? 'Unexpected server response';
        setState(() {
          _errorMessage = 'Server error: $errorDetail';
          _loading = false;
        });
        debugPrint('❌ Server error detail: $errorDetail');
      }
    } catch (e, stacktrace) {
      setState(() {
        _errorMessage = 'Network or parsing error: $e';
        _loading = false;
      });
      debugPrint('❌ Exception: $e');
      debugPrint('🧱 Stacktrace: $stacktrace');
    }
  }

  Future<void> _reportIncident(BuildContext context, Map<String, dynamic> patron) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make incident report?'),
        content: Text(
            'Do you want to create an incident report for ${patron['first_name']} ${patron['last_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Navigate to new incident report page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NewIncidentPage(patronId: patron['id'].toString(), patronName: "${patron['first_name']} ${patron['last_name']}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Today's Patrons")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : _patrons.isEmpty
                  ? Center(child: Text('No patrons found for today.'))
                  : ListView.builder(
                      itemCount: _patrons.length,
                      itemBuilder: (context, index) {
                        final patron = _patrons[index];
                        return Dismissible(
                          key: Key(patron['id'].toString()),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            await _reportIncident(context, patron);
                            return false; // Prevent actual dismissal (we're only using swipe to trigger)
                          },
                          background: Container(
                            color: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.report, color: Colors.white),
                          ),
                          child: ListTile(
                            title: Text(
                                "${patron['first_name']} ${patron['last_name']}"),
                            subtitle: Text("DOB: ${patron['dob']}"),
                          ),
                        );
                      },
                    ),
    );
  }
}
