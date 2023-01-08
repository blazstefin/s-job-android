import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Račun'),
      ),
      body: Container(
          child: Column(children: [
        IconButton(
          onPressed: () async {
            //forget id and token
            final _storage = const FlutterSecureStorage();
            await _storage.delete(key: 'token');
            await _storage.delete(key: 'id');
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ));
          },
          icon: const Icon(Icons.logout),
        ),
        const Text('Odjava'),
      ])),
    );
  }
}
