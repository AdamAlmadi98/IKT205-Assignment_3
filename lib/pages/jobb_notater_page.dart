import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../notes_repo.dart';
import '../main.dart'; 
import '../widgets/bakgrunn_ny.dart';
import '../pages/add_page.dart';
import '../pages/detail_page.dart';

class JobbNotaterPage extends StatefulWidget {
  const JobbNotaterPage({super.key});

  @override
  State<JobbNotaterPage> createState() => _JobbNotaterPageState();
}

class _JobbNotaterPageState extends State<JobbNotaterPage> {
  final NotesRepo repo = NotesRepo();
  late Future<List<Map<String, dynamic>>> futureNotes;

  @override
  void initState() {
    super.initState();
    futureNotes = repo.fetchNotes();
  }

  void refreshNotes() {
    setState(() {
      futureNotes = repo.fetchNotes();
    });
  }

  Future<void> goAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPage(repo: repo)),
    );
    refreshNotes();
  }

  Future<void> goDetail(Map<String, dynamic> note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(note: note, repo: repo),
      ),
    );
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Bakgrunn(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('JobbNotater'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureNotes,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Feil: ${snap.error}'));
            }

            final list = snap.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('Ingen notater enda'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final n = list[i];
                return Card(
                  child: ListTile(
                    title: Text(
                      '${n['title'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => goDetail(n),
                  ),
                );
              },
            );
          },
        ),
        
        floatingActionButton: FloatingActionButton(
          onPressed: goAdd,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}