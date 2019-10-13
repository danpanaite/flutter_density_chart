library flutter_density_chart;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector2, Vector3;

class ScatterPlotPainter extends CartesianPlotPainter {
  final List<Vector2> points;
  final Range defaultXRange;
  final Range defaultYRange;

  ScatterPlotPainter(this.points, {this.defaultXRange, this.defaultYRange})
      : super(
          points,
          defaultXRange: defaultXRange,
          defaultYRange: defaultXRange,
        );

  @override
  void paint(Canvas canvas, Size size) {
    var scatterPlotPaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..style = PaintingStyle.fill;

    getOffsetsForCanvas(size)
        .forEach((offset) => canvas.drawCircle(offset, 4.0, scatterPlotPaint));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HistogramDensityPainter extends CartesianPlotPainter {
  final List<Vector2> points;
  final int divisions;
  final List<Color> colors;
  final Range defaultXRange;
  final Range defaultYRange;

  HistogramDensityPainter(
    this.points, {
    this.defaultXRange,
    this.defaultYRange,
    this.divisions = 20,
    this.colors = const [Colors.white, Colors.green],
  }) : super(
          points,
          defaultXRange: defaultXRange,
          defaultYRange: defaultXRange,
        );

  @override
  void paint(Canvas canvas, Size size) {
    var histogramBinPaint = Paint()..style = PaintingStyle.fill;
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

        var color = getColor(colors, col / maxBinCount);

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

class KernelDensityEstimationPainter extends DensityPlotPainter {
  final List<Vector3> pointsWithDensity;
  final List<Color> colors;
  final Range defaultXRange;
  final Range defaultYRange;
  final Range defaultZRange;
  final Function clipRRect;

  KernelDensityEstimationPainter(
    this.pointsWithDensity, {
    this.colors = const [Colors.white, Colors.green],
    this.defaultXRange,
    this.defaultYRange,
    this.defaultZRange,
    this.clipRRect,
  }) : super(pointsWithDensity,
            defaultXRange: defaultXRange,
            defaultYRange: defaultYRange,
            defaultZRange: defaultZRange);

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width / sqrt(points.length);
    width += width / sqrt(points.length);

    var height = size.height / sqrt(points.length);
    height += height / sqrt(points.length);

    clipRRect(canvas, size);

    getOffsetsWithDensityForCanvas(size).forEach((point) {
      var color = getColor(colors, point.density);

      var paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRect(
          Rect.fromCenter(
            center: point.offset,
            width: width,
            height: height,
          ),
          paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ContourChart extends StatelessWidget {
  final List<List<Vector2>> contours;
  final Range defaultXRange;
  final Range defaultYRange;

  const ContourChart(
    this.contours, {
    Key key,
    this.defaultXRange,
    this.defaultYRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var contourPainters = contours.map((contour) {
      return CustomPaint(
        painter: ContourChartPainter(
          contour,
          defaultXRange: defaultXRange,
          defaultYRange: defaultYRange,
        ),
        size: Size(double.infinity, double.infinity),
      );
    }).toList();

    return Stack(children: contourPainters);
  }
}

class ContourChartPainter extends CartesianPlotPainter {
  final List<Vector2> points;
  final Range defaultXRange;
  final Range defaultYRange;

  ContourChartPainter(
    this.points, {
    this.defaultXRange,
    this.defaultYRange,
  }) : super(
          points,
          defaultXRange: defaultXRange,
          defaultYRange: defaultYRange,
        );

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    var path = Path();
    var offsets = getOffsetsForCanvas(size);

    offsets.asMap().forEach((index, offset) {
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

abstract class CartesianPlotPainter extends CustomPainter {
  final List<Vector2> points;
  final Range defaultXRange;
  final Range defaultYRange;

  CartesianPlotPainter(
    this.points, {
    this.defaultXRange,
    this.defaultYRange,
  });

  Range _xRange;
  Range get xRange {
    if (_xRange != null) return _xRange;
    if (defaultXRange != null) return _xRange = defaultXRange;

    var xPoints = points.map((point) => point.x).toList()..sort();

    return _xRange = Range(xPoints.first, xPoints.last);
  }

  Range _yRange;
  Range get yRange {
    if (_yRange != null) return _yRange;
    if (defaultYRange != null) return _yRange = defaultYRange;

    var yPoints = points.map((point) => point.y).toList()..sort();

    return _yRange = Range(yPoints.first, yPoints.last);
  }

  List<Offset> getOffsetsForCanvas(Size size) {
    return points
        .map((point) => Offset(
              (point.x - xRange.min) * getHorizontalScaleForCanvas(size),
              (point.y - yRange.min) * getVerticalScaleForCanvas(size),
            ))
        .toList();
  }

  double getHorizontalScaleForCanvas(Size size) {
    return size.width / (xRange.max - xRange.min);
  }

  double getVerticalScaleForCanvas(Size size) {
    return size.height / (yRange.max - yRange.min);
  }

  Color getColor(List<Color> colors, double value) {
    var scaledValue = value * (colors.length - 1);
    var firstColorIndex = scaledValue.floor();
    if (firstColorIndex == colors.length - 1) firstColorIndex--;

    return Color.lerp(colors[firstColorIndex], colors[firstColorIndex + 1],
            scaledValue - firstColorIndex)
        .withAlpha(150);
  }
}

abstract class DensityPlotPainter extends CartesianPlotPainter {
  final List<Vector3> pointsWithDensity;
  final Range defaultXRange;
  final Range defaultYRange;
  final Range defaultZRange;

  DensityPlotPainter(
    this.pointsWithDensity, {
    this.defaultXRange,
    this.defaultYRange,
    this.defaultZRange,
  }) : super(
          pointsWithDensity.map((point) => point.xy).toList(),
          defaultXRange: defaultXRange,
          defaultYRange: defaultXRange,
        );

  Range _zRange;
  Range get zRange {
    if (_zRange != null) return _zRange;
    if (defaultZRange != null) return _zRange = defaultZRange;

    var zPoints = pointsWithDensity.map((point) => point.z).toList()..sort();

    return _zRange = Range(zPoints.first, zPoints.last);
  }

  List<OffsetWithDensity> getOffsetsWithDensityForCanvas(Size size) {
    var zScale = 1 / (zRange.max - zRange.min);

    return pointsWithDensity
        .map((point) => OffsetWithDensity(
            Offset(
              (point.x - xRange.min) * getHorizontalScaleForCanvas(size),
              (point.y - yRange.min) * getVerticalScaleForCanvas(size),
            ),
            (point.z - zRange.min) * zScale))
        .toList();
  }
}

class Range {
  final double min;
  final double max;

  Range(this.min, this.max);
}

class OffsetWithDensity {
  final Offset offset;
  final double density;

  OffsetWithDensity(this.offset, this.density);
}
