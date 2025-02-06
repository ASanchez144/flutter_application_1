import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';
import 'pages/volume_page.dart';
import 'pages/goals_page.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();  // Initialize Supabase here
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
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/history': (context) => const HistoryPage(),
        //'/goals': (context) => const GoalsPage(),
      },
    );
  }
}
