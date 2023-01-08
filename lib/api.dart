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
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        categoryIcons[_items[index]['category_id']] ??
                            Icons.work,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      _items[index]['title'],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          categories[_items[index]['category_id']] ??
                              'No category',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        Text(
                          provinces[_items[index]['province_id']] ??
                              'No province',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        buildContactInfo(context, _items[index]),
                      ],
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          ((double.parse(_items[index]['salary']) * 1.18)
                                      .roundToDouble())
                                  .toStringAsFixed(2) +
                              ' €/h',
                          style:
                              Theme.of(context).textTheme.subtitle2?.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                    ),
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
                  )),
            );
          },
        ));
  }

  Widget buildContactInfo(BuildContext context, Map<String, dynamic> item) {
    if (item['contact_email'] != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${item['contact_person']}'),
          //row with email icon and email
          Row(
            children: [
              Icon(
                Icons.email,
                color: Colors.grey,
              ),
              Text(
                '${item['contact_email']}',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${item['contact_person']}'),
          //row with phone icon and phone number
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              Text(
                '${item['contact_phone']}',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ],
          ),
        ],
      );
    }
  }
}
