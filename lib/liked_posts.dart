import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_application_1/profile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LikedJobsScreen extends StatefulWidget {
  const LikedJobsScreen({super.key});
  @override
  State<LikedJobsScreen> createState() => _LikedJobsScreenState();
  static const String routeName = '/liked';
}

class _LikedJobsScreenState extends State<LikedJobsScreen> {
  List<Map<String, dynamic>> _items = [];
  Map<int, String> categories = {};
  Map<int, String> provinces = {};
  Map<int, IconData> categoryIcons = {
    1: Icons.local_cafe,
    2: Icons.shopping_cart,
    3: Icons.code,
    4: Icons.build,
    5: Icons.nature,
    6: Icons.people,
    7: Icons.headset_mic,
    8: Icons.person_add,
    9: Icons.lightbulb_outline,
    10: Icons.work,
    11: Icons.art_track,
    12: Icons.local_hospital,
    13: Icons.school,
    14: Icons.pets,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final storage = FlutterSecureStorage();
    String? userId = await storage.read(key: 'id');
    print(userId);
    final response = await http
        .get(Uri.parse('https://zbla.dev/api/is-liked/$userId'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });
    final List<dynamic> items = json.decode(response.body);
    setState(() {
      _items = items.map((item) => item as Map<String, dynamic>).toList();
    });

    final responseCategories = await http
        .get(Uri.parse('https://zbla.dev/api/categories'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });
    final List<dynamic> itemsCategories = json.decode(responseCategories.body);
    for (var item in itemsCategories) {
      categories[item['id']] = item['name'];
    }

    final responseProvinces = await http
        .get(Uri.parse('https://zbla.dev/api/provinces'), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });
    final List<dynamic> itemsProvinces = json.decode(responseProvinces.body);
    for (var item in itemsProvinces) {
      provinces[item['id']] = item['name'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('S-Job'),
          //button to go to liked jobs
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
                icon: const Icon(Icons.person))
          ],
        ),
        body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(categoryIcons[_items[index]['category_id']] ??
                      Icons.work),
                  title: Text(_items[index]['title']),
                  subtitle: Text(
                      '${categories[_items[index]['category_id']]} - ${provinces[_items[index]['province_id']]}'),
                  trailing: Text(((double.parse(_items[index]['salary']) * 1.18)
                              .roundToDouble())
                          .toStringAsFixed(2) +
                      ' €/h'),
                  onTap: () async {
                    final storage = FlutterSecureStorage();
                    final _userId = await storage.read(key: 'id');
                    // Make the POST request to the API
                    final response = await http.post(
                      Uri.parse('https://zbla.dev/api/like'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(
                          {'userId': _userId, 'jobId': _items[index]['id']}),
                    );
                    fetchData();
                    // Check the status code of the respons
                  },
                ),
              ),
            );
          },
        ));
  }
}
