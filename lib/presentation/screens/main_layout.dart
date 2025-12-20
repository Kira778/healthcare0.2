import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home/home_screen.dart';
import 'notifications/notifications_screen.dart';
import 'recommendations/recommendations_screen.dart';
import 'profile/profile_screen.dart';
<<<<<<< HEAD
import '../../ai/chat_screen.dart'; // عدل المسار حسب مشروعك
=======
>>>>>>> f987f9d (New Editing)

class MainLayout extends StatefulWidget {
  final Map<String, dynamic>? userDevice;
  final String? userName; // ⭐ استقبال اسم المستخدم
<<<<<<< HEAD
  final String userEmail; // ⭐ أضف هذا السطر

  const MainLayout({
    super.key,
    this.userDevice,
    this.userName,
    required this.userEmail, // ⭐ أضف required
  });
=======

  const MainLayout({super.key, this.userDevice, this.userName});

>>>>>>> f987f9d (New Editing)
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final SupabaseClient _supabase = Supabase.instance.client;

  // ⭐ قائمة الشاشات - سيتم تمرير البيانات لكل شاشة
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // ⭐ تهيئة الشاشات مع تمرير البيانات المطلوبة
    _screens = [
      HomeScreen(
        userName: widget.userName,
        userDevice: widget.userDevice,
<<<<<<< HEAD
        userEmail: widget.userEmail, // ⭐ تمرير الإيميل إلى HomeScreen
=======
>>>>>>> f987f9d (New Editing)
      ),
      NotificationsScreen(),
      RecommendationsScreen(),
      ProfileScreen(
        userName: widget.userName,
        userDevice: widget.userDevice,
<<<<<<< HEAD
        userEmail: widget.userEmail, // ⭐ إذا احتاج
=======
>>>>>>> f987f9d (New Editing)
      ),
    ];
  }

  final List<String> _appBarTitles = [
    'الصفحة الرئيسية',
    'الإشعارات',
    'التوصيات',
<<<<<<< HEAD
    'الملف الشخصي',
=======
    'الملف الشخصي'
>>>>>>> f987f9d (New Editing)
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
<<<<<<< HEAD
              _selectedIndex == 0
                  ? Icons.home
                  : _selectedIndex == 1
                  ? Icons.notifications
                  : _selectedIndex == 2
                  ? Icons.medical_services
                  : Icons.person,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              _appBarTitles[_selectedIndex],
              style: const TextStyle(color: Colors.white),
=======
              _selectedIndex == 0 ? Icons.home :
              _selectedIndex == 1 ? Icons.notifications :
              _selectedIndex == 2 ? Icons.medical_services :
              Icons.person,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              _appBarTitles[_selectedIndex],
              style: TextStyle(color: Colors.white),
>>>>>>> f987f9d (New Editing)
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        elevation: 3,
        actions: [
          if (widget.userDevice != null)
            Padding(
<<<<<<< HEAD
              padding: const EdgeInsets.only(right: 10),
              child: Chip(
                label: Text(
                  'SN: ${widget.userDevice!['serial_number']}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
=======
              padding: EdgeInsets.only(right: 10),
              child: Chip(
                label: Text(
                  'SN: ${widget.userDevice!['serial_number']}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
>>>>>>> f987f9d (New Editing)
                ),
                backgroundColor: Colors.green[700],
              ),
            ),
        ],
      ),
<<<<<<< HEAD

      // 🔥 زر AI العالمي
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 220, 214, 231),
        icon: const Icon(Icons.smart_toy),
        label: const Text('AI Chat'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
      ),

      body: _screens[_selectedIndex],

=======
      body: _screens[_selectedIndex],
>>>>>>> f987f9d (New Editing)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
<<<<<<< HEAD
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Badge(label: Text('3'), child: Icon(Icons.notifications)),
=======
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('3'),
              child: Icon(Icons.notifications),
            ),
>>>>>>> f987f9d (New Editing)
            label: 'الإشعارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'التوصيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> f987f9d (New Editing)
