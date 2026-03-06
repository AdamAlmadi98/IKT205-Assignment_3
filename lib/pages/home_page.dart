import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    
    await Supabase.instance.client.auth.signOut();

    
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FastNotes'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logg ut',
          ),
        ],
      ),
      body: Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Innlogget som: ${user?.email ?? "ukjent"}',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 40),

      ElevatedButton(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(fontSize: 18),
  ),
  onPressed: () {
    Navigator.pushNamed(context, '/jobb');
  },
  child: const Text('Jobb Notater'),
),

      const SizedBox(height: 16),

      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        child: const Text('Lag ny notat'),
      ),
    ],
  ),
),
    );
  }
}
