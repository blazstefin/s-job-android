import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'liked_posts.dart';
import 'profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
    super.initState();
    fetchData();
  }

  void fetchData() async {
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

    final response = await http.get(Uri.parse('https://zbla.dev/api/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });
    final List<dynamic> items = json.decode(response.body);
    setState(() {
      _items = items.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('S-Job'),
          //button to go to liked jobs
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LikedJobsScreen()));
                },
                icon: const Icon(Icons.favorite)),
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
                    final response = await http.post(
                      Uri.parse('https://zbla.dev/api/like'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(
                          {'userId': _userId, 'jobId': _items[index]['id']}),
                    );
                  },
                ),
              ),
            );
          },
        ));
  }
}
