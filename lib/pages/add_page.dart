// Denne filen håndterer siden for å lage et nytt notat.
// Brukeren kan skrive tittel og innhold, ta bilde med kamera
// eller velge bilde fra galleri. Bildet vises som forhåndsvisning
// og kan fjernes før lagring. Når notatet lagres blir bildet
// lastet opp til Supabase Storage med unikt navn, og filstien
// lagres sammen med notatet i databasen. Etter lagring sendes
// også en lokal notifikasjon til brukeren.


import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../notes_repo.dart';
import '../services/image_service.dart';
import '../services/notification_service.dart';

class AddPage extends StatefulWidget {
  final NotesRepo repo;

  const AddPage({super.key, required this.repo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final ImageService imageService = ImageService();
  final NotificationService notificationService = NotificationService();
  
  bool saving = false;

  // holder på valgt bilde
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  String? selectedImageName;

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }

  // tar bilde med kamera
  Future<void> takePhoto() async {
  final ImagePickResult result = await imageService.pickFromCamera();

  // hvis ingen fil ble valgt eller noe feilet
  if (result.file == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.error ?? 'Kameratilgang ble ikke gitt eller bildet ble avbrutt.',
        ),
      ),
    );
    return;
  }

  final image = result.file!;
  final bytes = await image.readAsBytes();

  // lagrer valgt bilde lokalt i appen
  setState(() {
    selectedImage = image;
    selectedImageBytes = bytes;
    selectedImageName = p.basename(image.path);
  });
}

  // velger bilde fra galleri
Future<void> pickFromGallery() async {
  final ImagePickResult result = await imageService.pickFromGallery();

  // hvis bruker avbryter eller noe går galt
  if (result.file == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.error ?? 'Valg av bilde ble avbrutt.',
        ),
      ),
    );
    return;
  }

  final image = result.file!;
  final bytes = await image.readAsBytes();

  // lagrer valgt bilde lokalt i appen
  setState(() {
    selectedImage = image;
    selectedImageBytes = bytes;
    selectedImageName = p.basename(image.path);
  });
}

  // fjerner bildet som er valgt
  void removeSelectedImage() {
    setState(() {
      selectedImage = null;
      selectedImageBytes = null;
      selectedImageName = null;
    });
  }

  Future<void> save() async {
  // stopper dobbeltklikk mens lagring pågår
  if (saving) return;

  final title = titleCtrl.text.trim();
  final content = contentCtrl.text.trim();

  // enkel validering av feltene
  if (title.isEmpty || content.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tittel og innhold kan ikke være tomme'),
      ),
    );
    return;
  }

  setState(() => saving = true);

  try {
    String? imagePath;

    // laster opp bilde bare hvis bruker har valgt et
    if (selectedImageBytes != null && selectedImageName != null) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Bruker er ikke logget inn.');
      }

      // sjekker filformat
      final extension = p.extension(selectedImageName!).toLowerCase();
      const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

      if (!allowedExtensions.contains(extension)) {
        throw Exception('Ugyldig filformat. Kun JPG, PNG og WebP er tillatt.');
      }

      debugPrint('Filnavn: $selectedImageName');
      debugPrint('Antall bytes: ${selectedImageBytes!.length}');
      debugPrint('MB i appen: ${selectedImageBytes!.length / (1024 * 1024)}');

      // sjekker filstørrelse (maks 6 MB)
      const maxSize = 6 * 1024 * 1024;
      if (selectedImageBytes!.length > maxSize) {
        throw Exception('Bildet er for stort. Maks størrelse er 15 MB.');
      }

      final cleanName = selectedImageName!
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');

      final baseName = p.basenameWithoutExtension(cleanName);

      // lager unikt filnavn så bilder ikke overskriver hverandre
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${baseName.isEmpty ? 'image' : baseName}$extension';

      // legger bildet i mappe med bruker id
      final filePath = '${user.id}/$fileName';

      await Supabase.instance.client.storage
          .from('notes_storage')
          .uploadBinary(
            filePath,
            selectedImageBytes!,
            fileOptions: FileOptions(
              upsert: false,
              contentType: selectedImage?.mimeType ?? 'image/png',
            ),
          );

      // lagrer filsti som skal kobles til notatet
      imagePath = filePath;
    }

    // lagrer selve notatet i databasen
    await widget.repo.addNote(
      title,
      content,
      imageUrl: imagePath,
    );

    // lokal notifikasjon etter vellykket lagring
    await notificationService.showNotification(
      title: 'Nytt notat: $title',
      body: 'Notatet ble lagret.',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notat lagret!')),
    );
    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kunne ikke lagre: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => saving = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nytt notat')),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ta bilde'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: saving ? null : pickFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text('Galleri'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedImageBytes != null) ...[
              // forhåndsvisning av valgt bilde
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  selectedImageBytes!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: saving ? null : removeSelectedImage,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Fjern valgt bilde'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // deaktiverer knappen mens notatet lagres
                onPressed: saving ? null : save,
                child: saving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Lagrer...'),
                        ],
                      )
                    : const Text('Lagre'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}