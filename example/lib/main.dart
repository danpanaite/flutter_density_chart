import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_density_chart/flutter_density_chart copy.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math.dart' show Vector2, Vector3;

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
        title: Text('Density Chart Example'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 150),
        // child: FutureBuilder<List<Vector2>>(
        //   future: getSampleData(),
        //   builder: (context, snapshot) {
        //     return ScatterPlotChart(points: snapshot.data);
        //   },
        // ),
        // child: Stack(
        //   children: [
        //     FutureBuilder<List<Vector3>>(
        //       future: getKDESampleDataOffline(),
        //       builder: (context, snapshot) {
        //         return KernelDensityEstimationChart(points: snapshot.data);
        //       },
        //     ),
        //     FutureBuilder<List<Vector2>>(
        //       future: getSampleData(),
        //       builder: (context, snapshot) {
        //         return ScatterPlotChart(points: snapshot.data);
        //       },
        //     ),
        //   ],
        // ),

        //            return GradientChart(values: snapshot.data.map((p) => p.z * 100).toList());
        // child: FutureBuilder<List<Vector3>>(
        //   future: getKDESampleDataOffline(),
        //   builder: (context, snapshot) {
        //     return KernelDensityEstimationChart(points: snapshot.data);
        //   },
        // ),

        child: FutureBuilder<ContourData>(
          future: getContourSampleDataOffline(),
          builder: (context, snapshot) {
            return ContourChart(
              points: snapshot.data.kdeData,
              contours: snapshot.data.contourData,
            );
          },
        ),
      ),
    );
  }

  Future<List<Vector2>> getSampleData() async {
    final data =
        await rootBundle.loadString('assets/sample_gaussian_data.json');
    final dataJson = json.decode(data) as List;

    return dataJson
        .map((pointJson) =>
            Vector2(pointJson['x'] as double, pointJson['y'] as double))
        .toList();
  }

  // Future<List<Point>> getSampleData() async {
  //   final response = await httpClient.get('http://10.0.2.2:5000/');
  //   final dataJson = json.decode(response.body) as List;

  //   return dataJson
  //       .map((pointJson) =>
  //           Point(pointJson['x'] as double, pointJson['y'] as double))
  //       .toList();
  // }

  Future<List<Point>> getKDESampleData() async {
    final response = await httpClient.get('http://10.0.2.2:5000/kde');
    final dataJson = json.decode(response.body) as List;

    return dataJson
        .map((pointJson) =>
            Point(pointJson['x'] as double, pointJson['y'] as double))
        .toList();
  }

  Future<List<Vector3>> getKDESampleDataOffline() async {
    final data = await rootBundle.loadString('assets/sample_data.json');
    final dataJson = json.decode(data) as List;

    return dataJson
        .map((pointJson) => Vector3(pointJson['x'] as double,
            pointJson['y'] as double, pointJson['z'] as double))
        .toList();
  }

  Future<ContourData> getContourSampleDataOffline() async {
    final kdeData = await rootBundle.loadString('assets/sample_data.json');
    final kdeDataJson = json.decode(kdeData) as List;

    final contourData =
        await rootBundle.loadString('assets/sample_contour_data.json');
    final contourDataJson = json.decode(contourData) as List;

    return ContourData(
      kdeData: kdeDataJson
          .map((pointJson) => Vector3(pointJson['x'] as double,
              pointJson['y'] as double, pointJson['z'] as double))
          .toList(),
      contourData: contourDataJson
          .map((contourPathJson) => (contourPathJson as List).map((pointJson) =>
              Vector2(pointJson['x'] as double, pointJson['y'] as double)).toList())
          .toList(),
    );
  }
}

class ContourData {
  final List<Vector3> kdeData;
  final List<List<Vector2>> contourData;

  ContourData({this.kdeData, this.contourData});
}
