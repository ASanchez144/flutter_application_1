import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'database_helper.dart';
import 'pages/home_page.dart';
import 'pages/auth_page.dart';
import 'pages/history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await DatabaseHelper.instance.database;  // Ensure SQLite is initialized before running app
  runApp(const DrinkTrackerApp());
}

class DrinkTrackerApp extends StatelessWidget {
  const DrinkTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drink Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      routes: {
        "/": (context) => SupabaseConfig.client.auth.currentSession == null ? const AuthPage() : const HomePage(),
        "/home": (context) => const HomePage(),
        "/history": (context) => const HistoryPage(),
      },
      initialRoute: SupabaseConfig.client.auth.currentSession == null ? "/" : "/home",
    );
  }
}

