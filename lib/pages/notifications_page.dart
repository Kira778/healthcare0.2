import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/alert_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: mockAlerts.length,
        itemBuilder: (context, index) {
          final alert = mockAlerts[index];
          return AlertCard(alert: alert);
        },
      ),
    );
  }
}
