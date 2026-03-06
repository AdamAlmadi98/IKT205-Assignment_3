import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'notes_repo.dart';
import 'auth/auth_gate.dart';
import 'pages/jobb_notater_page.dart';
import 'pages/add_page.dart';
import 'widgets/bakgrunn_ny.dart';
import '../pages/add_page.dart';
import '../pages/detail_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  runApp(const FastNotesApp());
}

class FastNotesApp extends StatelessWidget {
  const FastNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FastNotes',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      builder: (context, child) {
        return Bakgrunn(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
      routes: {
        '/jobb': (_) => const JobbNotaterPage(),
        '/add': (_) => AddPage(repo: NotesRepo()),
      },
    );
  }
}