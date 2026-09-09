import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client;
  final Future<Directory> Function()? docsDirProvider;

  static const String matchImagesBucket = 'match-images';

  StorageService(this._client, {this.docsDirProvider});

  Future<Directory> _getDocsDir() async {
    final provider = docsDirProvider;
    if (provider != null) {
      return await provider();
    }
    return await getApplicationDocumentsDirectory();
  }

  /// Uploads a local match photo to Supabase Storage and returns its public URL.
  /// If the upload fails, returns null without throwing to avoid breaking the sync flow.
  Future<String?> uploadMatchPhoto({
    required String userId,
    required File file,
    required String fileName,
  }) async {
    if (!file.existsSync()) return null;

    try {
      final storagePath = '$userId/$fileName';
      await _client.storage.from(matchImagesBucket).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from(matchImagesBucket).getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Storage upload error for $fileName: $e');
      return null;
    }
  }

  /// Downloads a remote image URL to the local app documents directory.
  /// Returns the absolute local file path, or null if the download fails.
  Future<String?> downloadPhotoToLocalCache({
    required String imageUrl,
    required String localFileName,
  }) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) return null;

    try {
      final dir = await _getDocsDir();
      final localFile = File('${dir.path}/$localFileName');

      // If already cached locally and not empty, return existing path
      if (localFile.existsSync() && localFile.lengthSync() > 0) {
        return localFile.path;
      }

      final uri = Uri.parse(imageUrl);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        await localFile.writeAsBytes(bytes);
        return localFile.path;
      } else {
        debugPrint('Storage download failed with HTTP ${response.statusCode} for $imageUrl');
        return null;
      }
    } catch (e) {
      debugPrint('Storage download error for $imageUrl: $e');
      return null;
    }
  }
}
