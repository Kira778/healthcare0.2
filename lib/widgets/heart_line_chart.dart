import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class HeartLineChart extends StatelessWidget {
  const HeartLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 60,
        maxY: 100,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) => Text('${value.toInt()}h'),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 5),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: mockChartSpots,
            isCurved: true,
            barWidth: 3,
            color: Colors.cyan,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
