import 'package:flutter/material.dart';
import 'volume_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> drinks = const [
    {"name": "Water", "icon": Icons.opacity, "color": Colors.blue},
    {"name": "Juice", "icon": Icons.local_drink, "color": Colors.orange},
    {"name": "Soda", "icon": Icons.local_cafe, "color": Colors.red},
    {"name": "Coffee", "icon": Icons.coffee, "color": Colors.brown},
    {"name": "Beer", "icon": Icons.sports_bar, "color": Colors.amber},
    {"name": "Wine", "icon": Icons.wine_bar, "color": Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(title: const Text('Drinks'), onTap: () => Navigator.pushNamed(context, '/home')),
            ListTile(title: const Text('History'), onTap: () => Navigator.pushNamed(context, '/history')),
            ListTile(title: const Text('Goals'), onTap: () => Navigator.pushNamed(context, '/goals')),
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Drinks')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: drinks.length,
        itemBuilder: (context, index) {
          final drink = drinks[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VolumePage(drinkName: drink["name"] as String)),
            ),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: drink["color"] as Color,
              elevation: 5,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(drink["icon"] as IconData, color: Colors.white, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      drink["name"] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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
