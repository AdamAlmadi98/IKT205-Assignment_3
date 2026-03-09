import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// resultat fra bildevalg (enten fil eller feil)
class ImagePickResult {
  final XFile? file;
  final String? error;

  ImagePickResult({this.file, this.error});
}

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // maks størrelse på bilde (15MB)
  static const int maxSizeBytes = 15 * 1024 * 1024;

  // tillatte filtyper
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // sjekker at filformatet er lov
  bool _isValidExtension(String path) {
    final lowerPath = path.toLowerCase();
    return allowedExtensions.any((ext) => lowerPath.endsWith('.$ext'));
  }

  // validerer bildet før det brukes
  Future<ImagePickResult> _validateImage(XFile? image) async {
    if (image == null) {
      return ImagePickResult(file: null);
    }

    if (!_isValidExtension(image.name)) {
      return ImagePickResult(
        error: 'Ugyldig filformat. Bare JPG, PNG og WebP er tillatt.',
      );
    }

    // sjekker størrelse på bildet
    final bytes = await image.length();

    if (bytes > maxSizeBytes) {
      return ImagePickResult(
        error: 'Bildet er for stort. Maks størrelse er 15 MB.',
      );
    }

    return ImagePickResult(file: image);
  }

  // ta bilde med kamera
  Future<ImagePickResult> pickFromCamera() async {
    if (!kIsWeb) {
      final status = await Permission.camera.request();

      if (!status.isGranted) {
        return ImagePickResult(error: 'Kameratilgang ble ikke gitt.');
      }
    }

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      return await _validateImage(image);
    } catch (e) {
      return ImagePickResult(error: 'Kunne ikke åpne kamera: $e');
    }
  }

  // velg bilde fra galleri
  Future<ImagePickResult> pickFromGallery() async {
    if (!kIsWeb) {
      final status = await Permission.photos.request();

      if (!status.isGranted && !status.isLimited) {
        return ImagePickResult(error: 'Tilgang til bildegalleri ble ikke gitt.');
      }
    }

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      return await _validateImage(image);
    } catch (e) {
      return ImagePickResult(error: 'Kunne ikke åpne bildegalleri: $e');
    }
  }
}