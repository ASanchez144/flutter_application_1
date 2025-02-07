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

  /// Retrieve drinks (convert from milliliters to liters)
  Future<List<Map<String, dynamic>>> getDrinks(String filter) async {
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
          .gte('timestamp', startDate?.toUtc().toIso8601String() ?? '')
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
