import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'scanner_page.dart'; 
import 'todayspatrons_page.dart';

void main() {
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
                // Navigator.pushNamed(context, '/incidents'); // Add this when incident list is ready
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


