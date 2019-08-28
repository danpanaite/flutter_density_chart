library flutter_density_chart;

import 'dart:math';

import 'package:flutter/material.dart';

class ScatterPlotChart extends StatefulWidget {
  final List<Point> points;

  const ScatterPlotChart({Key key, @required this.points}) : super(key: key);

  @override
  _ScatterPlotChartState createState() => _ScatterPlotChartState();
}

class _ScatterPlotChartState extends State<ScatterPlotChart> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DensityOutlineChartPainter(widget.points),
      size: Size(double.infinity, double.infinity),
      child: CustomPaint(
        painter: ScatterPlotPainter(widget.points),
        size: Size(double.infinity, double.infinity),
      ),
    );
  }
}

class HistogramDensityChart extends StatefulWidget {
  final List<Point> points;

  const HistogramDensityChart({Key key, @required this.points})
      : super(key: key);

  @override
  _HistogramDensityChartState createState() => _HistogramDensityChartState();
}

class _HistogramDensityChartState extends State<HistogramDensityChart> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DensityOutlineChartPainter(widget.points),
      size: Size(double.infinity, double.infinity),
      child: CustomPaint(
        painter: HistogramDensityPainter(widget.points),
        size: Size(double.infinity, double.infinity),
      ),
    );
  }
}

class DensityOutlineChartPainter extends CustomPainter {
  final List<Point> points;

  DensityOutlineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    var outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.zero),
        outlinePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HistogramDensityPainter extends DensityPlotPainter {
  final List<Point> points;

  HistogramDensityPainter(this.points) : super(points);

  @override
  void paint(Canvas canvas, Size size) {
    var histogramBinPaint = Paint()..style = PaintingStyle.fill;

    var divisions = 20;
    var binWidth = size.width / divisions;
    var binHeight = size.height / divisions;

    var bins = List<List<int>>.generate(
        divisions, (i) => List<int>.generate(divisions, (j) => 0));

    var maxBinCount = 0;

    getOffsetsForCanvas(size).forEach((offset) {
      var xBin = min((offset.dx / binWidth).floor(), divisions - 1);
      var yBin = min((offset.dy / binHeight).floor(), divisions - 1);

      bins[xBin][yBin]++;

      maxBinCount =
          bins[xBin][yBin] > maxBinCount ? bins[xBin][yBin] : maxBinCount;
    });

    bins.asMap().forEach((rowIndex, row) {
      row.asMap().forEach((colIndex, col) {
        var left = binWidth * rowIndex;
        var top = binHeight * colIndex;
        var right = binWidth * (rowIndex + 1);
        var bottom = binHeight * (colIndex + 1);

        var color = Color.lerp(Colors.white, Colors.green, col / maxBinCount);

        canvas.drawRRect(RRect.fromLTRBR(left, top, right, bottom, Radius.zero),
            histogramBinPaint..color = color);
      });
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ScatterPlotPainter extends DensityPlotPainter {
  final List<Point> points;

  ScatterPlotPainter(this.points) : super(points);

  @override
  void paint(Canvas canvas, Size size) {
    var scatterPlotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    getOffsetsForCanvas(size)
        .forEach((offset) => canvas.drawCircle(offset, 8.0, scatterPlotPaint));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

abstract class DensityPlotPainter extends CustomPainter {
  final List<Point> points;

  DensityPlotPainter(this.points);

  List<Offset> getOffsetsForCanvas(Size size) {
    var xPoints = this.points.map((point) => point.x).toList()..sort();
    var xScale = size.width / (xPoints.last - xPoints.first);

    var yPoints = this.points.map((point) => point.y).toList()..sort();
    var yScale = size.height / (yPoints.last - yPoints.first);

    return this.points.map((point) {
      return Offset(
          (point.x - xPoints[0]) * xScale, (point.y - yPoints[0]) * yScale);
    }).toList();
  }
}
