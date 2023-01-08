import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _storage = const FlutterSecureStorage();

  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Homepage(),
        ),
      );
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController zipController = TextEditingController();

  void signUp(
    String name,
    String email,
    String password,
    String address,
    String city,
    String zip,
  ) async {
    try {
      final response = await post(
        Uri.parse('https://zbla.dev/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'address': address,
          'city': city,
          'zip': zip,
          'type': 'user',
        }),
      );

      print(response.body);

      final responseJson = jsonDecode(response.body);
      final token = responseJson['token'];

      final _storage = const FlutterSecureStorage();
      await _storage.write(key: 'token ', value: token);
      await _storage.write(
          key: 'id', value: responseJson['user']['id'].toString());

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Homepage(),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registracija'),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Ime in priimek',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'E-pošta',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                //hide text that is entered
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Geslo',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  hintText: 'Naslov',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  hintText: 'Mesto',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: zipController,
                decoration: const InputDecoration(
                  hintText: 'Poštna številka',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  signUp(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                    addressController.text,
                    cityController.text,
                    zipController.text,
                  );
                },
                child: const Text('Registracija'),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
