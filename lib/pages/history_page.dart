import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // 📅 Import intl for date formatting
import '../database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> drinks = [];
  String selectedFilter = "today";
  String viewMode = "individual";  // New: 'individual' or 'totals'
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDrinks();
  }

  Future<void> loadDrinks() async {
    setState(() => isLoading = true);
    final data = await DatabaseHelper.instance.getDrinks(selectedFilter);
    setState(() {
      drinks = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drink History")),
      body: Column(
        children: [
          // Filter Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["today", "week", "month", "year"].map((filter) {
              return ElevatedButton(
                onPressed: () {
                  setState(() => selectedFilter = filter);
                  loadDrinks();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedFilter == filter ? Colors.purple : Colors.grey,
                ),
                child: Text(filter.toUpperCase()),
              );
            }).toList(),
          ),

          // View Mode Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["individual", "totals"].map((mode) {
              return ElevatedButton(
                onPressed: () {
                  setState(() => viewMode = mode);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: viewMode == mode ? Colors.purple : Colors.grey,
                ),
                child: Text(mode.toUpperCase()),
              );
            }).toList(),
          ),

          if (isLoading) const LinearProgressIndicator(),

          Expanded(
            child: drinks.isEmpty
                ? const Center(child: Text("No drinks recorded"))
                : viewMode == "individual" ? _buildIndividualView() : _buildTotalsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualView() {
    return ListView.builder(
      itemCount: drinks.length,
      itemBuilder: (context, index) {
        final drink = drinks[index];
        final date = DateTime.parse(drink['timestamp']).toLocal();
        final formattedDate = DateFormat('dd/MM HH:mm').format(date);  // 📅 Format date

        return ListTile(
          title: Text("${drink['name']} - ${drink['volume']} L"),
          subtitle: Text(formattedDate),
        );
      },
    );
  }

  Widget _buildTotalsView() {
    final totals = <String, Map<String, dynamic>>{};

    for (var drink in drinks) {
      if (totals.containsKey(drink['name'])) {
        totals[drink['name']]!['volume'] += drink['volume'];
        totals[drink['name']]!['count'] += 1;
      } else {
        totals[drink['name']] = {
          'volume': drink['volume'],
          'count': 1,
        };
      }
    }

    return ListView(
      children: totals.entries.map((entry) {
        return ListTile(
          title: Text("${entry.key}"),
          subtitle: Text("Total Volume: ${entry.value['volume']} L | Count: ${entry.value['count']}"),
        );
      }).toList(),
    );
  }
}
