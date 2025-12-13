import 'package:flutter/material.dart';
import '../widgets/health_card.dart';
import '../widgets/info_row.dart';
import '../widgets/promo_card.dart';
import '../data/mock_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final heart = mockHealth['heart'];
    final temp = mockHealth['temperature'];
    final time = mockHealth['lastReadTime'];
    final status = mockHealth['status'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحالة الصحية'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HealthCard(heart: heart, temperature: temp, status: status),
            const SizedBox(height: 20),
            InfoRow(label: 'آخر قراءة', value: time.toString()),
            const SizedBox(height: 20),
            const PromoCard(),
          ],
        ),
      ),
    );
  }
}
