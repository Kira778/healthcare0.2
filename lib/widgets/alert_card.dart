import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final Map<String, String> alert;
  const AlertCard({super.key, required this.alert});

  Color _getColor(String type) {
    switch (type) {
      case 'خطر':
        return Colors.redAccent;
      case 'تحذير':
        return Colors.orangeAccent;
      default:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColor(alert['type']!),
          child: const Icon(Icons.warning, color: Colors.white),
        ),
        title: Text(alert['title']!),
        subtitle: Text('${alert['time']!}\n${alert['location']!}'),
        isThreeLine: true,
      ),
    );
  }
}
