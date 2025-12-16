import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../login/login_screen.dart';
import '../../../core/theme/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String? userName;
  final Map<String, dynamic>? userDevice;
  final String userEmail;
  const ProfileScreen({
    super.key,
    this.userName,
    this.userDevice,
    required this.userEmail,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  try {
    print('🔍 جاري تحميل بيانات البروفايل...');
    print('📧 الإيميل المستلم: ${widget.userEmail}');
    
    final userEmail = widget.userEmail;

    if (userEmail.isNotEmpty) {
      // ⭐ البحث في profiles باستخدام الإيميل
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('email', userEmail)
          .maybeSingle()
          .timeout(Duration(seconds: 10));

      print('📊 Profile data loaded for email: $userEmail');
      print('📋 Data type: ${response.runtimeType}');
      print('📋 Data: $response');
      
      // ⭐ تحقق من نوع البيانات
      if (response != null) {
        print('✅ تم العثور على بيانات');
        print('   serial_number نوع: ${response['serial_number'].runtimeType}');
        print('   serial_number قيمة: ${response['serial_number']}');
        
        // ⭐ تحويل جميع القيم إلى String بشكل آمن
        final processedData = Map<String, dynamic>.from(response);
        
        // تحويل serial_number إلى String إذا كان int
        if (processedData['serial_number'] is int) {
          processedData['serial_number'] = processedData['serial_number'].toString();
        }
        
        // تحويل phone إلى String إذا كان int
        if (processedData['phone'] is int) {
          processedData['phone'] = processedData['phone'].toString();
        }
        
        // تحويل age إلى String إذا كان int
        if (processedData['age'] is int) {
          processedData['age'] = processedData['age'].toString();
        }

        setState(() {
          _userData = processedData;
          _loading = false;
        });
      } else {
        print('❌ لم يتم العثور على بيانات للإيميل: $userEmail');
        setState(() => _loading = false);
      }
    } else {
      print('❌ الإيميل فارغ!');
      setState(() => _loading = false);
    }
  } catch (e) {
    print('❌ Error loading profile: $e');
    print('❌ Stack trace: ${e.toString()}');
    setState(() => _loading = false);
  }
}

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تسجيل الخروج: $e')));
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon, {
    Color? iconColor,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.blue),
        title: Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value.isNotEmpty ? value : 'غير محدد',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('جاري تحميل بيانات الملف الشخصي...'),
          ],
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 صورة الملف الشخصي
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, size: 60, color: Colors.blue[700]),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)],
                    ),
                    child: Icon(Icons.edit, size: 20, color: Colors.blue),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // 🔹 معلومات المستخدم الأساسية
            Text(
              _userData?['full_name'] ?? widget.userName ?? 'مستخدم',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              _userData?['email'] ??
                  widget.userEmail ??
                  'لا يوجد بريد إلكتروني',
              style: TextStyle(color: Colors.grey[600]),
            ),

            SizedBox(height: 30),

            // 🔹 معلومات الجهاز (إذا كان موجوداً)
            if (widget.userDevice != null) ...[
              _buildSectionTitle('معلومات الجهاز'),
              Card(
                color: Colors.green[50],
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.device_hub, color: Colors.green, size: 30),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'جهاز المراقبة الصحية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'الرقم التسلسلي: ${widget.userDevice!['serial_number']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              'نشط',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (widget.userDevice!['assigned_at'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'تم التفعيل: ${_formatDate(widget.userDevice!['assigned_at'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],

            // 🔹 معلومات الحساب الشخصية
            _buildSectionTitle('معلومات الحساب'),
            _buildInfoCard(
              'الاسم الكامل',
              _userData?['full_name'] ?? 'غير محدد',
              Icons.person,
              iconColor: Colors.purple,
            ),
            _buildInfoCard(
              'السن',
              _userData?['age']?.toString() ?? 'غير محدد',
              Icons.cake,
              iconColor: Colors.orange,
            ),
            _buildInfoCard(
              'البريد الإلكتروني',
              _userData?['email'] ?? 'غير محدد',
              Icons.email,
              iconColor: Colors.blue,
            ),
            _buildInfoCard(
              'رقم الهاتف',
              _userData?['phone'] ?? 'لم يتم إضافة رقم',
              Icons.phone,
              iconColor: Colors.green,
            ),
            _buildInfoCard(
              'رقم الجهاز',
              _userData?['serial_number']?.toString() ?? '-',
              Icons.device_hub,
              iconColor: Colors.teal,
            ),
            _buildInfoCard(
              'تاريخ التسجيل',
              _userData?['created_at'] != null
                  ? _formatDate(_userData!['created_at'])
                  : 'غير محدد',
              Icons.calendar_today,
              iconColor: Colors.red,
            ),

            SizedBox(height: 30),

            // 🔹 الإعدادات
            _buildSectionTitle('الإعدادات'),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications, color: Colors.orange),
                    title: Text('الإشعارات'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: Colors.blue,
                    ),
                  ),
                  Divider(height: 0, indent: 20, endIndent: 20),
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.blue),
                    title: Text('اللغة'),
                    trailing: Text(
                      'العربية',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {},
                  ),
                  Divider(height: 0, indent: 20, endIndent: 20),
                  ListTile(
  leading: Icon(
    themeNotifier.value == ThemeMode.dark
        ? Icons.dark_mode
        : Icons.light_mode,
    color: Colors.purple,
  ),
  title: Text('الوضع الداكن'),
  trailing: Switch(
    value: themeNotifier.value == ThemeMode.dark,
    onChanged: (value) {
      setState(() {
        themeNotifier.value =
            value ? ThemeMode.dark : ThemeMode.light;
      });
    },
  ),
),

                  Divider(height: 0, indent: 20, endIndent: 20),
                  ListTile(
                    leading: Icon(Icons.help, color: Colors.teal),
                    title: Text('المساعدة والدعم'),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 🔹 زر تسجيل الخروج
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red[100]!),
                color: Colors.red[50],
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.red),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Text('تسجيل الخروج'),
                        ],
                      ),
                      content: Text(
                        'هل أنت متأكد من رغبتك في تسجيل الخروج من التطبيق؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'إلغاء',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _signOut();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // 🔹 معلومات التطبيق
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Colors.blue,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Health Care System',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    'إصدار 1.2',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '© 2026 جميع الحقوق محفوظة',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
