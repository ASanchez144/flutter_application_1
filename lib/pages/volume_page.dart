import 'package:flutter/material.dart';
import '../database_helper.dart';

class VolumePage extends StatelessWidget {
  final String drinkName;
  
  const VolumePage({super.key, required this.drinkName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Volume for $drinkName")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VolumeButton(volume: 250, drinkName: drinkName),
          VolumeButton(volume: 500, drinkName: drinkName),
          VolumeButton(volume: 750, drinkName: drinkName),
        ],
      ),
    );
  }
}

class VolumeButton extends StatelessWidget {
  final int volume;
  final String drinkName;

  const VolumeButton({super.key, required this.volume, required this.drinkName});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await DatabaseHelper.instance.addDrink(drinkName, volume);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$drinkName ($volume ml) added!")),
        );
        Navigator.pop(context);
      },
      child: Text("$volume ml"),
    );
  }
}
