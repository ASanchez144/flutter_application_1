import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> drinks = [];
  String selectedFilter = "today";
  String viewMode = "individual"; // Individual or Totals
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
      final data = await DatabaseHelper.instance.getDrinks(selectedFilter);
      setState(() => drinks = data);
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
          _buildFilterButtons(),
          _buildViewModeToggle(),
          if (isLoading) const LinearProgressIndicator(),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: drinks.isEmpty && !isLoading
                ? const Center(child: Text("No drinks recorded"))
                : viewMode == "individual"
                    ? _buildIndividualList()
                    : _buildTotalsView(),
          ),
        ],
      ),
    );
  }

  // Filter Buttons (Today, Week, Month, Year)
  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["today", "week", "month", "year"].map((filter) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedFilter == filter ? Colors.teal : Colors.grey,
              ),
              onPressed: () {
                setState(() => selectedFilter = filter);
                loadDrinks();
              },
              child: Text(filter.toUpperCase()),
            ),
          );
        }).toList(),
      ),
    );
  }

  // View Mode Toggle (Individual / Totals)
  Widget _buildViewModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => setState(() => viewMode = "individual"),
          child: Text(
            "Individual",
            style: TextStyle(color: viewMode == "individual" ? Colors.teal : Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => viewMode = "totals"),
          child: Text(
            "Totals",
            style: TextStyle(color: viewMode == "totals" ? Colors.teal : Colors.grey),
          ),
        ),
      ],
    );
  }

  // Individual Drink List (With Conversion to Liters)
  Widget _buildIndividualList() {
    return ListView.builder(
      itemCount: drinks.length,
      itemBuilder: (context, index) {
        final drink = drinks[index];
        final volumeInLiters = (drink['volume'] as num).toDouble() / 1000; // Convert to liters
        final formattedDate = DateFormat('dd/MM HH:mm').format(DateTime.parse(drink['timestamp']));

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(
              "${drink['name']} - ${volumeInLiters.toStringAsFixed(1)} L", // Display in liters
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(formattedDate),
          ),
        );
      },
    );
  }

  // Totals View: Aggregate Volumes by Drink Type
  Widget _buildTotalsView() {
    final Map<String, double> totals = {};

    for (var drink in drinks) {
      final name = drink['name'] as String;
      final volumeInLiters = (drink['volume'] as num).toDouble() / 1000;

      if (totals.containsKey(name)) {
        totals[name] = totals[name]! + volumeInLiters;
      } else {
        totals[name] = volumeInLiters;
      }
    }

    return ListView.builder(
      itemCount: totals.length,
      itemBuilder: (context, index) {
        final drinkName = totals.keys.elementAt(index);
        final totalVolume = totals[drinkName]!;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(
              "$drinkName - ${totalVolume.toStringAsFixed(1)} L", // Display total in liters
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
