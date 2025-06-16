import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'scanner_page.dart'; 
import 'todayspatrons_page.dart';
import 'pending_incidents_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:id_tracker_app/services/current_user.dart';

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

  var currentUserRole = CurrentUser().role;

  @override
  Widget build(BuildContext context) {

    void _handleLogout(){
      CurrentUser().clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Main Page')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('ID Tracker Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            if(currentUserRole == 'Manager')
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Pending Incidents'),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/incidents/pending');
                },
              ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: (){
                _handleLogout();
              }
            ),
          ],
        ),
      ),
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
            if (currentUserRole == "manager")
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/incidents/pending'); // Add this when incident list is ready
                },
                child: Text('View Incidents'),
              ),
            if(currentUserRole == "manager")
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


