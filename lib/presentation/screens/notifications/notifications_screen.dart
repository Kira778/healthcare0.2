import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'قراءة غير طبيعية',
      'message': 'معدل ضربات القلب مرتفع قليلاً',
      'time': 'منذ 10 دقائق',
      'type': 'warning',
      'read': false,
    },
    {
      'title': 'تذكير الفحص',
      'message': 'حان وقت الفحص الدوري',
      'time': 'منذ ساعة',
      'type': 'reminder',
      'read': true,
    },
    {
      'title': 'اتصال ناجح',
      'message': 'تم الاتصال بالجهاز بنجاح',
      'time': 'منذ 3 ساعات',
      'type': 'success',
      'read': true,
    },
    {
      'title': 'تحديث النظام',
      'message': 'تحديث جديد متاح للتطبيق',
      'time': 'منذ يوم',
      'type': 'info',
      'read': true,
    },
    {
      'title': 'نصيحة صحية',
      'message': 'احرص على النوم 8 ساعات يومياً',
      'time': 'منذ يومين',
      'type': 'tip',
      'read': true,
    },
  ];

  IconData _getIconByType(String type) {
    switch (type) {
      case 'warning': return Icons.warning;
      case 'reminder': return Icons.access_time;
      case 'success': return Icons.check_circle;
      case 'info': return Icons.info;
      case 'tip': return Icons.medical_services;
      default: return Icons.notifications;
    }
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'warning': return Colors.orange;
      case 'reminder': return Colors.blue;
      case 'success': return Colors.green;
      case 'info': return Colors.purple;
      case 'tip': return Colors.teal;
      default: return Colors.grey;
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإشعارات',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (_notifications.isNotEmpty)
                  TextButton(
                    onPressed: _clearAll,
                    child: Text('مسح الكل'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _notifications.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey[400]),
                  SizedBox(height: 10),
                  Text(
                    'لا توجد إشعارات',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key(notification['title']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    color: notification['read'] ? Colors.white : Colors.blue[50],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorByType(notification['type']).withOpacity(0.1),
                        child: Icon(
                          _getIconByType(notification['type']),
                          color: _getColorByType(notification['type']),
                        ),
                      ),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification['message']),
                          SizedBox(height: 5),
                          Text(
                            notification['time'],
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: !notification['read']
                          ? IconButton(
                        icon: Icon(Icons.mark_email_read),
                        onPressed: () => _markAsRead(index),
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          _notifications[index]['read'] = true;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}