<<<<<<< HEAD
 import 'package:flutter/material.dart';
=======
import 'package:flutter/material.dart';
>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/main_layout.dart';
import 'core/auth/auth_gate.dart';

<<<<<<< HEAD
=======

>>>>>>> 510688871d3338ab9876665aa0d631033a50755e
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
