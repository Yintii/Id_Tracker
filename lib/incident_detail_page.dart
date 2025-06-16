
import 'package:flutter/material.dart';
import 'package:id_tracker_app/services/incident.dart';
import 'package:id_tracker_app/services/current_user.dart';

class IncidentDetailPage extends StatelessWidget {
  final Incident incident;

  const IncidentDetailPage({required this.incident});

  Future<void> _approveIncident(BuildContext context) async {
    final token = CurrentUser().token;
    final approverID = CurrentUser().userId;
    if (token == null) return;

    final success = await Incident.approveIncident(incident.id, approverID, token);
    if (success) Navigator.pop(context, true);
    else _showError(context, 'Failed to approve incident');
  }

  Future<void> _denyIncident(BuildContext context) async {
    final token = CurrentUser().token;
    final approverID = CurrentUser().userId;
    if (token == null) return;

    final success = await Incident.deleteIncident(incident.id, approverID, token);
    if (success) Navigator.pop(context, true);
    else _showError(context, 'Failed to delete incident');
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Incident #${incident.id}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: ${incident.type}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Description: ${incident.description}"),
            Text("Status: ${incident.status}"),
            Text("Occurred on: ${incident.dateOccurred.toLocal()}"),
            Text("Created at: ${incident.createdAt.toLocal()}"),
            Text("Reporter ID: ${incident.userId}"),
            Text("Patron ID: ${incident.patronId}"),
            if (incident.approvedBy != null)
              Text("Approved By: ${incident.approvedBy}"),
            if (incident.approvedAt != null)
              Text("Approved At: ${incident.approvedAt!.toLocal()}"),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _approveIncident(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () => _denyIncident(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Deny'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
