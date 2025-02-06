import 'package:flutter/material.dart';
import '../supabase_config.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = "";
  bool isLoading = false;

  Future<void> signUp() async {
    setState(() => isLoading = true);
    try {
      final response = await SupabaseConfig.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        print("✅ User registered: ${response.user!.id}");
        setState(() => errorMessage = "✅ Account created! Check your email.");
      } else {
        setState(() => errorMessage = "❌ Registration failed.");
      }
    } catch (e) {
      setState(() => errorMessage = "❌ Error: ${e.toString()}");
    }
    setState(() => isLoading = false);
  }

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        print("✅ Login successful: ${response.user!.id}");
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        setState(() => errorMessage = "❌ Login failed.");
      }
    } catch (e) {
      setState(() => errorMessage = "❌ Error: ${e.toString()}");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login / Register")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: login,
                        child: const Text("Login"),
                      ),
                      ElevatedButton(
                        onPressed: signUp,
                        child: const Text("Register"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
