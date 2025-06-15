import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'scanner_page.dart'; 
import 'todayspatrons_page.dart';
import 'pending_incidents_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ID Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(), // Your full login form
        '/main': (context) => MainPage(),   // Placeholder for now
        '/scanner': (context) => ScannerPage(),
        '/patrons': (context) => TodaysPatronsPage(),
        '/incidents/pending': (context) => PendingIncidentsPage(),
      },
    );
  }
}

// Optional: still include MainPage as a placeholder for now
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scanner');
              },
              child: Text('Scan License'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/incidents/pending'); // Add this when incident list is ready
              },
              child: Text('View Incidents'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/patrons');
              },
              child: Text('Today\'s Patrons'),
            ),
          ],
        ),
      ),
    );
  }
}


