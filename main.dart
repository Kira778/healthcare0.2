import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      create: (context) => HealthProvider(prefs: prefs),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Health System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        MainBottomNav.routeName: (context) => const MainBottomNav(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// ===================
// Colors & Fonts
// ===================
class AppColors {
  static const Color background = Colors.white;
  static const Color accentBlue = Color(0xFF5CC8FF);
  static const Color softRed = Color(0xFFFF6B6B);
  static const Color normalGreen = Color(0xFF34D399);
  static const Color warnYellow = Color(0xFFFBBF24);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color lightGray = Color(0xFFF5F5F5);
}

// ===================
// Widgets
// ===================
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.accentBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 4,
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

Widget metricCircle({required String label, required String value, required Color color, IconData? icon}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: color, size: 28),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
    ],
  );
}

// ===================
// Provider
// ===================
class HealthProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  int? heartRate;
  double? temperature;
  Timer? _timer;
  final List<Map<String, dynamic>> alerts = [];

  HealthProvider({required this.prefs}) {
    heartRate = prefs.getInt('hr') ?? 75;
    temperature = prefs.getDouble('temp') ?? 36.7;
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final random = Random();
      heartRate = 70 + random.nextInt(40);
      temperature = 36 + random.nextDouble() * 2;
      prefs.setInt('hr', heartRate!);
      prefs.setDouble('temp', temperature!);
      notifyListeners();
    });
  }

  bool get isCritical =>
      heartRate != null &&
          temperature != null &&
          (heartRate! > 120 || heartRate! < 40 || temperature! >= 39.0);

  void addAlert(String type) {
    final alert = {
      'type': type,
      'time': DateTime.now().toIso8601String(),
      'hr': heartRate,
      'temp': temperature,
    };
    alerts.add(alert);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ===================
// Splash Screen
// ===================
class SplashScreen extends StatefulWidget {
  static const String routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accentBlue, AppColors.softRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.favorite, size: 80, color: Colors.white),
              SizedBox(height: 12),
              Text(
                'Smart Health Emergency System',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================
// Login/Register Screen
// ===================
class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacementNamed(MainBottomNav.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFe6f7ff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, size: 60, color: AppColors.accentBlue),
                    const SizedBox(height: 12),
                    const Text('Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (val) => val != null && val.contains('@') ? null : 'Enter valid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (val) => val != null && val.length >= 4 ? null : 'Password too short',
                    ),
                    const SizedBox(height: 24),
                    AppButton(label: 'Login', onPressed: _login),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Create a new account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================
// Bottom Navigation
// ===================
class MainBottomNav extends StatefulWidget {
  static const String routeName = '/main';
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int currentIndex = 0;
  final List<Widget> screens = const [HomeScreen(), AnalysisScreen(), AlertsScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ===================
// Home Dashboard
// ===================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Color statusColor(int? hr, double? temp) {
    if (hr == null || temp == null) return Colors.grey;
    if (hr < 40 || hr > 120 || temp >= 39.0) return AppColors.dangerRed;
    if (hr < 60 || hr > 100 || temp >= 37.5) return AppColors.warnYellow;
    return AppColors.normalGreen;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final hr = provider.heartRate;
    final temp = provider.temperature;
    final color = statusColor(hr, temp);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), backgroundColor: AppColors.accentBlue),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                metricCircle(label: 'Heart Rate', value: '${hr ?? "--"} bpm', color: color, icon: Icons.favorite),
                metricCircle(label: 'Temperature', value: '${temp?.toStringAsFixed(1) ?? "--"} °C', color: color, icon: Icons.thermostat),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Details Analysis',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Send Alert',
                    color: AppColors.softRed,
                    onPressed: () {
                      provider.addAlert('Manual');
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Alert added locally')));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  provider.isCritical ? 'Status: CRITICAL' : 'Status: Stable',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: provider.isCritical ? AppColors.dangerRed : AppColors.normalGreen,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ===================
// Analysis Screen (بدون charts)
// ===================
class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final hr = provider.heartRate ?? 80;
    final temp = provider.temperature ?? 36.5;

    return Scaffold(
      appBar: AppBar(title: const Text('Health Analysis'), backgroundColor: AppColors.accentBlue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // بيانات بسيطة بدون رسوم بيانية
            Card(
              child: ListTile(
                title: const Text('Current Heart Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$hr BPM', style: const TextStyle(fontSize: 18)),
                leading: Icon(Icons.favorite, color: AppColors.softRed),
                trailing: Text(_getHeartRateStatus(hr), style: TextStyle(
                    color: _getHeartRateColor(hr),
                    fontWeight: FontWeight.bold
                )),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Current Temperature', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${temp.toStringAsFixed(1)} °C', style: const TextStyle(fontSize: 18)),
                leading: Icon(Icons.thermostat, color: AppColors.accentBlue),
                trailing: Text(_getTempStatus(temp), style: TextStyle(
                    color: _getTempColor(temp),
                    fontWeight: FontWeight.bold
                )),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('AI Analysis:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(_getAnalysis(hr, temp)),
                  const SizedBox(height: 4),
                  const Text('Tip: Drink water frequently. Consult your doctor if values are abnormal.',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getHeartRateStatus(int hr) {
    if (hr < 60) return 'Low';
    if (hr > 100) return 'High';
    return 'Normal';
  }

  Color _getHeartRateColor(int hr) {
    if (hr < 60) return AppColors.warnYellow;
    if (hr > 100) return AppColors.dangerRed;
    return AppColors.normalGreen;
  }

  String _getTempStatus(double temp) {
    if (temp < 36.0) return 'Low';
    if (temp > 37.5) return 'High';
    return 'Normal';
  }

  Color _getTempColor(double temp) {
    if (temp < 36.0) return AppColors.warnYellow;
    if (temp > 37.5) return AppColors.dangerRed;
    return AppColors.normalGreen;
  }

  String _getAnalysis(int hr, double temp) {
    if (hr > 120 || hr < 40 || temp >= 39.0) {
      return 'CRITICAL: Seek immediate medical attention!';
    } else if (hr > 100 || hr < 60 || temp >= 37.5) {
      return 'Warning: Monitor your condition closely.';
    } else {
      return 'Your vital signs are normal. Stay hydrated and get enough rest.';
    }
  }
}

// ===================
// Alerts Screen
// ===================
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final alerts = provider.alerts.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts'), backgroundColor: AppColors.accentBlue),
      body: alerts.isEmpty
          ? const Center(child: Text('No alerts yet'))
          : ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (ctx, i) {
          final a = alerts[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.warning, color: AppColors.dangerRed),
              title: Text(a['type']),
              subtitle: Text('HR: ${a['hr']}, Temp: ${a['temp']}\n${a['time']}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.softRed,
        onPressed: () {
          provider.addAlert('Manual');
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Manual alert sent')));
        },
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}

// ===================
// Profile / Settings
// ===================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings'), backgroundColor: AppColors.accentBlue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('User Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Name: John Doe'),
                    Text('Age: 30'),
                    Text('Phone: +201234567890'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Family & Doctor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    AppButton(label: 'Add Family Member', onPressed: () {}),
                    const SizedBox(height: 8),
                    AppButton(label: 'Add Responsible Doctor', onPressed: () {}),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SwitchListTile(
                      title: const Text('Enable Alerts'),
                      value: true,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}