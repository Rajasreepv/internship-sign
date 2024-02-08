import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_share/whatsapp_share.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:social_share/social_share.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

void main() {
  runApp(myApp());
}

class myApp extends StatefulWidget {
  const myApp({super.key});

  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final scrollController = ScrollController();
  List<dynamic> POSTS = [];
  int page = 1;
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrolllistener);
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Assignment",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            controller: scrollController,
            itemCount: POSTS.length,
            itemBuilder: (context, index) {
              final user = POSTS[index];
              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: ListTile(
                    title: Text(
                      user['title']['rendered'],
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Image.network(
                      user['jetpack_featured_media_url'],
                      height: 200,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    trailing: IconButton(
                        onPressed: () async {
                          String imageUrl = user['jetpack_featured_media_url'];
                          String imagePath = await _downloadImage(imageUrl);

                          SocialShare.shareOptions("Hello world",
                              imagePath: imagePath);
                        },
                        icon: Icon(Icons.share))),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<String> _downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final documentDirectory = await getTemporaryDirectory();
    final file = File('${documentDirectory.path}/image.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<void> fetchdata() async {
    final String baseUrl =
        'https://techcrunch.com/wp-json/wp/v2/posts?context=embed&per_page=15&page=$page';

    final uri = Uri.parse('$baseUrl');

    final response = await http.get(
      uri,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List;

      setState(() {
        POSTS = POSTS + jsonData;
      });
    } else {
      print('Failed to fetch user data. ${response.statusCode}');
    }
  }

  void _scrolllistener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      page = page + 1;
      fetchdata();
    } else {
      print("no sc");
    }
  }
}
