import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math';
=======
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e

class HomeScreen extends StatefulWidget {
  final String? userName;
  final Map<String, dynamic>? userDevice;

  const HomeScreen({super.key, this.userName, this.userDevice});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  final SupabaseClient supabase = Supabase.instance.client;
  bool _loading = true;
  bool _usingRealData = false;

  double _heartRate = 72.0;
  List<double> _heartRateHistory = [];

  double _bloodPressure = 120.0;
  double _oxygenLevel = 98.0;
  double _temperature = 36.8;
=======
  bool _loading = true;
  double _heartRate = 72.0;
  double _bloodPressure = 120.0;
  double _oxygenLevel = 98.0;
  double _temperature = 36.8;

  // 🔹 بيانات الجرافات المصغرة
  List<double> _heartRateHistory = [];
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
  List<double> _bloodPressureHistory = [];
  List<double> _oxygenHistory = [];
  List<double> _temperatureHistory = [];

<<<<<<< HEAD
  int? _deviceSerialNumber; // ⭐️ تغيير من String? إلى int?
  late Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    _initializeStaticHistoryData();
    _startDataLoading();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  void _startDataLoading() async {
    await _tryToFetchRealData();
    _startPeriodicUpdates();
    setState(() => _loading = false);
  }

  Future<void> _tryToFetchRealData() async {
    try {
      final String emailToFetch = 'ahmedelmaghraby113@gmail.com';
      
      print('🔍 جاري البحث عن بيانات المستخدم...');
      
      // 1. البحث عن ملف المستخدم باستخدام البريد
      final profileResponse = await supabase
          .from('profiles')
          .select('serial_number, full_name')
          .eq('email', emailToFetch)
          .maybeSingle();

      if (profileResponse != null && profileResponse['serial_number'] != null) {
        // ⭐️ serial_number هو bigint (رقم كبير)
        _deviceSerialNumber = profileResponse['serial_number'] as int;
        print('✅ تم العثور على رقم الجهاز: $_deviceSerialNumber');
        print('👤 اسم المستخدم: ${profileResponse['full_name']}');
        
        // 2. محاولة جلب قراءات النبض من device_readings
        await _fetchRealHeartRateData();
        
        if (_heartRateHistory.isNotEmpty) {
          setState(() {
            _usingRealData = true;
          });
          print('✅ جلب ${_heartRateHistory.length} قراءة نبض من Supabase');
        } else {
          print('⚠️ لا توجد قراءات نبض في قاعدة البيانات، سيتم استخدام المحاكاة');
          _initializeSimulatedHeartRate();
        }
      } else {
        print('⚠️ لم يتم العثور على مستخدم بهذا البريد: $emailToFetch');
        print('⚠️ سيتم استخدام المحاكاة');
        _initializeSimulatedHeartRate();
      }
    } catch (e) {
      print('❌ خطأ في جلب البيانات الحقيقية: $e');
      _initializeSimulatedHeartRate();
    }
  }

  Future<void> _fetchRealHeartRateData() async {
    if (_deviceSerialNumber == null) return;
    
    try {
      print('🔍 جاري جلب بيانات النبض من جدول device_readings...');
      print('🔢 رقم الجهاز المستخدم: $_deviceSerialNumber');
      
      // ⭐️ البحث عن قراءات النبض بناءً على device_serial (الذي هو bigint)
      final response = await supabase
          .from('device_readings')
          .select('reading_value, reading_time, device_serial')
          .eq('device_serial', _deviceSerialNumber!) // ⭐️ هنا نستخدم int
          .order('reading_time', ascending: false)
          .limit(15);

      print('📊 استجابة Supabase: $response');
      
      if (response.isNotEmpty) {
        print('📈 عدد القراءات المستلمة: ${response.length}');
        
        final List<double> newHistory = [];
        for (var reading in response.reversed.toList()) {
          final value = reading['reading_value'];
          final deviceSerial = reading['device_serial'];
          final readingTime = reading['reading_time'];
          
          print('📖 قراءة: قيمة=$value, جهاز=$deviceSerial, وقت=$readingTime');
          
          if (value != null) {
            final doubleValue = (value as num).toDouble();
            newHistory.add(doubleValue);
          }
        }

        if (newHistory.isNotEmpty) {
          setState(() {
            _heartRateHistory = newHistory;
            _heartRate = newHistory.last;
          });
          print('✅ تم تحميل ${newHistory.length} قراءة بنجاح');
          print('📊 آخر قراءة: $_heartRate');
        } else {
          print('⚠️ القراءات موجودة ولكنها فارغة');
        }
      } else {
        print('⚠️ لا توجد قراءات في جدول device_readings للجهاز $_deviceSerialNumber');
        print('💡 تأكد من:');
        print('   1. وجود بيانات في جدول device_readings');
        print('   2. تطابق device_serial مع serial_number في جدول profiles');
        print('   3. قم بإضافة بيانات تجريبية:');
        print('      INSERT INTO device_readings (device_serial, reading_value, reading_time)');
        print('      VALUES ($_deviceSerialNumber, 75, NOW());');
      }
    } catch (e) {
      print('❌ خطأ في جلب بيانات النبض: $e');
      print('💡 التفاصيل: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _fetchLatestHeartRate() async {
    if (_deviceSerialNumber == null || !_usingRealData) return;
    
    try {
      final response = await supabase
          .from('device_readings')
          .select('reading_value')
          .eq('device_serial', _deviceSerialNumber!)
          .order('reading_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null && response['reading_value'] != null) {
        final newHeartRate = (response['reading_value'] as num).toDouble();
        
        // تحديث فقط إذا كانت القراءة مختلفة
        if ((newHeartRate - _heartRate).abs() > 0.5) {
          setState(() {
            _heartRate = newHeartRate;
            
            if (_heartRateHistory.length >= 15) {
              _heartRateHistory.removeAt(0);
            }
            _heartRateHistory.add(_heartRate);
          });
          
          print('🔄 تم تحديث النبض من Supabase: $_heartRate');
        }
      }
    } catch (e) {
      print('❌ خطأ في جلب آخر قراءة: $e');
    }
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (mounted) {
        if (_usingRealData) {
          await _fetchLatestHeartRate();
        } else {
          _updateSimulatedHeartRate();
        }
        
        _updateOtherSensorData();
=======
  @override
  void initState() {
    super.initState();
    _initializeHistoryData();
    _simulateSensorData();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() => _loading = false);
    });
  }

  void _initializeHistoryData() {
    // إنشاء بيانات تاريخية أولية (آخر 6 قراءات)
    for (int i = 0; i < 6; i++) {
      _heartRateHistory.add(70 + (i * 3));
      _bloodPressureHistory.add(115 + (i * 4));
      _oxygenHistory.add(95 + (i % 3));
      _temperatureHistory.add(36.5 + (i * 0.2));
    }
  }

  void _simulateSensorData() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          // تحديث القراءات
          _heartRate = 70 + (DateTime.now().second % 20);
          _bloodPressure = 110 + (DateTime.now().second % 30);
          _oxygenLevel = 95 + (DateTime.now().second % 5);
          _temperature = 36.5 + (DateTime.now().second % 10) / 10;

          // تحديث التاريخ
          _updateHistoryData();
        });
        _simulateSensorData();
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
      }
    });
  }

<<<<<<< HEAD
  void _initializeSimulatedHeartRate() {
    final random = Random();
    final List<double> initialHistory = [];
    
    for (int i = 0; i < 10; i++) {
      initialHistory.add(70 + random.nextDouble() * 20);
    }
    
    setState(() {
      _heartRateHistory = initialHistory;
      _heartRate = initialHistory.last;
      _usingRealData = false;
    });
  }

  void _updateSimulatedHeartRate() {
    final random = Random();
    final newHeartRate = 70 + random.nextDouble() * 20;
    
    setState(() {
      _heartRate = newHeartRate;
      
      if (_heartRateHistory.length >= 15) {
        _heartRateHistory.removeAt(0);
      }
      _heartRateHistory.add(_heartRate);
    });
  }

  void _updateOtherSensorData() {
    final random = Random();
    
    setState(() {
      _bloodPressure = 110 + random.nextDouble() * 30;
      _oxygenLevel = 94 + random.nextDouble() * 6;
      _temperature = 36.2 + random.nextDouble() * 1.5;

      _updateStaticHistoryData();
    });
  }

  void _initializeStaticHistoryData() {
    final random = Random();
    
    _bloodPressureHistory.clear();
    _oxygenHistory.clear();
    _temperatureHistory.clear();
    _heartRateHistory.clear();
    
    for (int i = 0; i < 10; i++) {
      _heartRateHistory.add(70 + random.nextDouble() * 20);
      _bloodPressureHistory.add(115 + random.nextDouble() * 20);
      _oxygenHistory.add(95 + random.nextDouble() * 3);
      _temperatureHistory.add(36.5 + random.nextDouble() * 1.0);
    }
    
    if (_heartRateHistory.isNotEmpty) {
      _heartRate = _heartRateHistory.last;
    }
    if (_bloodPressureHistory.isNotEmpty) {
      _bloodPressure = _bloodPressureHistory.last;
    }
    if (_oxygenHistory.isNotEmpty) {
      _oxygenLevel = _oxygenHistory.last;
    }
    if (_temperatureHistory.isNotEmpty) {
      _temperature = _temperatureHistory.last;
    }
  }

  void _updateStaticHistoryData() {
    _addToHistory(_bloodPressureHistory, _bloodPressure, 10);
    _addToHistory(_oxygenHistory, _oxygenLevel, 10);
    _addToHistory(_temperatureHistory, _temperature, 10);
=======
  void _updateHistoryData() {
    // تحديث بيانات التاريخ مع الحفاظ على 6 قراءات فقط
    _addToHistory(_heartRateHistory, _heartRate, 6);
    _addToHistory(_bloodPressureHistory, _bloodPressure, 6);
    _addToHistory(_oxygenHistory, _oxygenLevel, 6);
    _addToHistory(_temperatureHistory, _temperature, 6);
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
  }

  void _addToHistory(List<double> history, double newValue, int maxLength) {
    if (history.length >= maxLength) {
      history.removeAt(0);
    }
    history.add(newValue);
  }

<<<<<<< HEAD
  Future<void> _forceRefreshData() async {
    setState(() => _loading = true);
    
    try {
      await _tryToFetchRealData();
      print('🔄 تم تحديث البيانات بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث البيانات: $e');
    }
    
    setState(() => _loading = false);
  }

  // دالة لإضافة بيانات تجريبية إلى Supabase
  Future<void> _addTestDataToSupabase() async {
    if (_deviceSerialNumber == null) {
      print('❌ لا يوجد رقم جهاز لإضافة بيانات تجريبية');
      return;
    }
    
    try {
      // إضافة 5 قراءات تجريبية
      for (int i = 0; i < 5; i++) {
        final randomValue = 70 + Random().nextDouble() * 20;
        
        await supabase.from('device_readings').insert({
          'device_serial': _deviceSerialNumber,
          'reading_value': randomValue,
          'reading_time': DateTime.now().subtract(Duration(minutes: i * 5)).toIso8601String(),
        });
      }
      
      print('✅ تم إضافة بيانات تجريبية إلى Supabase');
      await _forceRefreshData();
    } catch (e) {
      print('❌ خطأ في إضافة بيانات تجريبية: $e');
    }
  }

  Widget _buildHealthCardWithGraph(
    String title,
    double value,
    String unit,
    IconData icon,
    Color color,
    List<double> history,
    bool isHeartRate,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
=======
  Widget _buildHealthCardWithGraph(String title, double value, String unit, IconData icon, Color color, List<double> history) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔹 العنوان والقيمة
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                  ),
                ),
                Text(
                  value.toStringAsFixed(title == 'درجة الحرارة' ? 1 : 0),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
<<<<<<< HEAD
                const SizedBox(width: 4),
=======
                SizedBox(width: 4),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                Text(
                  unit,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
<<<<<<< HEAD
                if (isHeartRate && _deviceSerialNumber != null)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _usingRealData ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _usingRealData ? Icons.cloud_done : Icons.sim_card,
                          size: 10,
                          color: _usingRealData ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'جهاز $_deviceSerialNumber',
                          style: TextStyle(
                            fontSize: 8,
                            color: _usingRealData ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(height: 40, child: _buildMiniGraph(history, color)),
            const SizedBox(height: 4),
=======
              ],
            ),

            SizedBox(height: 8),

            // 🔹 جراف مصغر
            Container(
              height: 40,
              child: _buildMiniGraph(history, color),
            ),

            SizedBox(height: 4),

            // 🔹 مؤشر الاتجاه
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTrendText(history),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getTrendColor(history),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      _getTrendIcon(history),
                      size: 12,
                      color: _getTrendColor(history),
                    ),
<<<<<<< HEAD
                    const SizedBox(width: 2),
                    Text(
                      '${_calculateTrend(history).toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
=======
                    SizedBox(width: 2),
                    Text(
                      '${_calculateTrend(history).toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniGraph(List<double> data, Color color) {
<<<<<<< HEAD
    if (data.isEmpty) return const SizedBox();
    return CustomPaint(
      size: const Size(double.infinity, 40),
=======
    if (data.length < 2) return SizedBox();

    return CustomPaint(
      size: Size(double.infinity, 40),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
      painter: _MiniGraphPainter(data, color),
    );
  }

  String _getTrendText(List<double> data) {
    if (data.length < 2) return 'ثابت';
    final trend = _calculateTrend(data);
    if (trend > 1) return 'مرتفع';
    if (trend < -1) return 'منخفض';
    return 'مستقر';
  }

  Color _getTrendColor(List<double> data) {
    if (data.length < 2) return Colors.grey;
    final trend = _calculateTrend(data);
    if (trend > 1) return Colors.red;
    if (trend < -1) return Colors.green;
    return Colors.grey;
  }

  IconData _getTrendIcon(List<double> data) {
    if (data.length < 2) return Icons.trending_flat;
    final trend = _calculateTrend(data);
    if (trend > 1) return Icons.trending_up;
    if (trend < -1) return Icons.trending_down;
    return Icons.trending_flat;
  }

  double _calculateTrend(List<double> data) {
    if (data.length < 2) return 0;
    final last = data.last;
    final previous = data[data.length - 2];
    return last - previous;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
<<<<<<< HEAD
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('جاري تحميل بيانات النبض...'),
              const SizedBox(height: 10),
              Text(
                _deviceSerialNumber != null 
                    ? 'رقم الجهاز: $_deviceSerialNumber'
                    : 'جاري البحث عن الجهاز...',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقبة الصحة'),
        actions: [
          if (!_usingRealData && _deviceSerialNumber != null)
            IconButton(
              icon: const Icon(Icons.add_chart),
              onPressed: _addTestDataToSupabase,
              tooltip: 'إضافة بيانات تجريبية إلى Supabase',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _forceRefreshData,
            tooltip: 'تحديث البيانات من Supabase',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 معلومات النظام
            Card(
              color: _usingRealData ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _usingRealData ? Icons.cloud_done : Icons.sim_card,
                          color: _usingRealData ? Colors.green : Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _usingRealData ? '✅ متصل بـ Supabase' : '⚠️ وضع المحاكاة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _usingRealData ? Colors.green.shade800 : Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _usingRealData 
                                    ? 'بيانات النبض تُجلب من قاعدة البيانات'
                                    : 'بيانات النبض محاكاة (لا توجد بيانات في device_readings)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_deviceSerialNumber != null)
                      Row(
                        children: [
                          Icon(Icons.device_hub, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'رقم الجهاز: $_deviceSerialNumber',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!_usingRealData)
                            ElevatedButton(
                              onPressed: _addTestDataToSupabase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade100,
                                foregroundColor: Colors.blue.shade800,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text('إضافة بيانات تجريبية'),
                            ),
                        ],
                      ),
=======
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 بطاقة الترحيب
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, size: 25, color: Colors.blue.shade700),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً ${widget.userName ?? 'مستخدم'} 👋',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'نظام مراقبة الصحة الذكي',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                          if (widget.userDevice != null)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.device_hub, size: 12, color: Colors.grey.shade600),
                                  SizedBox(width: 4),
                                  Text(
                                    'الجهاز: ${widget.userDevice!['serial_number']}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.blue, size: 20),
                      onPressed: () {
                        setState(() {
                          _heartRate = 70 + (DateTime.now().second % 20);
                          _updateHistoryData();
                        });
                      },
                    ),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                  ],
                ),
              ),
            ),

<<<<<<< HEAD
            const SizedBox(height: 16),
=======
            SizedBox(height: 16),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e

            // 🔹 بطاقات القياس مع جرافات
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
<<<<<<< HEAD
              physics: const NeverScrollableScrollPhysics(),
=======
              physics: NeverScrollableScrollPhysics(),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
              childAspectRatio: 1.3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildHealthCardWithGraph(
                  'معدل ضربات القلب',
                  _heartRate,
                  'نبضة/دقيقة',
                  Icons.favorite,
                  _getHeartRateColor(_heartRate),
                  _heartRateHistory,
<<<<<<< HEAD
                  true,
=======
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                ),
                _buildHealthCardWithGraph(
                  'ضغط الدم',
                  _bloodPressure,
                  'ملم زئبق',
                  Icons.speed,
                  _getBloodPressureColor(_bloodPressure),
                  _bloodPressureHistory,
<<<<<<< HEAD
                  false,
=======
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                ),
                _buildHealthCardWithGraph(
                  'مستوى الأكسجين',
                  _oxygenLevel,
                  '%',
                  Icons.water_drop,
                  _getOxygenColor(_oxygenLevel),
                  _oxygenHistory,
<<<<<<< HEAD
                  false,
=======
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                ),
                _buildHealthCardWithGraph(
                  'درجة الحرارة',
                  _temperature,
                  '°C',
                  Icons.thermostat,
                  _getTemperatureColor(_temperature),
                  _temperatureHistory,
<<<<<<< HEAD
                  false,
=======
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                ),
              ],
            ),

<<<<<<< HEAD
            const SizedBox(height: 16),
=======
            SizedBox(height: 16),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e

            // 🔹 جراف رئيسي لمعدل ضربات القلب
            Card(
              elevation: 3,
              child: Padding(
<<<<<<< HEAD
                padding: const EdgeInsets.all(12),
=======
                padding: EdgeInsets.all(12),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
<<<<<<< HEAD
                        Icon(
                          Icons.favorite,
                          color: _usingRealData ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'معدل ضربات القلب',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'آخر ${_heartRateHistory.length} قراءة',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 150,
                      child: _heartRateHistory.isEmpty
                          ? const Center(child: Text('لا توجد بيانات نبض'))
                          : _buildMainGraph(
                              _heartRateHistory,
                              _usingRealData ? Colors.green : Colors.red,
                              'نبضة/دقيقة',
                            ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('الأدنى', _getMinValue(_heartRateHistory)),
                        _buildStatItem('الأعلى', _getMaxValue(_heartRateHistory)),
                        _buildStatItem('المتوسط', _getAverageValue(_heartRateHistory)),
=======
                        Icon(Icons.show_chart, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'تطور معدل ضربات القلب',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text(
                          'آخر 6 قراءات',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 120,
                      child: _buildMainGraph(_heartRateHistory, Colors.red, 'نبضة/دقيقة'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // 🔹 إحصائيات سريعة
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 ملخص اليوم',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickStat('قراءات اليوم', '24', Icons.assessment),
                        _buildQuickStat('في النطاق', '22', Icons.check_circle),
                        _buildQuickStat('تحت المراقبة', '2', Icons.warning),
                        _buildQuickStat('التوصيات', '3', Icons.medical_services),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                      ],
                    ),
                  ],
                ),
              ),
            ),

<<<<<<< HEAD
            const SizedBox(height: 16),

            // 🔹 معلومات التقنية
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 معلومات التقنية',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTechInfoItem('مصدر بيانات النبض', 
                      _usingRealData ? 'Supabase (جدول device_readings)' : 'محاكاة'),
                    _buildTechInfoItem('رقم الجهاز', 
                      _deviceSerialNumber?.toString() ?? 'غير محدد'),
                    _buildTechInfoItem('عدد القراءات', '${_heartRateHistory.length}'),
                    _buildTechInfoItem('آخر تحديث', _getFormattedTime()),
                    _buildTechInfoItem('معدل التحديث', 'كل 5 ثواني'),
                    if (!_usingRealData)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
=======
            SizedBox(height: 16),

            // 🔹 حالة الاتصال
            if (widget.userDevice != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.wifi, size: 16, color: Colors.green),
                      ),
                      SizedBox(width: 10),
                      Expanded(
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
<<<<<<< HEAD
                              '💡 ملاحظة: لإظهار بيانات حقيقية من Supabase:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '1. تأكد من وجود بيانات في جدول device_readings\n'
                              '2. تأكد أن device_serial يطابق $_deviceSerialNumber\n'
                              '3. اضغط زر "إضافة بيانات تجريبية"',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
=======
                              'جهاز متصل',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'آخر تحديث: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
                            ),
                          ],
                        ),
                      ),
<<<<<<< HEAD
                  ],
                ),
              ),
            ),
=======
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'نشط',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTechInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMinValue(List<double> data) {
    if (data.isEmpty) return '0';
    return data.reduce((a, b) => a < b ? a : b).toStringAsFixed(0);
  }

  String _getMaxValue(List<double> data) {
    if (data.isEmpty) return '0';
    return data.reduce((a, b) => a > b ? a : b).toStringAsFixed(0);
  }

  String _getAverageValue(List<double> data) {
    if (data.isEmpty) return '0';
    final sum = data.reduce((a, b) => a + b);
    return (sum / data.length).toStringAsFixed(0);
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Widget _buildMainGraph(List<double> data, Color color, String unit) {
    if (data.isEmpty) return const Center(child: Text('لا توجد بيانات'));

    final minY = data.reduce((a, b) => a < b ? a : b) - 5;
    final maxY = data.reduce((a, b) => a > b ? a : b) + 5;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length > 1 ? (data.length - 1).toDouble() : 10,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
=======
  Widget _buildMainGraph(List<double> data, Color color, String unit) {
    if (data.isEmpty) return Center(child: Text('لا توجد بيانات'));

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 10,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: data.length > 1 ? (data.length - 1).toDouble() : 5,
        minY: data.reduce((a, b) => a < b ? a : b) - 5,
        maxY: data.reduce((a, b) => a > b ? a : b) + 5,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
            isCurved: true,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
<<<<<<< HEAD
            dotData: const FlDotData(show: false),
=======
            dotData: FlDotData(show: true),
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
<<<<<<< HEAD
      duration: const Duration(milliseconds: 300),
    );
  }

=======
      duration: Duration(milliseconds: 300),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // 🔹 دوال تحديد الألوان
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
  Color _getHeartRateColor(double rate) {
    if (rate > 90) return Colors.red;
    if (rate < 60) return Colors.orange;
    return Colors.green;
  }

  Color _getBloodPressureColor(double pressure) {
    if (pressure > 140) return Colors.red;
    if (pressure < 110) return Colors.orange;
    return Colors.green;
  }

  Color _getOxygenColor(double oxygen) {
    if (oxygen < 95) return Colors.red;
    return Colors.blue;
  }

  Color _getTemperatureColor(double temp) {
    if (temp > 37.5) return Colors.red;
    return Colors.purple;
  }
}

<<<<<<< HEAD
=======
// 🔹 رسام الجراف المصغر
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
class _MiniGraphPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _MiniGraphPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

<<<<<<< HEAD
=======
    final path = Path();
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
    final points = <Offset>[];

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    final xStep = size.width / (data.length - 1);
    final yScale = range > 0 ? size.height / range : size.height;

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - ((data[i] - minValue) * yScale);
      points.add(Offset(x, y));
    }

<<<<<<< HEAD
=======
    // رسم الخط
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

<<<<<<< HEAD
    if (points.length > 1) {
      final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
=======
    // رسم التعبئة
    if (points.length > 1) {
      final fillPath = Path()
        ..moveTo(points.first.dx, points.first.dy);
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e

      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
    }
<<<<<<< HEAD
=======

    // رسم النقاط
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 1.5, dotPaint);
    }
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}