import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    final supabase = Supabase.instance.client;

    try {
      /// signUp = oppretter bruker med e-post/passord.
      /// Hvis bruker har "Confirm email" på i Supabase,
      /// vil brukeren få en bekreftelsesmail (som du kan template). :contentReference[oaicite:16]{index=16}
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _message = 'Konto opprettet! Sjekk e-post for bekreftelse.';
      });
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Ukjent feil. Prøv igjen.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-post'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passord'),
            ),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_message != null) Text(_message!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child: Text(_loading ? 'Oppretter...' : 'Opprett konto'),
            ),
          ],
        ),
      ),
    );
  }
}
