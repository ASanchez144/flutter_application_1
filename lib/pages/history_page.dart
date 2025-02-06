import 'package:flutter/material.dart';
import '../database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> drinks = [];
  String selectedFilter = "today";
  bool isLoading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadDrinks();
  }

  Future<void> loadDrinks() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final localData = await DatabaseHelper.instance.getDrinks(selectedFilter);
      print("📂 Local Drinks: $localData");

      final cloudData = await DatabaseHelper.instance.getDrinksFromSupabase();
      print("☁️ Supabase Drinks: $cloudData");

      setState(() => drinks = [...localData, ...cloudData]);
    } catch (e) {
      setState(() {
        errorMessage = "❌ Error loading drink history.";
        print("❌ Error: $e");
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drink History")),
      body: Column(
        children: [
          // Filter Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["today", "week", "month", "year"].map((filter) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedFilter == filter ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                      loadDrinks();
                    },
                    child: Text(filter.toUpperCase()),
                  ),
                );
              }).toList(),
            ),
          ),

          // Loading Indicator
          if (isLoading) const LinearProgressIndicator(),

          // Error Message
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ),

          // Drink List
          Expanded(
            child: drinks.isEmpty && !isLoading
                ? const Center(child: Text("No drinks recorded"))
                : ListView.builder(
                    itemCount: drinks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            "${drinks[index]['name']} - ${drinks[index]['volume']}ml",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(drinks[index]['timestamp']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
