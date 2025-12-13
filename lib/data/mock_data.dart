import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

final Map<String, dynamic> mockHealth = {
  'heart': 72,
  'temperature': 36.6,
  'lastReadTime': DateTime.now().subtract(const Duration(minutes: 5)),
  'status': 'ممتازة',
};

final List<Map<String, String>> mockAlerts = [
  {
    'type': 'خطر',
    'title': 'نبض القلب مرتفع - 95 BPM',
    'time': '2025-10-13 10:30',
    'location': 'الرياض، السعودية',
  },
  {
    'type': 'تحذير',
    'title': 'درجة حرارة مرتفعة قليلاً - 37.5 °C',
    'time': '2025-10-12 16:45',
    'location': 'جدة، السعودية',
  },
  {
    'type': 'معلومة',
    'title': 'جهاز القياس غير متصل',
    'time': '2025-10-11 08:15',
    'location': 'الدمام، السعودية',
  },
];

final List<FlSpot> mockChartSpots = [
  FlSpot(0, 72),
  FlSpot(1, 75),
  FlSpot(2, 78),
  FlSpot(3, 82),
  FlSpot(4, 76),
  FlSpot(5, 84),
  FlSpot(6, 73),
  FlSpot(7, 70),
];
