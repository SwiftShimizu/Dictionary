import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'modules/characters/character.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _apiUrl = "https://narutodb.xyz/api/character";
  final _limit = 15;
  final ScrollController _scrollController = ScrollController();
  List<Character> _characters = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent - 100 <
          _scrollController.offset) {
        _fetchCharacters();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCharacters() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final response = await Dio()
        .get(_apiUrl, queryParameters: {"page": _page, "limit": _limit});
    final List<dynamic> data = response.data["characters"];

    setState(() {
      _characters = [
        ..._characters,
        ...data.map((data) => Character.fromJson(data))
      ];
      _page++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFBCE2E8),
        title: const Text("NARUTO図鑑"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _characters.length,
          itemBuilder: (context, index) {
            final character = _characters[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: character.images.isNotEmpty
                        ? Image.network(
                            character.images[0],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Image(
                                  image: AssetImage("assets/dummy.png"));
                            },
                          )
                        : const Image(
                            image: AssetImage("assets/dummy.png"),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      character.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      character.debut?["appearsIn"]?.toString() ?? "なし",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
