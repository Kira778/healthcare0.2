import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/main_layout.dart';
import 'core/auth/auth_gate.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dswsqxyezweqjukyuelz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRzd3NxeHllendlcWp1a3l1ZWx6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NDYwNDYsImV4cCI6MjA5MjUyMjA0Nn0.NztpuVWAxVkBp1t2vo3_sTvzSuHIxKfmUZ-2wHWEgb8',
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
