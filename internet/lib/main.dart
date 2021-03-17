import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

Future<ISSInfo> fetchISSInfo() async {
  Uri  url = Uri.parse("http://api.open-notify.org/iss-now");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return ISSInfo.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed');
  }
}

class ISSInfo {
  final String longitude;
  final String latitude;

  ISSInfo({required this.longitude, required this.latitude});

  factory ISSInfo.fromJson(Map<String, dynamic> json) {
    return ISSInfo(
      latitude: json["iss_position"]["latitude"],
      longitude: json["iss_position"]["longitude"],
    );
  }
}

class _MyAppState extends State<MyApp> {
  late Future<ISSInfo> infos;

  _createWidget(snapshot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Longitude\n"),
            Text("          \n"),
            Text("Latitude\n"),
          ],
        ),
        Row (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(snapshot.data!.longitude),
            Text("          \n"),
            Text(snapshot.data!.latitude),
          ],
        ),
        IconButton(icon: Icon(Icons.replay), onPressed: () {
          setState(() {
            infos = fetchISSInfo();
          });
        })
      ],
    );
  }

  _createScreen() {
    return FutureBuilder<ISSInfo>(
      future: fetchISSInfo(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return (_createWidget(snapshot));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISS Location',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ISS Location'),
        ),
        body: Center(
          child: _createScreen()
        ),
      ),
    );
  }
}