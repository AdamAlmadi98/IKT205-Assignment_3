import 'package:flutter/material.dart';
import '../notes_repo.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic> note;
  final NotesRepo repo;

  const EditPage({super.key, required this.note, required this.repo});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    titleCtrl.text = (widget.note['title'] ?? '').toString();
    contentCtrl.text = (widget.note['content'] ?? '').toString();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (saving) return;

    final id = widget.note['id']?.toString();
    if (id == null) return;

    final title = titleCtrl.text.trim();
    final content = contentCtrl.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tittel og innhold kan ikke være tomme')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await widget.repo.updateNote(id, title, content);

      if (!mounted) return;

      Navigator.pop(context, {
        'id': id,
        'title': title,
        'content': content,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunne ikke lagre: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rediger notat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Tittel'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: contentCtrl,
                decoration: const InputDecoration(labelText: 'Innhold'),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : save,
                child: Text(saving ? 'Lagrer…' : 'Lagre endringer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}