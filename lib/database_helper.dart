import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  /// Adds a drink to Supabase
  Future<void> addDrink(String name, double volume) async {
    final user = SupabaseConfig.client.auth.currentUser;  // Get the current user session

    if (user == null) {
      print("❌ No authenticated user found!");
      return;
    }

    final drinkData = {
      "user_id": user.id,  // Make sure this matches the logged-in user's ID
      "name": name,
      "volume": volume,
      "timestamp": DateTime.now().toUtc().toIso8601String(),  // Ensure UTC storage
    };

    try {
      await SupabaseConfig.client.from("drinks").insert(drinkData);
      print("☁️ Synced to Supabase: $drinkData");
    } catch (e) {
      print("❌ Supabase Sync Error: $e");
    }
  }

  /// Retrieves drinks from Supabase with a time filter
  Future<List<Map<String, dynamic>>> getDrinks(String filter) async {
    final user = SupabaseConfig.client.auth.currentUser;  // Ensure user session is active

    if (user == null) {
      print("❌ No authenticated user found!");
      return [];
    }

    DateTime now = DateTime.now();
    DateTime? startDate;

    if (filter == "today") {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (filter == "week") {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (filter == "month") {
      startDate = DateTime(now.year, now.month, 1);
    } else if (filter == "year") {
      startDate = DateTime(now.year, 1, 1);
    }

    try {
      final response = await SupabaseConfig.client
          .from("drinks")
          .select("*")
          .eq('user_id', user.id)  // Filter drinks for the logged-in user
          .gte('timestamp', startDate?.toUtc().toIso8601String() ?? '')  // Query in UTC
          .order('timestamp', ascending: false)
          .execute();

      final data = response.data as List<dynamic>;
      print("☁️ Retrieved Supabase Drinks: $data");
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("❌ Error Fetching Drinks from Supabase: $e");
      return [];
    }
  }
}
