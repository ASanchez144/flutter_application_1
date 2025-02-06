import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = "https://wwxxmvhvzpbhltppvsjz.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3eHhtdmh2enBiaGx0cHB2c2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgyNTM3MDIsImV4cCI6MjA1MzgyOTcwMn0.1qyklNIUKg8kfkUOQsVSODNEF73DWqpAguBmYutM1ME";
  
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      print("✅ Supabase Initialized Successfully");
    } catch (e) {
      print("❌ Error Initializing Supabase: $e");
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}