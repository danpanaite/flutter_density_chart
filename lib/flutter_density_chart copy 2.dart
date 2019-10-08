library flutter_density_chart;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' show Vector2, Vector3;

class ScatterPlotChart extends StatelessWidget {
  final List<Vector2> points;

  const ScatterPlotChart({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DensityOutlineChartPainter(this.points),
      size: Size(double.infinity, double.infinity),
      child: CustomPaint(
        painter: ScatterPlotPainter(this.points),
        size: Size(double.infinity, double.infinity),
      ),
    );
  }
}

class ScatterPlotPainter extends DensityPlotPainter {
  final List<Vector2> points;

  ScatterPlotPainter(this.points) : super(points);

  @override
  void paint(Canvas canvas, Size size) {
    var scatterPlotPaint = Paint()
      ..color = Colors.black.withAlpha(50)
      ..style = PaintingStyle.fill;

    getOffsetsForCanvas(size)
        .forEach((offset) => canvas.drawCircle(offset, 2.0, scatterPlotPaint));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BlankChart extends StatelessWidget {
  final List<Vector2> points;

  const BlankChart({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DensityOutlineChartPainter(this.points),
      size: Size(double.infinity, double.infinity),
    );
  }
}

class DensityOutlineChartPainter extends CustomPainter {
  final List<Vector2> points;

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
      paintTickLabel(tickLabel, canvas,
          Offset(tick.dx - 4 * tickLabel.length, size.height + 10));
    });

    var yPoints = this.points.map((point) => point.y).toList()..sort();
    var yScale = size.height / (yPoints.last - yPoints.first);
    var yTicks = List.generate((yPoints.last - yPoints.first).floor(),
        (i) => Offset(0, (i + 1) * yScale));

    yTicks.asMap().forEach((index, tick) {
      var tickLabel = (yPoints.last - index).floor().toString();

      canvas.drawLine(tick, Offset(-10, tick.dy), outlinePaint);
      paintTickLabel(
          tickLabel, canvas, Offset(-15 - 4.0 * tickLabel.length, tick.dy - 7));
    });

    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.zero),
        outlinePaint);
  }

  void paintTickLabel(String tickLabel, Canvas canvas, Offset offset) {
    TextPainter(
      text: TextSpan(
        text: tickLabel,
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(minWidth: 0, maxWidth: double.infinity)
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class HistogramDensityChart extends StatelessWidget {
  final List<Vector2> points;

  const HistogramDensityChart({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DensityOutlineChartPainter(this.points),
      size: Size(double.infinity, double.infinity),
      child: CustomPaint(
        painter: HistogramDensityPainter(this.points),
        size: Size(double.infinity, double.infinity),
      ),
    );
  }
}

class HistogramDensityPainter extends DensityPlotPainter {
  final List<Vector2> points;

  HistogramDensityPainter(this.points) : super(points);

  @override
  void paint(Canvas canvas, Size size) {
    var histogramBinPaint = Paint()..style = PaintingStyle.fill;

    var divisions = 10;
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

        var color =
            Color.lerp(Colors.white, Colors.green, col / maxBinCount * 2);

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

class GradientChart extends StatelessWidget {
  final List<double> values;

  const GradientChart({Key key, this.values}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GradientOutlineChartPainter(values),
      size: Size(double.infinity, double.infinity),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFF225ea8),
            Color(0xFF41b6c4),
            Color(0xFFa1dab4),
            Color(0xFFffffcc),
          ]),
        ),
      ),
    );
  }
}

class GradientOutlineChartPainter extends CustomPainter {
  final List<double> values;

  GradientOutlineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    var outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    var test = values
      ..sort()
      ..toList();

    print(test.last);
    print(test.first);

    var scale = size.width / (values.last - values.first);
    var ticks = List.generate((values.last - values.first).floor(),
        (i) => Offset((i + 1) * scale, -10));

    print(scale);

    ticks.asMap().forEach((index, tick) {
      var tickLabel = (values.first + index).floor().toString();

      canvas.drawLine(tick, Offset(tick.dx, 0), outlinePaint);

      TextPainter(
        text: TextSpan(
          text: tickLabel,
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: double.infinity)
        ..paint(canvas, Offset(tick.dx - 4 * tickLabel.length, -25));
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

class KernelDensityEstimationChart extends StatelessWidget {
  final List<Vector3> points;

  const KernelDensityEstimationChart({Key key, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Vector2> points2D = this.points.map((point) => point.xy).toList();

    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(width: 1.0),
            gradient: LinearGradient(colors: [
              Color(0xFF225ea8),
              Color(0xFF41b6c4),
              Color(0xFFa1dab4),
              Color(0xFFffffcc),
            ]),
          ),
        ),
        Expanded(
          child: CustomPaint(
            painter: KernelDensityEstimationPainter(this.points),
            size: Size(double.infinity, double.infinity),
            child: CustomPaint(
              painter: DensityOutlineChartPainter(points2D),
              size: Size(double.infinity, double.infinity),
            ),
          ),
        ),
      ],
    );
  }
}

class KernelDensityEstimationPainter extends DensityPlot3Painter {
  final List<Vector3> points;

  KernelDensityEstimationPainter(this.points) : super(points);

  @override
  void paint(Canvas canvas, Size size) {
    var width = size.width / sqrt(this.points.length);
    var height = size.height / sqrt(this.points.length);
    var buffer = 1.1;

    getScaledPointsForCanvas(size).forEach((point) {
      var color = getColor([
        Color(0xFF225ea8),
        Color(0xFF41b6c4),
        Color(0xFFa1dab4),
        Color(0xFFffffcc),
      ], point.z);

      var paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // canvas.drawRect(Rect.fromCenter(center: Offset(point.x, point.y), width: width, height: height), paint);
      if (point.x + width < size.width && point.y + height < size.height) {
        canvas.drawRect(
            Rect.fromLTRB(point.x, point.y + height * buffer,
                point.x + width * buffer, point.y),
            paint);
      }
      // canvas.drawCircle(Offset(point.x, point.y), width, paint);
    });
  }

  Color getColor(List<Color> colors, double value) {
    var scaledValue = value * (colors.length - 1);
    var firstColorIndex = scaledValue.floor();
    if (firstColorIndex == colors.length - 1) firstColorIndex--;

    return Color.lerp(colors[firstColorIndex], colors[firstColorIndex + 1],
        scaledValue - firstColorIndex);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ContourChart extends StatelessWidget {
  final List<Vector3> points;
  final List<List<Vector2>> contours;

  const ContourChart({Key key, this.points, this.contours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Vector2> points2D = this.points.map((point) => point.xy).toList();

    return CustomPaint(
      painter: KernelDensityEstimationPainter(this.points),
      size: Size(double.infinity, double.infinity),
      child: CustomPaint(
        painter: DensityOutlineChartPainter(points2D),
        size: Size(double.infinity, double.infinity),
        child: CustomPaint(
          painter: ContourChartPainter(points2D, this.contours),
          size: Size(double.infinity, double.infinity),
        ),
      ),
    );
  }
}

class ContourChartPainter extends DensityPlotPainter {
  final List<Vector2> points;
  final List<List<Vector2>> contours;

  ContourChartPainter(this.points, this.contours) : super(points);

  @override
  void paint(Canvas canvas, Size size) {
    var outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    contours.forEach((contour) {
      var contourPath = Path();
      var offsets = getOffsetsForPoints(contour, size);

      offsets.asMap().forEach((index, offset) {
        if (index == 0) {
          contourPath.moveTo(offset.dx, offset.dy);
        } else {
          contourPath.lineTo(offset.dx, offset.dy);
        }

        if (index == offsets.length - 1) {
          contourPath.lineTo(offsets[0].dx, offsets[0].dy);
        }
      });

      canvas.drawPath(contourPath, outlinePaint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

abstract class DensityPlotPainter extends CustomPainter {
  final List<Vector2> points;

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

  List<Offset> getOffsetsForPoints(List<Vector2> points, Size size) {
    var xPoints = this.points.map((point) => point.x).toList()..sort();
    var xScale = size.width / (xPoints.last - xPoints.first);

    var yPoints = this.points.map((point) => point.y).toList()..sort();
    var yScale = size.height / (yPoints.last - yPoints.first);

    return points
        .map((point) => Offset((point.x - xPoints.first) * xScale,
            (point.y - yPoints.first) * yScale))
        .toList();
  }

  double getHorizontalScaleForCanvas(Size size) {
    var xPoints = this.points.map((point) => point.x).toList()..sort();
    var xScale = size.width / (xPoints.last - xPoints.first);

    return xScale;
  }

  double getVerticalScaleForCanvas(Size size) {
    var yPoints = this.points.map((point) => point.y).toList()..sort();
    var yScale = size.height / (yPoints.last - yPoints.first);

    return yScale;
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
