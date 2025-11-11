import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Entry
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartHealthStaticApp());
}

class SmartHealthStaticApp extends StatelessWidget {
  const SmartHealthStaticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Health Emergency System (Static Demo)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.cairoTextTheme(), // use Cairo Arabic-like font
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),
      home: const MainScreen(),
    );
  }
}

// -------------------- MainScreen with Bottom Nav --------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _current = 0;
  final _pages = [
    const HomePage(),
    const AnalyticsPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_current],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _current,
        onTap: (i) => setState(() => _current = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey.shade500,
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartLine),
            label: 'التحليل',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bell),
            label: 'التنبيهات',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: 'الملف',
          ),
        ],
      ),
    );
  }
}

// -------------------- Mock Data --------------------
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

// -------------------- Home Page --------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String formattedTime(DateTime t) =>
      DateFormat('yyyy-MM-dd • HH:mm').format(t);

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية بسيطة
    final heart = 78;
    final temp = 36.8;
    final lastRead = DateTime.now();
    final status = "طبيعي";

    final controller = PageController(viewportFraction: 0.95);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Health Emergency System'),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // -------- العنوان --------
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100, // ممكن تغيّر الحجم حسب الشكل اللي يناسبك
                      height: 60,
                      child: Lottie.asset('assets/welcome.json'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('hh:mm a').format(DateTime.now()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(FontAwesomeIcons.bell),
              ],
            ),

            const SizedBox(height: 20),

            // -------- كروت النبض والحرارة --------
            Row(
              children: [
                Expanded(
                  child: _healthCard(
                    title: 'نبض القلب',
                    value: '$heart',
                    unit: 'BPM',
                    icon: FontAwesomeIcons.heart,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _healthCard(
                    title: 'درجة الحرارة',
                    value: '$temp',
                    unit: '°C',
                    icon: FontAwesomeIcons.thermometerHalf,
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // -------- ملخص الحالة --------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ملخص الحالة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _infoRow(
                            label: 'آخر قراءة',
                            value: formattedTime(lastRead),
                          ),
                        ),
                        Expanded(
                          child: _infoRow(label: 'الجهاز', value: 'متصل'),
                        ),
                        Expanded(
                          child: _infoRow(label: 'الحالة', value: status),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------- عروض لوتي --------
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller,
                      children: const [
                        _promoCard(
                          title: 'موجه صحي ذكي',
                          subtitle: 'تحليل سريع للحالة اليومية',
                          lottieUrl:
                              'https://assets5.lottiefiles.com/packages/lf20_touohxv0.json',
                        ),
                        _promoCard(
                          title: 'توصيل للطبيب',
                          subtitle: 'إرسال تقرير للطبيب المختص',
                          lottieUrl:
                              'https://assets2.lottiefiles.com/packages/lf20_jcikwtux.json',
                        ),
                        _promoCard(
                          title: 'خدمة الطوارئ',
                          subtitle: 'زر واحد لإرسال التنبيه الآن',
                          lottieUrl: 'assets/heartBeatPulse.json',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: const WormEffect(dotWidth: 8, dotHeight: 8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Widgets فرعية ----------------

  Widget _healthCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------- Promo Card ----------------

class _promoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String lottieUrl;
  const _promoCard({
    required this.title,
    required this.subtitle,
    required this.lottieUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 2, child: Lottie.network(lottieUrl)),
        ],
      ),
    );
  }
}

// -------------------- Analytics Page --------------------
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BackRow(title: 'تحليل الحالة الصحية'),
          const SizedBox(height: 12),
          // info big blue card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.chartLine,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'تحليل ذكي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'حالتك الصحية جيدة بشكل عام. نبض القلب في المعدل الطبيعي ودرجة الحرارة مستقرة. ينصح بمواصلة النشاط البدني المنتظم.',
                  style: TextStyle(color: Colors.white.withOpacity(0.95)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // chart card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.heart,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'معدل نبض القلب (اليوم)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: HeartLineChart(spots: mockChartSpots),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// -------------------- Notifications Page --------------------
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التنبيهات'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'سجل التنبيهات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children:
                  mockAlerts
                      .map(
                        (a) => AlertCard(
                          type: a['type']!,
                          title: a['title']!,
                          time: a['time']!,
                          location: a['location']!,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.question,
                  animType: AnimType.scale,
                  title: 'هل أنت متأكد من إرسال تنبيه طارئ؟',
                  btnOkText: 'نعم، إرسال',
                  btnOkOnPress: () {
                    // show success dialog
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      title: 'تم',
                      desc: 'تم إرسال التنبيه للطوارئ.',
                      btnOkOnPress: () {},
                    ).show();
                  },
                  btnCancelOnPress: () {},
                ).show();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(FontAwesomeIcons.paperPlane),
              label: const Text('إرسال تنبيه طارئ'),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Profile Page --------------------
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool emergency = true;
  bool doctorAlerts = true;
  bool dailyReport = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      emergency = _prefs.getBool('emergency') ?? true;
      doctorAlerts = _prefs.getBool('doctorAlerts') ?? true;
      dailyReport = _prefs.getBool('dailyReport') ?? false;
    });
  }

  Future<void> _save(String key, bool val) async {
    await _prefs.setBool(key, val);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // profile header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Text(
                    'م',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'محمد عبدالله',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '+966 50 123 4567',
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // family members mock
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'أفراد العائلة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(onPressed: () {}, child: const Text('إضافة')),
                    ],
                  ),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(child: Text('أ')),
                    title: const Text('أحمد محمد'),
                    subtitle: const Text('+966 50 123 4567'),
                  ),
                  ListTile(
                    leading: const CircleAvatar(child: Text('ف')),
                    title: const Text('فاطمة علي'),
                    subtitle: const Text('+966 55 987 6543'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // doctor card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(child: Text('د')),
              title: const Text('د. أحمد محمد السعيد'),
              subtitle: const Text('طبيب عام'),
              trailing: IconButton(
                onPressed: () async {
                  final Uri tel = Uri.parse('tel:+966112345678');
                  if (await canLaunchUrl(tel)) {
                    await launchUrl(tel);
                  } else {
                    Get.snackbar('خطأ', 'لا يمكن فتح تطبيق الاتصال');
                  }
                },
                icon: const Icon(Icons.call),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // settings toggles using flutter_switch
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Column(
                children: [
                  SettingTile(
                    title: 'إشعارات طارئة',
                    subtitle: 'تنبيهات فورية',
                    value: emergency,
                    onChanged: (v) {
                      setState(() {
                        emergency = v;
                        _save('emergency', v);
                      });
                    },
                  ),
                  SettingTile(
                    title: 'تنبيهات الطبيب',
                    subtitle: 'إرسال تنبيهات للطبيب',
                    value: doctorAlerts,
                    onChanged: (v) {
                      setState(() {
                        doctorAlerts = v;
                        _save('doctorAlerts', v);
                      });
                    },
                  ),
                  SettingTile(
                    title: 'التقرير اليومي',
                    subtitle: 'تلقي ملخص يومي',
                    value: dailyReport,
                    onChanged: (v) {
                      setState(() {
                        dailyReport = v;
                        _save('dailyReport', v);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // logout button
          OutlinedButton.icon(
            onPressed:
                () => Get.snackbar('تسجيل الخروج', 'تم تسجيل الخروج (محاكاة)'),
            icon: const Icon(FontAwesomeIcons.rightFromBracket),
            label: const Text('تسجيل الخروج'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// -------------------- Widgets --------------------
class HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  const HealthCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('طبيعي'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String lottieUrl;
  const PromoCard({
    required this.title,
    required this.subtitle,
    required this.lottieUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            SizedBox(width: 120, height: 120, child: Lottie.network(lottieUrl)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}

class AlertCard extends StatelessWidget {
  final String type;
  final String title;
  final String time;
  final String location;
  const AlertCard({
    required this.type,
    required this.title,
    required this.time,
    required this.location,
    super.key,
  });

  Color _typeColor() {
    if (type == 'خطر') return Colors.redAccent;
    if (type == 'تحذير') return Colors.orange;
    return Colors.blue;
  }

  IconData _typeIcon() {
    if (type == 'خطر') return FontAwesomeIcons.triangleExclamation;
    if (type == 'تحذير') return FontAwesomeIcons.bell;
    return FontAwesomeIcons.circleInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _typeColor().withOpacity(0.1),
          child: Icon(_typeIcon(), color: _typeColor()),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$time • $location'),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}

class SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          FlutterSwitch(
            width: 55,
            height: 28,
            value: value,
            onToggle: onChanged,
          ),
        ],
      ),
    );
  }
}

// -------------------- Chart Widget (fl_chart) --------------------
class HeartLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  const HeartLineChart({required this.spots, super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 60,
        maxY: 90,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                // sample hours labels
                const labels = [
                  '08:00',
                  '10:00',
                  '12:00',
                  '14:00',
                  '16:00',
                  '18:00',
                  '20:00',
                  '22:00',
                ];
                final idx = v.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[idx % labels.length],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              interval: 1,
            ),
          ),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: true),
            color: Colors.redAccent,
          ),
        ],
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBorder: BorderSide(color: Colors.white, width: 1),
            getTooltipItems: (tSpots) {
              return tSpots
                  .map(
                    (e) => LineTooltipItem(
                      '${DateFormat.Hm().format(DateTime.now())}\nvalue : ${e.y.toInt()}',
                      TextStyle(color: Colors.redAccent),
                    ),
                  )
                  .toList();
            },
          ),
        ),
      ),
    );
  }
}

// -------------------- Small Back Row --------------------
class BackRow extends StatelessWidget {
  final String title;
  const BackRow({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}