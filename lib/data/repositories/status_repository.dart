
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatusRepository {
  StatusRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String bucketName = 'fof-statuses';

  String? get currentUserId => _client.auth.currentUser?.id;

  String get _userId {
    final id = currentUserId;
    if (id == null) {
      throw StateError('Connecte-toi pour publier un statut.');
    }
    return id;
  }

  Future<void> publishImage(
    XFile image, {
    String? caption,
  }) async {
    final userId = _userId;

    final extension = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : 'jpg';

    const allowed = {'jpg', 'jpeg', 'png', 'webp'};
    if (!allowed.contains(extension)) {
      throw ArgumentError('Format accepté : JPG, PNG ou WEBP.');
    }

    final inserted = await _client.from('statuses').insert({
      'user_id': userId,
      'caption': (caption ?? '').trim().isEmpty
          ? null
          : caption!.trim(),
      'media_url': null,
    }).select('id').single();

    final statusId = inserted['id'].toString();
    final path = '$statusId/status.$extension';

    try {
      final bytes = await image.readAsBytes();
      final contentType = extension == 'jpg'
          ? 'image/jpeg'
          : 'image/$extension';

      await _client.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: false,
        ),
      );

      await _client.from('statuses').update({
        'media_url': path,
      }).eq('id', statusId);
    } catch (_) {
      await _client.from('statuses').delete().eq('id', statusId);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getActiveStatuses() async {
    final rows = await _client
        .from('statuses')
        .select(
          'id, user_id, media_url, caption, created_at, expires_at',
        )
        .gt(
          'expires_at',
          DateTime.now().toUtc().toIso8601String(),
        )
        .not('media_url', 'is', null)
        .order('created_at', ascending: false);

    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<String> createMediaUrl(String path) {
    return _client.storage.from(bucketName).createSignedUrl(
      path,
      3600,
    );
  }

  Future<void> registerView(String statusId) async {
    await _client.from('status_views').upsert(
      {
        'status_id': statusId,
        'user_id': _userId,
      },
      onConflict: 'status_id,user_id',
      ignoreDuplicates: true,
    );
  }

  Future<Map<String, dynamic>> getStats(String statusId) async {
    final result = await _client.rpc(
      'get_status_stats',
      params: {'p_status_id': statusId},
    );

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    if (result is List &&
        result.isNotEmpty &&
        result.first is Map) {
      return Map<String, dynamic>.from(result.first as Map);
    }

    return {};
  }
}
