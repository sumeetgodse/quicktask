import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:quicktask/register.dart';
import 'package:quicktask/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    try {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => QuickTaskApp()));
    } catch (e) {
      print('Login Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('QuickTask - Login',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0))),
          backgroundColor: Color.fromARGB(255, 255, 197, 38),
          centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 40,
            ),
            Center(
              child: const Text('QuickTask',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0))),
            ),
            SizedBox(
              height: 2,
            ),
            Center(
              child: const Text(
                  'Conquer Your Tasks, One at a Time with QuickTask!',
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 66, 66, 66))),
            ),
            SizedBox(
              height: 26,
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(
              height: 26,
            ),
            ElevatedButton(
              onPressed: () => _login(),
              child: const Text('Login'),
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                  foregroundColor:
                      WidgetStateProperty.all<Color>(Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text('New User? Click here to Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      final user = ParseUser(username, password, null);
      var response = await user.login();

      if (response.success) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => QuickTaskApp()));
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Login failed: ${response.error!.message}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
