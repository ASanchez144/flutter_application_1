import 'package:flutter/material.dart';
import '../database_helper.dart';

class VolumePage extends StatelessWidget {
  final String drinkName;

  VolumePage({required this.drinkName});

  final List<Map<String, dynamic>> volumes = const [
    {"label": "Shot", "volume": 0.06},
    {"label": "Glass", "volume": 0.2},
    {"label": "Cup", "volume": 0.25},
    {"label": "Pint", "volume": 0.586},
    {"label": "Beer Jar", "volume": 0.75},
    {"label": "1L", "volume": 1.0},
  ];

  Future<void> _addDrink(BuildContext context, double volume) async {
    await DatabaseHelper.instance.addDrink(drinkName, volume);
    Navigator.pop(context);  // Return to the previous page after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$drinkName Volumes')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: volumes.length,
        itemBuilder: (context, index) {
          final volumeInfo = volumes[index];
          return GestureDetector(
            onTap: () => _addDrink(context, volumeInfo['volume']),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              color: Colors.purple[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_drink, size: 50, color: Colors.purple),
                    const SizedBox(height: 10),
                    Text(volumeInfo['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('${volumeInfo['volume']} L', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
