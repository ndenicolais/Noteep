// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/material.dart';
import '../../models/audio_note.dart';
import '../../utils/audio_service.dart';

/// Playback controls for a single attached [AudioNote].
class AudioNotePlayerTile extends StatefulWidget {
  const AudioNotePlayerTile({
    super.key,
    required this.audioNote,
    required this.onDelete,
  });

  final AudioNote audioNote;
  final VoidCallback onDelete;

  @override
  State<AudioNotePlayerTile> createState() => _AudioNotePlayerTileState();
}

class _AudioNotePlayerTileState extends State<AudioNotePlayerTile> {
  final _service = AudioRecordingService();
  bool _isPlaying = false;

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _service.pauseAudio();
    } else {
      await _service.playAudio(widget.audioNote.filepath);
    }
    if (mounted) setState(() => _isPlaying = !_isPlaying);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: IconButton(
        icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
        onPressed: _togglePlay,
      ),
      title: Text(_format(widget.audioNote.duration)),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: widget.onDelete,
      ),
    );
  }
}
