import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  final user = SupabaseConfig.client.auth.currentUser;

  /// Add a drink (stored in milliliters)
  Future<void> addDrink(String name, double volumeInLiters) async {
    final drinkData = {
      "user_id": user?.id,
      "name": name,
      "volume": (volumeInLiters * 1000).toInt(),  // Convert liters to milliliters before storing
      "timestamp": DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await SupabaseConfig.client.from("drinks").insert(drinkData);
      print("☁️ Synced to Supabase: $drinkData");
    } catch (e) {
      print("❌ Supabase Sync Error: $e");
    }
  }

  /// Retrieve drinks based on date filter (convert from milliliters to liters)
  Future<List<Map<String, dynamic>>> getDrinks(String filter) async {
    DateTime now = DateTime.now().toUtc();  // Ensure UTC for accurate comparison
    DateTime? startDate, endDate;

    // Set the start and end dates based on the filter
    if (filter == "today") {
      startDate = DateTime.utc(now.year, now.month, now.day);
      endDate = startDate.add(const Duration(days: 1));
    } else if (filter == "week") {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime.utc(startDate.year, startDate.month, startDate.day);
      endDate = startDate.add(const Duration(days: 7));
    } else if (filter == "month") {
      startDate = DateTime.utc(now.year, now.month, 1);
      endDate = DateTime.utc(now.year, now.month + 1, 1);
    } else if (filter == "year") {
      startDate = DateTime.utc(now.year, 1, 1);
      endDate = DateTime.utc(now.year + 1, 1, 1);
    }

    // Ensure startDate and endDate are not null
    if (startDate == null || endDate == null) {
      print("❌ Date filter error: startDate or endDate is null");
      return [];
    }

    try {
      final response = await SupabaseConfig.client
          .from("drinks")
          .select("*")
          .gte('timestamp', startDate.toIso8601String())  // Null-safe usage
          .lt('timestamp', endDate.toIso8601String())    // Null-safe usage
          .order('timestamp', ascending: false)
          .execute();

      final data = response.data as List<dynamic>;

      // Convert volume from milliliters to liters for display
      final drinks = data.map((drink) {
        return {
          "name": drink['name'],
          "volume": (drink['volume'] as int) / 1000,  // Convert mL to Liters
          "timestamp": drink['timestamp'],
        };
      }).toList();

      print("☁️ Retrieved Supabase Drinks: $drinks");
      return drinks;
    } catch (e) {
      print("❌ Error Fetching Drinks from Supabase: $e");
      return [];
    }
  }
}
