import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/main_layout.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isCheckingAuth = true;
  bool _hasValidDevice = false;
  Map<String, dynamic>? _userDevice;
  String? _userName; // ⭐ إضافة متغير لاسم المستخدم

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;

      if (session != null) {
        await _loadUserProfile(session.user.id); // ⭐ جلب بيانات المستخدم أولاً
        await _checkUserDevice(session.user.id);
      }
    } catch (e) {
      print('AuthGate initialization error: $e');
    } finally {
      setState(() => _isCheckingAuth = false);
    }
  }

  // ⭐ دالة جديدة لجلب بيانات المستخدم من profiles
  Future<void> _loadUserProfile(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('full_name, email')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null) {
        setState(() {
          _userName = profile['full_name'] ?? profile['email']?.split('@')[0] ?? 'مستخدم';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _checkUserDevice(String userId) async {
    try {
      final device = await Supabase.instance.client
          .from('sensor_devices')
          .select('*')
          .eq('assigned_to', userId)
          .maybeSingle();

      if (device != null && device['is_assigned'] == true) {
        setState(() {
          _userDevice = device;
          _hasValidDevice = true;
        });
        return;
      }

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('serial_number')
          .eq('id', userId)
          .maybeSingle();

      if (profile != null && profile['serial_number'] != null) {
        final deviceBySerial = await Supabase.instance.client
            .from('sensor_devices')
            .select('*')
            .eq('serial_number', profile['serial_number'])
            .maybeSingle();

        if (deviceBySerial != null && deviceBySerial['is_assigned'] == true) {
          setState(() {
            _userDevice = deviceBySerial;
            _hasValidDevice = true;
          });
          return;
        }
      }

      setState(() {
        _hasValidDevice = false;
        _userDevice = null;
      });
    } catch (e) {
      print('Check user device error: $e');
      setState(() {
        _hasValidDevice = false;
        _userDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Colors.blue[50]!,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'جاري التحقق من الحساب والجهاز...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          if (_hasValidDevice) {
            // ⭐ إرسال اسم المستخدم مع البيانات الأخرى
            return MainLayout(
              userDevice: _userDevice,
              userName: _userName,
            );
          } else {
            return _buildNoDeviceScreen(session.user.email ?? '');
          }
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Widget _buildNoDeviceScreen(String userEmail) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تنبيه'),
        backgroundColor: Colors.orange[700]!,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.orange[700]!,
            ),
            SizedBox(height: 20),
            Text(
              'مرحباً $userEmail',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 15),
            Text(
              'ليس لديك جهاز مفعل على حسابك',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'للاستفادة من كامل مزايا التطبيق، يجب تفعيل جهاز باستخدام رقم تسلسلي صحيح',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Supabase.instance.client.auth.signOut();
                  },
                  icon: Icon(Icons.logout),
                  label: Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.grey[800],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user != null) {
                      await _checkUserDevice(user.id);
                    }
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('إعادة تحميل'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}