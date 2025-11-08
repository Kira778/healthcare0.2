import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/main.dart';

void main() {
  testWidgets('Splash screen loads and navigates to login', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SplashScreen(),
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
        },
      ),
    );

    expect(find.text('Smart Health Emergency System'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Home screen displays metrics', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hr': 75, 'temp': 36.7});

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => HealthProvider(prefs: prefs),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Heart Rate'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });

  testWidgets('Navigation between screens works', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'hr': 75, 'temp': 36.7});

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => HealthProvider(prefs: prefs),
        child: const MaterialApp(home: MainBottomNav()),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.show_chart));
    await tester.pumpAndSettle();
    expect(find.text('Health Analysis'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();
    expect(find.text('Alerts'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Settings'), findsOneWidget);
  });
}