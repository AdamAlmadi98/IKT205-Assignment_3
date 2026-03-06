import 'package:flutter/material.dart';
import '../pages/add_page.dart';
import '../notes_repo.dart';
import '../pages/edit_page.dart';





class DetailPage extends StatefulWidget {
  final Map<String, dynamic> note;
  final NotesRepo repo;

  const DetailPage({
    super.key,
    required this.note,
    required this.repo,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Map<String, dynamic> note;

  @override
  void initState() {
    super.initState();
    note = Map<String, dynamic>.from(widget.note);
  }

  Future<void> goEdit() async {
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPage(note: note, repo: widget.repo),
      ),
    );

    if (result != null) {
      setState(() => note = result);
    }
  }

  Future<void> deleteNote() async {
    final id = note['id']?.toString();
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Slette notat?'),
        content: const Text('Er du sikker? Dette kan ikke angres.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Slett',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await widget.repo.deleteNote(id);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
  final title = (note['title'] ?? '').toString();
  final content = (note['content'] ?? '').toString();
  final imageUrl = (note['image_url'] ?? '').toString();

  return Scaffold(
    appBar: AppBar(
      title: const Text('Detaljer'),
      actions: [
        IconButton(
          onPressed: goEdit,
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: deleteNote,
          icon: const Icon(Icons.delete),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isEmpty ? 'Uten tittel' : title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(content.isEmpty ? '— (tomt notat) —' : content),
          const SizedBox(height: 16),

          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    ),
  );
}
}