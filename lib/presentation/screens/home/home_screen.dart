import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math';
import '../../../ai/ai_service.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  final Map<String, dynamic>? userDevice;
  final String userEmail;

  const HomeScreen({
    super.key,
    this.userName,
    this.userDevice,
    required this.userEmail, // ⭐️ تأكد من وجود required
  });
=======

class HomeScreen extends StatefulWidget {
  final String? userName; // ⭐ اسم المستخدم
  final Map<String, dynamic>? userDevice; // ⭐ بيانات الجهاز

  const HomeScreen({super.key, this.userName, this.userDevice});

>>>>>>> f987f9d (New Editing)
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  final SupabaseClient supabase = Supabase.instance.client;
  bool _loading = true;
  bool _usingRealData = false;
  bool _hasRealHeartRateData = false;
  double _heartRate = 72.0;
  List<double> _heartRateHistory = [];

  double _bloodPressure = 120.0;
  double _oxygenLevel = 98.0;
  double _temperature = 36.8;
  List<double> _bloodPressureHistory = [];
  List<double> _oxygenHistory = [];
  List<double> _temperatureHistory = [];

  int? _deviceSerialNumber; // ⭐️ تغيير من String? إلى int?
  late Timer _updateTimer;
=======
  bool _loading = true;
  double _heartRate = 72.0;
  double _bloodPressure = 120.0;
  double _oxygenLevel = 98.0;
  double _temperature = 36.8;
>>>>>>> f987f9d (New Editing)

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _initializeStaticHistoryData();
    _startDataLoading();
  }

  void _initializeEmptyHeartRate() {
    setState(() {
      _heartRateHistory = []; // ⭐ تاريخ فارغ
      _heartRate = 0; // ⭐ قيمة صفر
      _usingRealData = true; // ⭐ نظل متصلين بـ Supabase
      _hasRealHeartRateData = false; // ⭐ لكن لا توجد بيانات
    });
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
      final String emailToFetch = widget.userEmail;
      print('🔍 البحث عن بيانات المستخدم: $emailToFetch');

      final profileResponse = await supabase
          .from('profiles')
          .select('serial_number, full_name')
          .eq('email', emailToFetch)
          .maybeSingle();

      if (profileResponse != null && profileResponse['serial_number'] != null) {
        _deviceSerialNumber = profileResponse['serial_number'] as int;
        print('✅ تم العثور على رقم الجهاز: $_deviceSerialNumber');

        await _fetchRealHeartRateData(); // ⭐ استدعاء الدالة المعدلة

        if (_hasRealHeartRateData) {
          // ⭐ تحقق من هذا المتغير بدلاً من _heartRateHistory.isNotEmpty
          print('✅ جلب ${_heartRateHistory.length} قراءة نبض من Supabase');
        } else {
          print('⚠️ لا توجد قراءات نبض في قاعدة البيانات');
          // ⭐ لا تستدعي _initializeSimulatedHeartRate هنا
          // ⭐ دع _fetchRealHeartRateData تتعامل مع الحالة
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
      print('🔍 جاري البحث عن بيانات النبض من Supabase...');

      final response = await supabase
          .from('device_readings')
          .select('reading_value, reading_time')
          .eq('device_serial', _deviceSerialNumber!)
          .order('reading_time', ascending: false)
          .limit(15);

      if (response.isNotEmpty) {
        print('✅ تم العثور على ${response.length} قراءة في Supabase');

        final List<double> newHistory = [];
        for (var reading in response.reversed.toList()) {
          final value = reading['reading_value'];
          if (value != null) {
            newHistory.add((value as num).toDouble());
          }
        }

        if (newHistory.isNotEmpty) {
          setState(() {
            _heartRateHistory = newHistory;
            _heartRate = newHistory.last;
            _usingRealData = true;
            _hasRealHeartRateData = true;
          });
          print('📊 تم تحميل ${newHistory.length} قراءة نبض حقيقية');
        } else {
          print('⚠️ القراءات موجودة ولكن فارغة');
          _initializeEmptyHeartRate(); // ⭐ استخدم الدالة الجديدة
        }
      } else {
        print('⚠️ لا توجد قراءات نهائياً في Supabase');
        _initializeEmptyHeartRate(); // ⭐ استخدم الدالة الجديدة
      }
    } catch (e) {
      print('❌ خطأ في جلب بيانات النبض: $e');
      setState(() {
        _usingRealData = false;
        _hasRealHeartRateData = false;
      });
      _initializeSimulatedHeartRate(); // ⭐ فقط في حالة الخطأ
    }
  }

  Future<void> _fetchLatestHeartRate() async {
    if (_deviceSerialNumber == null || !_usingRealData) return;

    try {
      final response = await supabase
          .from('device_readings')
          .select('reading_value, reading_time')
          .eq('device_serial', _deviceSerialNumber!)
          .order('reading_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null && response['reading_value'] != null) {
        final newHeartRate = (response['reading_value'] as num).toDouble();
        final readingTime = response['reading_time'] as String?;

        print('🔄 تم استلام قراءة جديدة: $newHeartRate في $readingTime');

        setState(() {
          _heartRate = newHeartRate;
          _hasRealHeartRateData = true;

          if (_heartRateHistory.length >= 15) {
            _heartRateHistory.removeAt(0);
          }
          _heartRateHistory.add(_heartRate);
        });
      } else {
        print('⚠️ لا توجد قراءات جديدة من الجهاز');
        // لا نغير _hasRealHeartRateData لأن قد تكون هناك قراءات قديمة
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
      }
    });
  }

  void _initializeSimulatedHeartRate() {
    final random = Random();
    final List<double> initialHistory = [];

    for (int i = 0; i < 10; i++) {
      initialHistory.add(70 + random.nextDouble() * 20);
    }

    setState(() {
      _heartRateHistory = initialHistory;
      _heartRate = initialHistory.last;
      _usingRealData = false; // ⭐ محاكاة
      _hasRealHeartRateData = false; // ⭐ ليست بيانات حقيقية
    });
  }

  void _updateSimulatedHeartRate() {
    if (_hasRealHeartRateData) return; // ⭐ لا نحدث إذا كان لدينا بيانات حقيقية

    final random = Random();
    final newHeartRate = 70 + random.nextDouble() * 20;

    setState(() {
      _heartRate = newHeartRate;

      if (_heartRateHistory.length >= 20) {
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
  }

  void _addToHistory(List<double> history, double newValue, int maxLength) {
    if (history.length >= maxLength) {
      history.removeAt(0);
    }
    history.add(newValue);
  }

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
          'reading_time': DateTime.now()
              .subtract(Duration(minutes: i * 5))
              .toIso8601String(),
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
    final bool isEmpty =
        isHeartRate && !_hasRealHeartRateData && _usingRealData;
    final bool isSimulated = isHeartRate && !_usingRealData;

    return Card(
      elevation: 3,
      color: isEmpty ? Colors.grey[100] : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
=======
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
>>>>>>> f987f9d (New Editing)
        child: Column(
          children: [
            Row(
              children: [
<<<<<<< HEAD
                Icon(
                  icon,
                  color: isEmpty
                      ? Colors.grey
                      : (isSimulated ? Colors.orange : color),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isEmpty ? Colors.grey[600] : Colors.black,
                        ),
                      ),
                      if (isHeartRate)
                        Text(
                          isEmpty
                              ? 'لا توجد بيانات'
                              : (isSimulated ? '(محاكاة)' : '(بيانات حقيقية)'),
                          style: TextStyle(
                            fontSize: 10,
                            color: isEmpty
                                ? Colors.grey
                                : (isSimulated ? Colors.orange : Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'فارغة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'آخر إرسال: غير متاح',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value.toStringAsFixed(title == 'درجة الحرارة' ? 1 : 0),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSimulated ? Colors.orange : color,
                        ),
                      ),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (isHeartRate && _usingRealData)
                        Text(
                          'آخر إرسال: ${_getLastUpdateTime()}',
                          style: TextStyle(fontSize: 9, color: Colors.green),
                        ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 جراف مصغر
            Container(
              height: 40,
              child: isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sync_disabled,
                            size: 16,
                            color: Colors.grey,
                          ),
                          Text(
                            'بانتظار البيانات',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : _buildMiniGraph(
                      history,
                      isSimulated ? Colors.orange : color,
                    ),
            ),

            const SizedBox(height: 4),

            // 🔹 مؤشر الحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isEmpty)
                  Row(
                    children: [
                      Icon(Icons.wifi_off, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'غير متصل بالجهاز',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  )
                else if (isSimulated)
                  Row(
                    children: [
                      Icon(Icons.sim_card, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'بيانات محاكاة',
                        style: TextStyle(fontSize: 10, color: Colors.orange),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.cloud_done, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'بيانات حقيقية',
                        style: TextStyle(fontSize: 10, color: Colors.green),
                      ),
                    ],
                  ),

                if (!isEmpty && history.length >= 2)
                  Row(
                    children: [
                      Icon(
                        _getTrendIcon(history),
                        size: 12,
                        color: _getTrendColor(history),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _getTrendText(history),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getTrendColor(history),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
=======
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
>>>>>>> f987f9d (New Editing)
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildMiniGraph(List<double> data, Color color) {
    if (data.isEmpty) return const SizedBox();
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: _MiniGraphPainter(data, color),
    );
  }

  String _getLastUpdateTime() {
    if (_heartRateHistory.isEmpty) return 'غير متاح';

    // يمكنك تخزين وقت آخر قراءة إذا كان عندك
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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
        title: const Text('Helth Care'),
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
              color: _usingRealData
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
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
                                _usingRealData
                                    ? ' Conected Supabase'
                                    : '⚠️  Virtual Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _usingRealData
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text('إضافة بيانات تجريبية'),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // 🔹 بطاقة الترحيب
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 25,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً ${widget.userName ?? 'مستخدم'} 👋', // ⭐ اسم الشخص هنا
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'نظام مراقبة الصحة الذكي',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _usingRealData
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                size: 12,
                                color: _usingRealData
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _usingRealData
                                    ? 'متصل بـ Supabase'
                                    : 'بيانات محاكاة',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _usingRealData
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.blue, size: 20),
                      onPressed:
                          _forceRefreshData, // ⭐ غير من _addTestDataToSupabase إلى _forceRefreshData
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // بعد بطاقة الترحيب مباشرة
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      _usingRealData ? Icons.cloud_done : Icons.cloud_off,
                      color: _usingRealData ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
=======
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
>>>>>>> f987f9d (New Editing)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
<<<<<<< HEAD
                            _usingRealData ? 'متصل بـ Supabase' : 'غير متصل',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _usingRealData
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          if (_usingRealData && _heartRateHistory.isNotEmpty)
                            Text(
                              'آخر قراءة: ${_heartRate.toStringAsFixed(0)} نبضة/دقيقة',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            )
                          else if (_usingRealData)
                            Text(
                              'جاري انتظار البيانات...',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_deviceSerialNumber != null)
                      Chip(
                        label: Text(
                          'جهاز $_deviceSerialNumber',
                          style: TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.blue[50],
                      ),
                  ],
                ),
              ),
            ),
            // 🔹 بطاقات القياس مع جرافات
            // عرض رسالة إذا كانت البيانات فارغة
            if (_usingRealData && !_hasRealHeartRateData)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'لا توجد بيانات في Supabase. الجهاز متصل ولكن لم يرسل بيانات بعد.',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _addTestDataToSupabase,
                        child: Text('إضافة بيانات تجريبية'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildHealthCardWithGraph(
                  'معدل ضربات القلب',
                  _heartRateHistory.isEmpty
                      ? 0
                      : _heartRate, // ⭐ تمرير 0 إذا فارغة
                  'نبضة/دقيقة',
                  Icons.favorite,
                  _getHeartRateCardColor(), // ⭐ استخدام اللون الجديد
                  _heartRateHistory,
                  true,
                ),
                _buildHealthCardWithGraph(
                  'ضغط الدم',
                  _bloodPressure,
                  'ملم زئبق',
                  Icons.speed,
                  _getBloodPressureColor(_bloodPressure),
                  _bloodPressureHistory,
                  false,
                ),
                _buildHealthCardWithGraph(
                  'مستوى الأكسجين',
                  _oxygenLevel,
                  '%',
                  Icons.water_drop,
                  _getOxygenColor(_oxygenLevel),
                  _oxygenHistory,
                  false,
                ),
                _buildHealthCardWithGraph(
                  'درجة الحرارة',
                  _temperature,
                  '°C',
                  Icons.thermostat,
                  _getTemperatureColor(_temperature),
                  _temperatureHistory,
                  false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 جراف رئيسي لمعدل ضربات القلب
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                      height: 120,
                      child: _heartRateHistory.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.heart_broken,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لا توجد بيانات نبض',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (_usingRealData)
                                    Text(
                                      'جاري انتظار بيانات من الجهاز',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                            )
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
                        _buildStatItem(
                          'الأدنى',
                          _getMinValue(_heartRateHistory),
                        ),
                        _buildStatItem(
                          'الأعلى',
                          _getMaxValue(_heartRateHistory),
                        ),
                        _buildStatItem(
                          'المتوسط',
                          _getAverageValue(_heartRateHistory),
                        ),
                      ],
=======
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
>>>>>>> f987f9d (New Editing)
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
                    _buildTechInfoItem(
                      'مصدر بيانات النبض',
                      _usingRealData
                          ? 'Supabase (جدول device_readings)'
                          : 'محاكاة',
                    ),
                    _buildTechInfoItem(
                      'رقم الجهاز',
                      _deviceSerialNumber?.toString() ?? 'غير محدد',
                    ),
                    _buildTechInfoItem(
                      'عدد القراءات',
                      '${_heartRateHistory.length}',
                    ),
                    _buildTechInfoItem('آخر تحديث', _getFormattedTime()),
                    _buildTechInfoItem('معدل التحديث', 'كل 5 ثواني'),
                    if (!_usingRealData)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                            ),
                          ],
                        ),
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
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
=======
>>>>>>> f987f9d (New Editing)
        ],
      ),
    );
  }
<<<<<<< HEAD

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
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
            isCurved: true,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
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
      duration: const Duration(milliseconds: 300),
    );
  }

  String _getHeartRateDisplayText() {
    if (_heartRateHistory.isEmpty) {
      return 'فارغة';
    }
    return _heartRate.toStringAsFixed(0);
  }

  Color _getHeartRateCardColor() {
    if (_usingRealData && !_hasRealHeartRateData) {
      return Colors
          .grey; // ⭐ لون رمادي عندما متصل بـ Supabase ولكن لا توجد بيانات
    }
    if (!_usingRealData) {
      return Colors.orange; // ⭐ لون برتقالي للمحاكاة
    }
    return _getHeartRateColor(_heartRate); // ⭐ اللون الطبيعي حسب القيمة
  }

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

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    if (points.length > 1) {
      final fillPath = Path()..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
=======
}
>>>>>>> f987f9d (New Editing)
