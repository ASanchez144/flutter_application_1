import 'package:flutter/material.dart';
import 'volume_page.dart';
import 'drinks_data.dart';  // Import the external drink data

class HomePage extends StatelessWidget {
  const HomePage({super.key});  // We can safely keep const here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),  // Custom Drawer Widget (cleaner)
      appBar: AppBar(title: const Text('Drinks')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: DrinkData.drinks.length,
        itemBuilder: (context, index) {
          final drink = DrinkData.drinks[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VolumePage(drinkName: drink["name"] as String)),
              );
            },
            child: DrinkCard(
              name: drink["name"] as String,
              iconPath: drink["iconPath"] as String,
              color: drink["color"] as Color,
            ),
          );
        },
      ),
    );
  }
}

// Custom Drawer for Navigation (keeps UI clean)
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(title: const Text('Drinks'), onTap: () => Navigator.pushNamed(context, '/home')),
          ListTile(title: const Text('History'), onTap: () => Navigator.pushNamed(context, '/history')),
        ],
      ),
    );
  }
}

// Custom Widget to handle image icons and text
class DrinkCard extends StatelessWidget {
  final String name;
  final String iconPath;
  final Color color;

  const DrinkCard({
    super.key,
    required this.name,
    required this.iconPath,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color,
      elevation: 5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, width: 50, height: 50, color: Colors.white),  // Use custom icon
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
