import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String? userName; // ⭐ اسم المستخدم
  final Map<String, dynamic>? userDevice; // ⭐ بيانات الجهاز

  const HomeScreen({super.key, this.userName, this.userDevice});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  double _heartRate = 72.0;
  double _bloodPressure = 120.0;
  double _oxygenLevel = 98.0;
  double _temperature = 36.8;

  @override
  void initState() {
    super.initState();
    _simulateSensorData();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() => _loading = false);
    });
  }

  void _simulateSensorData() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _heartRate = 70 + (DateTime.now().second % 20);
        _bloodPressure = 110 + (DateTime.now().second % 30);
        _oxygenLevel = 95 + (DateTime.now().second % 5);
        _temperature = 36.5 + (DateTime.now().second % 10) / 10;
      });
      _simulateSensorData();
    });
  }

  Widget _buildHealthCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              unit,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  'مخطط معدل ضربات القلب',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 40, color: Colors.grey[400]),
                    SizedBox(height: 10),
                    Text(
                      '📈 مخطط حي للبيانات\n(مرتبط بجهاز الاستشعار)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'آخر تحديث: ${DateTime.now().minute}:${DateTime.now().second}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(
                  label: Text('الآن: ${_heartRate.toStringAsFixed(0)}'),
                  backgroundColor: Colors.blue[100],
                ),
                Chip(
                  label: Text('أعلى: 92'),
                  backgroundColor: Colors.red[100],
                ),
                Chip(
                  label: Text('أقل: 68'),
                  backgroundColor: Colors.green[100],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة ترحيب بالمستخدم
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person, size: 30, color: Colors.blue[700]),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً ${widget.userName ?? 'مستخدم'} 👋',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'نظام مراقبة الصحة الذكي',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 5),
                        if (widget.userDevice != null)
                          Row(
                            children: [
                              Icon(Icons.device_hub, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 5),
                              Text(
                                'الجهاز: ${widget.userDevice!['serial_number']}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    onPressed: () {
                      setState(() {
                        _heartRate = 70 + (DateTime.now().second % 20);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // قراءات الصحة
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            children: [
              _buildHealthCard(
                'معدل ضربات القلب',
                _heartRate.toStringAsFixed(0),
                'نبضة/دقيقة',
                Icons.favorite,
                _heartRate > 90 ? Colors.red : _heartRate < 60 ? Colors.orange : Colors.green,
              ),
              _buildHealthCard(
                'ضغط الدم',
                _bloodPressure.toStringAsFixed(0),
                'ملم زئبق',
                Icons.speed,
                _bloodPressure > 140 ? Colors.red : Colors.orange,
              ),
              _buildHealthCard(
                'مستوى الأوكسجين',
                _oxygenLevel.toStringAsFixed(0),
                '%',
                Icons.water_drop,
                _oxygenLevel < 95 ? Colors.red : Colors.blue,
              ),
              _buildHealthCard(
                'درجة الحرارة',
                _temperature.toStringAsFixed(1),
                '°C',
                Icons.thermostat,
                _temperature > 37.5 ? Colors.red : Colors.purple,
              ),
            ],
          ),

          SizedBox(height: 20),

          // قسم الجراف
          _buildGraphSection(),

          SizedBox(height: 20),

          // معلومات سريعة
          Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🩺 ملاحظات طبية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    leading: Icon(
                      _heartRate > 90 || _heartRate < 60
                          ? Icons.warning
                          : Icons.check_circle,
                      color: _heartRate > 90 || _heartRate < 60 ? Colors.orange : Colors.green,
                    ),
                    title: Text(
                      _heartRate > 90
                          ? 'معدل ضربات القلب مرتفع'
                          : _heartRate < 60
                          ? 'معدل ضربات القلب منخفض'
                          : 'معدل ضربات القلب ضمن الطبيعي',
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.blue),
                    title: Text('ينصح بشرب كمية كافية من الماء'),
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.orange),
                    title: Text('الفحص التالي بعد 4 ساعات'),
                  ),
                  ListTile(
                    leading: Icon(Icons.medical_services, color: Colors.teal),
                    title: Text('اطلع على التوصيات للعناية بصحتك'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // الانتقال لشاشة التوصيات
                      // يمكن إضافة Navigation هنا
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // حالة الاتصال بالجهاز
          if (widget.userDevice != null)
            Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: Colors.green,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'متصل بالجهاز',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'آخر تحديث: ${DateTime.now().hour}:${DateTime.now().minute}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text('نشط'),
                      backgroundColor: Colors.green[100],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}