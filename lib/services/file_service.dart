import 'dart:io';

class FileService {
  // Placeholder service for document upload workflow.
  Future<String> validateLocalFile(File file) async {
    final length = await file.length();
    if (length > 10 * 1024 * 1024) {
      throw Exception('Fichier trop volumineux (max 10MB)');
    }
    return file.path;
  }
}
