
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StatusRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static const String bucket = 'fof-statuses';
  static const int maxFileSize = 20 * 1024 * 1024;

  String _contentType(String extension, bool isVideo) {
    if (isVideo) return 'video/mp4';

    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        throw Exception('Format de photo non pris en charge.');
    }
  }

  Future<String> publishStatus({
    required String mediaPath,
    required bool isVideo,
    String? caption,
    Map<String, dynamic> editorData = const {},
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Connecte-toi avant de publier un statut.');
    }

    final file = File(mediaPath);

    if (!await file.exists()) {
      throw Exception('Le fichier sélectionné est introuvable.');
    }

    final fileSize = await file.length();

    if (fileSize > maxFileSize) {
      throw Exception('Le fichier dépasse la limite de 20 Mo.');
    }

    final extension = mediaPath.split('.').last.toLowerCase();
    final contentType = _contentType(extension, isVideo);

    String? statusId;
    String? storagePath;

    try {
      final inserted = await _client
          .from('statuses')
          .insert({
            'user_id': user.id,
            'media_url': null,
            'caption': caption,
            'editor_data': editorData,
          })
          .select('id')
          .single();

      statusId = inserted['id'] as String;
      storagePath = '$statusId/media.$extension';

      await _client.storage.from(bucket).upload(
        storagePath,
        file,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: false,
        ),
      );

      await _client.from('statuses').update({
        'media_url': storagePath,
      }).eq('id', statusId).eq('user_id', user.id);

      return statusId;
    } catch (error) {
      if (storagePath != null) {
        try {
          await _client.storage.from(bucket).remove([storagePath]);
        } catch (_) {}
      }

      if (statusId != null) {
        try {
          await _client.from('statuses').delete().eq('id', statusId);
        } catch (_) {}
      }

      rethrow;
    }
  }
}
