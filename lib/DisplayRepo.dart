import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisplayRepo extends StatefulWidget {
  const DisplayRepo({Key? key}) : super(key: key);

  @override
  State<DisplayRepo> createState() => _DisplayRepoState();
}

class _DisplayRepoState extends State<DisplayRepo> {
  Future<List<dynamic>> fetchRepositories() async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/freeCodeCamp/repos'),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> fetchLastCommit(
      String owner, String repository) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$owner/$repository/commits'),
    );
    return jsonDecode(response.body)[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urban Match Task'),
      ),
      body: FutureBuilder(
        future: fetchRepositories(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: fetchLastCommit(
                      snapshot.data[index]['owner']['login'],
                      snapshot.data[index]['name']),
                  builder: (context, AsyncSnapshot commitSnapshot) {
                    if (commitSnapshot.hasData) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                snapshot.data[index]['owner']['avatar_url']),
                          ),
                          title: Text(snapshot.data[index]['name']),
                          subtitle:
                              Text(commitSnapshot.data['commit']['message']),
                        ),
                      );
                    } else if (commitSnapshot.hasError) {
                      return Text('${commitSnapshot.error}');
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
