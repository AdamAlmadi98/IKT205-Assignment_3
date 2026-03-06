import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../pages/detail_page.dart';
import '../notes_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/image_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;




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
  bool saving = false;

  File? selectedImage;
  

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }

    Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();

  if (status.isGranted) {
    return true;
  }

  if (status.isPermanentlyDenied) {
    await openAppSettings();
  }

  if (!mounted) return false;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Kameratilgang ble ikke gitt')),
  );

  return false;
}

Future<bool> requestGalleryPermission() async {
  PermissionStatus status;

  status = await Permission.photos.request();

  if (status.isGranted || status.isLimited) {
    return true;
  }

  status = await Permission.storage.request();

  if (status.isGranted) {
    return true;
  }

  if (status.isPermanentlyDenied) {
    await openAppSettings();
  }

  if (!mounted) return false;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Tilgang til bilder ble ikke gitt')),
  );

  return false;
}

Future<void> takePhoto() async {
  final image = await imageService.pickFromCamera();

  if (image == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kameratilgang ble ikke gitt.'),
      ),
    );
    return;
  }

  setState(() {
    selectedImage = image;
  });
}

  Future<void> pickFromGallery() async {
  final image = await imageService.pickFromGallery();

  if (image == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tilgang til galleri ble ikke gitt eller bildet ble avbrutt'),
      ),
    );
    return;
  }

  setState(() {
    selectedImage = image;
  });
}

  Future<void> save() async {
  if (saving) return;

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
    String? imageUrl;

    if (selectedImage != null) {
      final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(selectedImage!.path)}';

      await Supabase.instance.client.storage
          .from('notes_storage')
          .upload(fileName, selectedImage!);

      imageUrl = Supabase.instance.client.storage
          .from('notes_storage')
          .getPublicUrl(fileName);
    }

    await widget.repo.addNote(
      title,
      content,
      imageUrl: imageUrl,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notat lagret!')),
    );
    Navigator.pop(context);
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
                    onPressed: takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ta bilde'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text('Galleri'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            if (selectedImage != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            selectedImage!.path,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.contain,
                        )
                    : Image.file(
                            selectedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.contain,
            ),
            ),
            if (selectedImage != null) const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : save,
                child: Text(saving ? 'Lagrer…' : 'Lagre'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}