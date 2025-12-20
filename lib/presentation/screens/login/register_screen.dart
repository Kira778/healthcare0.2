import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final serialNumberController = TextEditingController();
  final ageController = TextEditingController();

  bool loading = false;
  bool passwordsMatch = true;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? serialNumberError;
  bool isSerialValid = false;
  String? genderValue; 
  final List<String> genderOptions = ['ذكر', 'أنثى', 'أخرى'];

  Future<void> _checkSerialNumber() async {
    final serialNumber = serialNumberController.text.trim();

    if (serialNumber.isEmpty) {
      setState(() {
        serialNumberError = 'الرجاء إدخال الرقم التسلسلي';
        isSerialValid = false;
      });
      return;
    }

    final serialBigInt = int.tryParse(serialNumber);
    if (serialBigInt == null) {
      setState(() {
        serialNumberError = 'الرقم التسلسلي يجب أن يكون أرقام فقط';
        isSerialValid = false;
      });
      return;
    }

    setState(() {
      loading = true;
      serialNumberError = null;
    });

    try {
      final deviceResponse = await Supabase.instance.client
          .from('sensor_devices')
          .select('id, serial_number, is_assigned, assigned_to')
          .eq('serial_number', serialBigInt)
          .maybeSingle();

      if (deviceResponse == null) {
        setState(() {
          serialNumberError = 'الرقم التسلسلي غير موجود في النظام';
          isSerialValid = false;
        });
        return;
      }

      if (deviceResponse['is_assigned'] == true ||
          deviceResponse['assigned_to'] != null) {
        setState(() {
          serialNumberError = 'هذا الجهاز مفعل بالفعل على حساب آخر';
          isSerialValid = false;
        });
        return;
      }

      setState(() {
        serialNumberError = null;
        isSerialValid = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ تم التحقق من الرقم التسلسلي بنجاح'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        serialNumberError = 'خطأ في الاتصال: ${e.toString()}';
        isSerialValid = false;
      });
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('كلمات المرور غير متطابقة')),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل')),
      );
      return;
    }

    final ageText = ageController.text.trim();
    if (ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال السن')),
      );
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age < 1 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال سن صحيح (من 1 إلى 120)')),
      );
      return;
    }

    final serialNumber = serialNumberController.text.trim();
    if (serialNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال الرقم التسلسلي')),
      );
      return;
    }

    if (!isSerialValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب التحقق من صحة الرقم التسلسلي أولاً')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final fullName = fullNameController.text.trim();
      final phone = phoneController.text.trim();
      final serialBigInt = int.parse(serialNumber);

      final deviceCheck = await Supabase.instance.client
          .from('sensor_devices')
          .select('id, is_assigned, assigned_to')
          .eq('serial_number', serialBigInt)
          .maybeSingle();

      if (deviceCheck == null) {
        throw Exception('الرقم التسلسلي غير موجود');
      }

      if (deviceCheck['is_assigned'] == true ||
          deviceCheck['assigned_to'] != null) {
        throw Exception('هذا الجهاز مفعل بالفعل');
      }

      final existingUser = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('البريد الإلكتروني مسجل بالفعل');
      }

      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('فشل إنشاء حساب المصادقة');
      }

      final userId = authResponse.user!.id;
      final deviceId = deviceCheck['id'] as String;

      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'email': email,
        'passwords': password,
        'full_name': fullName,
        'phone': phone.isNotEmpty ? phone : null,
        'age': age,
        'gender': genderValue,
        'serial_number': serialBigInt,
        'device_id': deviceId,
        'created_at': DateTime.now().toIso8601String(),
      });

      await Supabase.instance.client
          .from('sensor_devices')
          .update({
        'is_assigned': true,
        'assigned_to': userId,
        'assigned_at': DateTime.now().toIso8601String(),
      })
          .eq('id', deviceId);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('تم بنجاح'),
            ],
          ),
          content: Text('تم إنشاء الحساب وتفعيل الجهاز بنجاح!\nالآن يمكنك تسجيل الدخول.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('حسناً'),
            ),
          ],
        ),
      );
    } on PostgrestException catch (e) {
      String errorMessage = 'خطأ في قاعدة البيانات';

      if (e.code == '23505') {
        errorMessage = 'البريد الإلكتروني أو الرقم التسلسلي مستخدم بالفعل';
      } else if (e.code == '23503') {
        errorMessage = 'الرقم التسلسلي غير صحيح';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$errorMessage: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في المصادقة: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء حساب جديد'),
        backgroundColor: Colors.blue[700]!,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loading)
              LinearProgressIndicator(
                backgroundColor: Colors.blue[100]!,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),

            SizedBox(height: 20),

            TextField(
              controller: serialNumberController,
              decoration: InputDecoration(
                labelText: 'الرقم التسلسلي للجهاز *',
                prefixIcon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                suffixIcon: IconButton(
                  icon: Icon(
                    isSerialValid ? Icons.verified : Icons.verified_outlined,
                    color: isSerialValid ? Colors.green : Colors.blue,
                  ),
                  onPressed: _checkSerialNumber,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                errorText: serialNumberError,
                hintText: 'أدخل الرقم التسلسلي الموجود على الجهاز',
                errorStyle: TextStyle(color: Colors.red),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) {
                if (serialNumberError != null) {
                  setState(() {
                    serialNumberError = null;
                    isSerialValid = false;
                  });
                }
              },
            ),

            if (serialNumberError == null && serialNumberController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 5, left: 10),
                child: Text(
                  'اضغط على ✓ للتحقق من صحة السيريال',
                  style: TextStyle(color: Colors.blue[600], fontSize: 12),
                ),
              ),

            SizedBox(height: 20),

            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل *',
                prefixIcon: Icon(Icons.person, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'السن *',
                prefixIcon: Icon(Icons.cake, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'أدخل عمرك بالأرقام',
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: genderValue,
              decoration: InputDecoration(
                labelText: 'النوع (اختياري)',
                prefixIcon: Icon(Icons.transgender, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: genderOptions.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  genderValue = value;
                });
              },
              hint: Text('اختر النوع'),
            ),

            SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني *',
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 15),

            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف (اختياري)',
                prefixIcon: Icon(Icons.phone, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور *',
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: passwordController.text.isNotEmpty &&
                    passwordController.text.length < 6
                    ? 'يجب أن تكون 6 أحرف على الأقل'
                    : null,
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور *',
                prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: !passwordsMatch ? 'كلمات المرور غير متطابقة' : null,
              ),
              onChanged: (_) {
                setState(() {
                  passwordsMatch = passwordController.text == confirmPasswordController.text;
                });
              },
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700]!,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child: loading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    SizedBox(width: 10),
                    Text('جاري المعالجة...'),
                  ],
                )
                    : Text(
                  'إنشاء الحساب وتفعيل الجهاز',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 15),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'لديك حساب بالفعل؟ سجل دخول',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: 25),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[50]!,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 22),
                      SizedBox(width: 8),
                      Text(
                        'معلومات مهمة:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• يجب إدخال رقم تسلسلي صحيح وغير مفعل مسبقاً\n'
                        '• كلمة المرور يجب أن تكون 6 أحرف على الأقل\n'
                        '• تأكد من صحة البريد الإلكتروني لاستعادة الحساب\n'
                        '• يمكنك تفعيل جهاز واحد فقط لكل حساب\n'
                        '• السن مطلوب لتحسين التوصيات الصحية',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
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