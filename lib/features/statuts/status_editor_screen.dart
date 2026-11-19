
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class StatusEditorScreen extends StatefulWidget {
  const StatusEditorScreen({super.key});

  @override
  State<StatusEditorScreen> createState() =>
      _StatusEditorScreenState();
}

class _StatusEditorScreenState extends State<StatusEditorScreen> {
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  XFile? _media;
  String? _audioName;
  String? _audioPath;

  VideoPlayerController? _videoController;

  final List<String> _stickers = [];
  final List<Map<String, dynamic>> _texts = [];

  bool _isVideo = false;
  bool _musicPlaying = false;
  bool _loading = false;

  Color _textColor = Colors.white;

  Future<void> _pickMedia(bool video) async {
    final XFile? file = video
        ? await _picker.pickVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(seconds: 60),
          )
        : await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 90,
          );

    if (file == null) return;

    await _videoController?.dispose();
    _videoController = null;

    if (video) {
      final controller =
          VideoPlayerController.file(File(file.path));

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _media = file;
        _isVideo = true;
        _videoController = controller;
      });
    } else {
      setState(() {
        _media = file;
        _isVideo = false;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final path = result.files.single.path!;

    try {
      await _audioPlayer.setFilePath(path);

      if (!mounted) return;

      setState(() {
        _audioPath = path;
        _audioName = result.files.single.name;
        _musicPlaying = false;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Impossible de lire ce fichier audio.');
    }
  }

  Future<void> _toggleMusic() async {
    if (_audioPath == null) {
      _showMessage('Choisis d’abord une musique.');
      return;
    }

    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }

      if (!mounted) return;

      setState(() {
        _musicPlaying = _audioPlayer.playing;
      });
    } catch (_) {
      _showMessage('Erreur pendant la lecture audio.');
    }
  }

  Future<void> _addText() async {
    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un texte'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 150,
          decoration: const InputDecoration(
            hintText: 'Écris ton texte...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (value == null || value.isEmpty || !mounted) return;

    setState(() {
      _texts.add({
        'text': value,
        'color': _textColor.value,
      });
    });
  }

  void _addSticker(String sticker) {
    setState(() {
      _stickers.add(sticker);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildPreview() {
    if (_media == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 60, color: Colors.white70),
            SizedBox(height: 12),
            Text(
              'Choisis une photo ou une vidéo',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: _isVideo && _videoController != null
              ? FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              : Image.file(
                  File(_media!.path),
                  fit: BoxFit.contain,
                ),
        ),

        ..._texts.map(
          (item) => Positioned(
            top: 35,
            left: 15,
            right: 15,
            child: Text(
              item['text'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(item['color'] as int),
                fontSize: 25,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 25,
          child: Text(
            _stickers.join(' '),
            style: const TextStyle(fontSize: 35),
          ),
        ),

        if (_isVideo && _videoController != null)
          IconButton.filled(
            onPressed: () {
              setState(() {
                if (_videoController!.value.isPlaying) {
                  _videoController!.pause();
                } else {
                  _videoController!.play();
                }
              });
            },
            icon: Icon(
              _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
      ],
    );
  }

  Widget _toolButton(
    IconData icon,
    String label,
    VoidCallback action,
  ) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 25),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101018),
        foregroundColor: Colors.white,
        title: const Text('VOIR+ Studio'),
        actions: [
          TextButton(
            onPressed: () {
              _showMessage(
                'La publication sera connectée à Supabase à l’étape suivante.',
              );
            },
            child: const Text('Suivant'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildPreview(),
            ),
          ),

          if (_media == null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _pickMedia(false),
                      icon: const Icon(Icons.photo),
                      label: const Text('Photo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _pickMedia(true),
                      icon: const Icon(Icons.videocam),
                      label: const Text('Vidéo'),
                    ),
                  ),
                ],
              ),
            ),

          if (_media != null)
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _toolButton(
                  Icons.photo,
                  'Média',
                  () => _pickMedia(false),
                ),
                _toolButton(
                  Icons.videocam,
                  'Vidéo',
                  () => _pickMedia(true),
                ),
                _toolButton(
                  Icons.text_fields,
                  'Texte',
                  _addText,
                ),
                _toolButton(
                  Icons.emoji_emotions,
                  'Stickers',
                  () => _addSticker('🔥'),
                ),
                _toolButton(
                  Icons.music_note,
                  'Musique',
                  _pickAudio,
                ),
                _toolButton(
                  Icons.auto_awesome,
                  'Effets',
                  () => _showMessage(
                    'Les filtres avancés arrivent dans le prochain module.',
                  ),
                ),
              ],
            ),

          if (_audioName != null)
            ListTile(
              dense: true,
              leading: const Icon(
                Icons.music_note,
                color: Colors.white,
              ),
              title: Text(
                _audioName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              trailing: IconButton(
                onPressed: _toggleMusic,
                icon: Icon(
                  _musicPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
 