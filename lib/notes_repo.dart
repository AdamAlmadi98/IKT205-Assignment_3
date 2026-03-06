import 'package:supabase_flutter/supabase_flutter.dart';

class NotesRepo {
  final SupabaseClient db = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final data = await db
        .from('notes')
        .select('id, title, content, image_url, created_at')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addNote(String title, String content, {String? imageUrl}) async {
    final t = title.trim();
    final c = content.trim();

    if (t.isEmpty || c.isEmpty) {
      throw Exception('Tittel og innhold kan ikke være tomme.');
    }

    final userId = db.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Bruker ikke logget inn.');
    }

    await db.from('notes').insert({
      'title': t,
      'content': c,
      'user_id': userId,
      'image_url': imageUrl,
    });
  }

  Future<void> updateNote(String id, String title, String content) async {
    final t = title.trim();
    final c = content.trim();

    if (t.isEmpty || c.isEmpty) {
      throw Exception('Tittel og innhold kan ikke være tomme.');
    }

    await db.from('notes').update({
      'title': t,
      'content': c,
    }).eq('id', id);
  }

  Future<void> deleteNote(String id) async {
    await db.from('notes').delete().eq('id', id);
  }
}