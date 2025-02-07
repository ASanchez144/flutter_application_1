import 'package:flutter/material.dart';
import '../database_helper.dart';

class VolumePage extends StatelessWidget {
  final String drinkName;

  const VolumePage({super.key, required this.drinkName});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> volumes = [
      {"label": "Shot", "icon": 'assets/icons/icon_shot.png', "volume": 60},   // 60 ml
      {"label": "Cup", "icon": 'assets/icons/icon_cup.png', "volume": 200},    // 200 ml
      {"label": "Glass", "icon": 'assets/icons/icon_glass.png', "volume": 250},// 250 ml
      {"label": "Pint", "icon": 'assets/icons/icon_pint.png', "volume": 586},  // 586 ml
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Select Volume for $drinkName')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: volumes.length,
        itemBuilder: (context, index) {
          final volume = volumes[index];
          return GestureDetector(
            onTap: () {
              final int volumeInMl = volume["volume"] as int;  // Ensure it's int
              DatabaseHelper.instance.addDrink(drinkName, volumeInMl.toDouble());  // Convert safely to double
              Navigator.pop(context);
            },
            child: VolumeCard(
              label: volume["label"] as String,
              iconPath: volume["icon"] as String,
              volume: volume["volume"] as int,
            ),
          );
        },
      ),
    );
  }
}

// Custom widget for volume cards
class VolumeCard extends StatelessWidget {
  final String label;
  final String iconPath;
  final int volume;

  const VolumeCard({super.key, required this.label, required this.iconPath, required this.volume});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 50, height: 50),
            const SizedBox(height: 10),
            Text('$label (${(volume / 1000).toStringAsFixed(1)} L)', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
