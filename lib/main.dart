 import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/main_layout.dart';
import 'core/auth/auth_gate.dart';
import 'core/theme/theme_controller.dart';
import 'presentation/screens/recommendations/recommendations_screen.dart';
import 'presentation/screens/recommendations/chat_screen.dart'; // لو حابب تستخدمها مباشرة



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://feoosyjnxwlebkxojrys.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlb29zeWpueHdsZWJreG9qcnlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1NjAzMzQsImV4cCI6MjA4MTEzNjMzNH0.PaF7UN1_zN5CHWRVjE5l_2SlZI7KXh5_lUXgMsGlA9I',
  );

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: AuthGate(),
        );
      },
    );
  }
}
