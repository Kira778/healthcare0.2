import 'package:flutter/material.dart';

class HealthCard extends StatelessWidget {
  final int heart;
  final double temperature;
  final String status;

  const HealthCard({
    super.key,
    required this.heart,
    required this.temperature,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.cyan.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('نبض القلب: $heart BPM', style: const TextStyle(fontSize: 18)),
            Text('درجة الحرارة: $temperature °C',
                style: const TextStyle(fontSize: 18)),
            Text('الحالة: $status',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
