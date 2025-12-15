import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  final Map<String, dynamic>? userDevice;

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

  // 🔹 بيانات الجرافات المصغرة
  List<double> _heartRateHistory = [];
  List<double> _bloodPressureHistory = [];
  List<double> _oxygenHistory = [];
  List<double> _temperatureHistory = [];

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
      }
    });
  }

  void _updateHistoryData() {
    // تحديث بيانات التاريخ مع الحفاظ على 6 قراءات فقط
    _addToHistory(_heartRateHistory, _heartRate, 6);
    _addToHistory(_bloodPressureHistory, _bloodPressure, 6);
    _addToHistory(_oxygenHistory, _oxygenLevel, 6);
    _addToHistory(_temperatureHistory, _temperature, 6);
  }

  void _addToHistory(List<double> history, double newValue, int maxLength) {
    if (history.length >= maxLength) {
      history.removeAt(0);
    }
    history.add(newValue);
  }

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
                SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
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
                    SizedBox(width: 2),
                    Text(
                      '${_calculateTrend(history).toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
    if (data.length < 2) return SizedBox();

    return CustomPaint(
      size: Size(double.infinity, 40),
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
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // 🔹 بطاقات القياس مع جرافات
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                ),
                _buildHealthCardWithGraph(
                  'ضغط الدم',
                  _bloodPressure,
                  'ملم زئبق',
                  Icons.speed,
                  _getBloodPressureColor(_bloodPressure),
                  _bloodPressureHistory,
                ),
                _buildHealthCardWithGraph(
                  'مستوى الأكسجين',
                  _oxygenLevel,
                  '%',
                  Icons.water_drop,
                  _getOxygenColor(_oxygenLevel),
                  _oxygenHistory,
                ),
                _buildHealthCardWithGraph(
                  'درجة الحرارة',
                  _temperature,
                  '°C',
                  Icons.thermostat,
                  _getTemperatureColor(_temperature),
                  _temperatureHistory,
                ),
              ],
            ),

            SizedBox(height: 16),

            // 🔹 جراف رئيسي لمعدل ضربات القلب
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                      ],
                    ),
                  ],
                ),
              ),
            ),

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جهاز متصل',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'آخر تحديث: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
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
          ],
        ),
      ),
    );
  }

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
            isCurved: true,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
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

// 🔹 رسام الجراف المصغر
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

    final path = Path();
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

    // رسم الخط
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // رسم التعبئة
    if (points.length > 1) {
      final fillPath = Path()
        ..moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
    }

    // رسم النقاط
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}