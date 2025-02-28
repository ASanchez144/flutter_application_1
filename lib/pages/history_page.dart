import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> drinks = [];
  String selectedFilter = "week";
  bool isLoading = false;
  String errorMessage = "";
  Set<String> selectedDrinks = {};

  final Map<String, Color> drinkColors = {
    "Water": Colors.blue,
    "Juice": Colors.orange,
    "Soda": Colors.red,
    "Coffee": Colors.brown,
    "Beer": Colors.yellow,
    "Wine": Colors.purple,
  };

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
      final response = await DatabaseHelper.instance.getDrinks(selectedFilter);
      setState(() => drinks = response);
    } catch (e) {
      setState(() {
        errorMessage = "❌ Error loading drink history.";
        print("❌ Error: $e");
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Aggregates drink volumes per period (hour/day/week/month) based on the selected filter.
  Map<String, Map<int, double>> getDrinkVolumesPerPeriod() {
    Map<String, Map<int, double>> volumesPerPeriod = {};
    for (var drink in drinks) {
      String name = drink['name'];
      // Convert volume from milliliters to liters.
      double volume = ((drink['volume'] as num).toDouble() / 1000);
      DateTime timestamp = DateTime.parse(drink['timestamp']).toLocal();
      int period;

      if (selectedFilter == "year") {
        period = timestamp.month;
      } else if (selectedFilter == "month") {
        period = timestamp.day;
      } else if (selectedFilter == "week") {
        period = timestamp.weekday;
      } else {
        period = timestamp.hour;
      }

      volumesPerPeriod.putIfAbsent(name, () => {});
      volumesPerPeriod[name]![period] = (volumesPerPeriod[name]![period] ?? 0) + volume;
    }
    return volumesPerPeriod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Activity Page",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFilterTabs(),
            const SizedBox(height: 20),
            if (isLoading) const LinearProgressIndicator(),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            if (drinks.isNotEmpty) buildDrinkFilters(),
            if (drinks.isNotEmpty) Expanded(child: buildChart()),
            const SizedBox(height: 20),
            if (drinks.isNotEmpty) buildStats(),
          ],
        ),
      ),
    );
  }

  Widget buildFilterTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ["today", "week", "month", "year"].map((filter) {
        bool isSelected = selectedFilter == filter;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedFilter = filter;
              loadDrinks();
            });
          },
          child: Column(
            children: [
              Text(
                filter.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 40,
                  color: Colors.blue,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildDrinkFilters() {
    final drinkNames = drinks.map((drink) => drink['name']).toSet().toList();
    return Wrap(
      spacing: 10,
      children: drinkNames.map((drink) {
        bool isSelected = selectedDrinks.contains(drink);
        return FilterChip(
          label: Text(drink),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedDrinks.add(drink);
              } else {
                selectedDrinks.remove(drink);
              }
            });
          },
          backgroundColor: drinkColors[drink]?.withOpacity(0.3),
          selectedColor: drinkColors[drink],
        );
      }).toList(),
    );
  }

  /// Updated chart: using a LineChart to display each drink's trend over time.
  /// For the "week" filter, we ensure that the X axis spans the full screen width.
  Widget buildChart() {
    final drinkVolumesPerPeriod = getDrinkVolumesPerPeriod();
    int maxPeriod = selectedFilter == "year"
        ? 12
        : selectedFilter == "month"
            ? 31
            : selectedFilter == "week"
                ? 7
                : 24;

    // Determine the overall maximum Y value across all drinks and periods.
    double maxY = 0;
    drinkVolumesPerPeriod.forEach((drink, periodMap) {
      if (selectedDrinks.isNotEmpty && !selectedDrinks.contains(drink)) return;
      periodMap.forEach((period, volume) {
        if (volume > maxY) maxY = volume;
      });
    });
    maxY = (maxY + 1).ceilToDouble();

    // Create a line for each drink series.
    List<LineChartBarData> lineBarsData = [];
    drinkVolumesPerPeriod.forEach((drinkName, periodMap) {
      if (selectedDrinks.isNotEmpty && !selectedDrinks.contains(drinkName)) return;
      List<FlSpot> spots = [];
      for (int period = 1; period <= maxPeriod; period++) {
        double volume = periodMap[period] ?? 0;
        spots.add(FlSpot(period.toDouble(), volume));
      }
      final color = drinkColors[drinkName] ?? Colors.grey;
      lineBarsData.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: FlDotData(show: true),
      ));
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // For the week filter, force the chart to use the full available width.
        // For others, use the computed width (but ensure it's at least as wide as the screen).
        double chartWidth = selectedFilter == "week"
            ? constraints.maxWidth
            : max(maxPeriod * 50.0, constraints.maxWidth);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 300,
            child: LineChart(
              LineChartData(
                lineBarsData: lineBarsData,
                minX: 1,
                maxX: maxPeriod.toDouble(),
                minY: 0,
                maxY: maxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (selectedFilter == "year") {
                          List<String> months = [
                            "Jan",
                            "Feb",
                            "Mar",
                            "Apr",
                            "May",
                            "Jun",
                            "Jul",
                            "Aug",
                            "Sep",
                            "Oct",
                            "Nov",
                            "Dec"
                          ];
                          int index = value.toInt() - 1;
                          return Text(
                            index >= 0 && index < months.length ? months[index] : '',
                            style: const TextStyle(fontSize: 10),
                          );
                        } else if (selectedFilter == "month") {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        } else if (selectedFilter == "week") {
                          List<String> days = ["M", "T", "W", "T", "F", "S", "S"];
                          int index = value.toInt() - 1;
                          return Text(
                            index >= 0 && index < days.length ? days[index] : '',
                            style: const TextStyle(fontSize: 10),
                          );
                        } else {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) =>
                          Text("${value.toStringAsFixed(1)} L", style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildStats() {
    double totalLiters = drinks.fold(0.0, (sum, drink) => sum + ((drink['volume'] as num).toDouble() / 1000));
    double averageLiters = totalLiters / drinks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildStatTile("Total Liters", totalLiters.toStringAsFixed(2)),
            buildStatTile("Average per Drink", averageLiters.toStringAsFixed(2)),
            buildStatTile("Evolution", "+30%", color: Colors.blue),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Drink Breakdown", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...getDrinkVolumesPerPeriod().entries.map((entry) {
          final totalVolume = entry.value.values.fold(0.0, (sum, volume) => sum + volume);
          return ListTile(
            title: Text(entry.key),
            trailing: Text("${totalVolume.toStringAsFixed(2)} L"),
          );
        }).toList(),
      ],
    );
  }

  Widget buildStatTile(String title, String value, {Color color = Colors.black}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
