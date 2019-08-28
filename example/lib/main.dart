import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_density_chart/flutter_density_chart.dart';
import 'package:http/http.dart' as http;

final httpClient = http.Client();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Density Chart Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Density Chart Example'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<List<Point>>(
                future: getSampleData(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 200),
                    child: HistogramDensityChart(points: snapshot.data),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Point>> getSampleData() async {
    final response = await httpClient.get('http://10.0.2.2:5000/');
    final dataJson = json.decode(response.body) as List;

    return dataJson
        .map((pointJson) =>
            Point(pointJson['x'] as double, pointJson['y'] as double))
        .toList();
  }
}
