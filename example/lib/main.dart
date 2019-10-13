import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math.dart' show Vector2, Vector3;
import 'ice_rink.dart';

final httpClient = http.Client();
final baseUrl = 'https://c3384d8d.ngrok.io/shots';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        title: Text('Density Chart Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: <Widget>[
              getScatterPlotIceRinkChart(),
              getContourIceRinkChart(),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<List<Vector2>> getScatterPlotIceRinkChart() {
    return FutureBuilder<List<Vector2>>(
      future: getData('COL'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        return IceRinkChart(points: snapshot.data);
      },
    );
  }

  FutureBuilder<ContourData> getContourIceRinkChart() {
    return FutureBuilder<ContourData>(
      future: getKDEWithContourData('VGK', 50),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        return IceRinkDensityChart(
          points: snapshot.data.kdeData,
          contours: snapshot.data.contourData,
        );
      },
    );
  }

  Future<List<Vector2>> getData(String teamCode) async {
    final response = await httpClient.get('$baseUrl?team=$teamCode');
    final dataJson = json.decode(response.body) as List;

    return dataJson.map((pointJson) {
      var x = pointJson['x'] as double;
      var y = pointJson['y'] as double;

      return Vector2(x, y);
    }).toList();
  }

  Future<ContourData> getKDEWithContourData(
      String teamCode, int divisions) async {
    var kdeData = await getKDEData(teamCode, divisions);
    var contourData = await getContourData(teamCode, divisions);

    return ContourData(contourData: contourData, kdeData: kdeData);
  }

  Future<List<Vector3>> getKDEData(String teamCode, int divisions) async {
    final response = await httpClient
        .get('$baseUrl/kde?team=$teamCode&divisions=$divisions');
    final dataJson = json.decode(response.body) as List;

    return dataJson.map((pointJson) {
      var x = pointJson['x'] as double;
      var y = pointJson['y'] as double;
      var z = pointJson['z'] as double;

      return Vector3(x, y, z);
    }).toList();
  }

  Future<List<List<Vector2>>> getContourData(
      String teamCode, int divisions) async {
    final response = await httpClient
        .get('$baseUrl/kde/contour?team=$teamCode&divisions=$divisions');
    final dataJson = json.decode(response.body) as List;

    return dataJson
        .map((contourPathJson) => (contourPathJson as List)
            .map((pointJson) =>
                Vector2(pointJson['x'] as double, pointJson['y'] as double))
            .toList())
        .toList();
  }
}

class ContourData {
  final List<Vector3> kdeData;
  final List<List<Vector2>> contourData;

  ContourData({this.kdeData, this.contourData});
}
