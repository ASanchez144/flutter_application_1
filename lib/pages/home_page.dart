import 'package:flutter/material.dart';
import 'volume_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../supabase_config.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    await SupabaseConfig.client.auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drink Tracker", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, "/history");
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        children: [
          DrinkButton(drinkName: "Water", color: Colors.blue),
          DrinkButton(drinkName: "Juice", color: Colors.orange),
          DrinkButton(drinkName: "Soda", color: Colors.red),
          DrinkButton(drinkName: "Coffee", color: Colors.brown),
        ],
      ),
    );
  }
}

class DrinkButton extends StatelessWidget {
  final String drinkName;
  final Color color;

  const DrinkButton({super.key, required this.drinkName, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VolumePage(drinkName: drinkName)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: color,
        elevation: 5,
        child: Center(
          child: Text(
            drinkName,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
