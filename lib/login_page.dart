import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:id_tracker_app/services/current_user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = FlutterSecureStorage();
  final url = 'b6d4-2603-8001-58f0-7770-7462-3dc3-ab69-e46f.ngrok-free.app';
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final _url = Uri.parse('https://$url/login');

    try {
      final response = await http.post(
        _url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final role = data['role'];

        final decodedToken = JwtDecoder.decode(token);

        CurrentUser().setUser(
          jwtToken: token,
          id: decodedToken['user_id'],
          userEmail: decodedToken['email'],
          userRole: role,
        );



        // Save token and role securely
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_role', value: role);

        // Navigate to main page
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login Failed';
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              enabled: !_isLoading,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
