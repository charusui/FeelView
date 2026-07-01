import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  /// Upload a [File] to [path] and return the download URL.
  static Future<String> uploadMedia(File file, String path) async {
    final ref = _storage.ref(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Upload raw bytes (e.g. a voice note) and return the download URL.
  /// Path: families/{familyId}/chat/{threadId}/{messageId}.aac
  static Future<String> uploadVoiceNote(
      Uint8List bytes, String threadId) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'families/default/chat/$threadId/$messageId.aac';
    final ref = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'audio/aac'));
    return ref.getDownloadURL();
  }

  /// Delete a file by its download URL.
  static Future<void> deleteFile(String url) =>
      _storage.refFromURL(url).delete();
}
