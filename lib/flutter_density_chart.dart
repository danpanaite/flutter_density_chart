library flutter_density_chart;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector3;

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

class KernelDensityEstimationChart extends StatelessWidget {
  final List<Vector3> points;

  const KernelDensityEstimationChart({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Point> points2D =
        this.points.map((point) => Point(point.x, point.y)).toList();

    return CustomPaint(
      painter: KernelDensityEstimationPainter(this.points),
      size: Size(double.infinity, double.infinity),
      child: CustomPaint(
        painter: DensityOutlineChartPainter(points2D),
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
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    var xPoints = this.points.map((point) => point.x).toList()..sort();
    var xScale = size.width / (xPoints.last - xPoints.first);
    var xTicks = List.generate((xPoints.last - xPoints.first).floor(),
        (i) => Offset((i + 1) * xScale, size.height));

    xTicks.asMap().forEach((index, tick) {
      var tickLabel = (xPoints.first + index).floor().toString();

      canvas.drawLine(tick, Offset(tick.dx, size.height + 10), outlinePaint);

      TextPainter(
        text: TextSpan(
          text: tickLabel,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(
            canvas, Offset(tick.dx - 4 * tickLabel.length, size.height + 10));
    });

    var yPoints = this.points.map((point) => point.y).toList()..sort();
    var yScale = size.height / (yPoints.last - yPoints.first);
    var yTicks = List.generate((yPoints.last - yPoints.first).floor(),
        (i) => Offset(0, (i + 1) * yScale));

    yTicks.asMap().forEach((index, tick) {
      var tickLabel = (yPoints.first + index).floor().toString();

      canvas.drawLine(tick, Offset(-10, tick.dy), outlinePaint);

      TextPainter(
        text: TextSpan(
          text: tickLabel,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(canvas, Offset(-15 - 4.0 * tickLabel.length, tick.dy - 7));
    });

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
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    getOffsetsForCanvas(size)
        .forEach((offset) => canvas.drawCircle(offset, 4.0, scatterPlotPaint));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class KernelDensityEstimationPainter extends DensityPlot3Painter {
  final List<Vector3> points;

  KernelDensityEstimationPainter(this.points) : super(points);

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width / sqrt(this.points.length);
    var height = size.height / sqrt(this.points.length) * 1.1;

    getScaledPointsForCanvas(size).forEach((point) {
      var color = Color.lerp(Colors.white, Colors.blue, point.z);

      var paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      //canvas.drawRect(Rect.fromCenter(center: Offset(point.x, point.y), width: width, height: height), paint);
      canvas.drawCircle(Offset(point.x, point.y), width, paint);
    });
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

    return this
        .points
        .map((point) => Offset((point.x - xPoints.first) * xScale,
            (point.y - yPoints.first) * yScale))
        .toList();
  }
}

abstract class DensityPlot3Painter extends CustomPainter {
  final List<Vector3> points;

  DensityPlot3Painter(this.points);

  List<Vector3> getScaledPointsForCanvas(Size size) {
    var xPoints = this.points.map((point) => point.x).toList()..sort();
    var xScale = size.width / (xPoints.last - xPoints.first);

    var yPoints = this.points.map((point) => point.y).toList()..sort();
    var yScale = size.height / (yPoints.last - yPoints.first);

    var zPoints = this.points.map((point) => point.z).toList()..sort();
    var zScale = 1 / (zPoints.last - zPoints.first);

    return this.points.map((point) {
      return Vector3((point.x - xPoints[0]) * xScale,
          (point.y - yPoints[0]) * yScale, point.z * zScale);
    }).toList();
  }
}
