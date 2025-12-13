import 'package:flutter/material.dart';
import '../widgets/heart_line_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل البيانات'),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: HeartLineChart(),
      ),
    );
  }
}
