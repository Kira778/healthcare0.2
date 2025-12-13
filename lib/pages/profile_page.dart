import 'package:flutter/material.dart';
import '../widgets/setting_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SettingTile(
              title: 'الإشعارات',
              subtitle: 'تفعيل أو تعطيل التنبيهات',
              value: notifications,
              onChanged: (v) => setState(() => notifications = v),
            ),
            SettingTile(
              title: 'الوضع الداكن',
              subtitle: 'تغيير مظهر التطبيق',
              value: darkMode,
              onChanged: (v) => setState(() => darkMode = v),
            ),
          ],
        ),
      ),
    );
  }
}
