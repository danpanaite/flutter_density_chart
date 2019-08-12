library flutter_density_chart;

import 'dart:math';

import 'package:flutter/material.dart';

class DensityChart extends StatefulWidget {
  final List<Point> points;

  const DensityChart({Key key, @required this.points}) : super(key: key);

  @override
  _DensityChartState createState() => _DensityChartState();
}

class _DensityChartState extends State<DensityChart> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RadarChartPainter(widget.points),
      size: Size(double.infinity, double.infinity),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<Point> points;

  RadarChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Painting the chart outline
    var outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var scatterPlotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.zero),
        outlinePaint);

    var xPoints = this.points.map((point) => point.x).toList()..sort();
    var xScale = size.width / (xPoints.last - xPoints.first);

    var yPoints = this.points.map((point) => point.y).toList()..sort();
    var yScale = size.height / (yPoints.last - yPoints.first);

    this.points.forEach((point) {
      var offset = Offset(
          (point.x - xPoints[0]) * xScale, (point.y - yPoints[0]) * yScale);

      canvas.drawCircle(offset, 8.0, scatterPlotPaint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
