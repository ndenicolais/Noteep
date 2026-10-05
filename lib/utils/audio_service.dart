// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/audio_note.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance =
      AudioRecordingService._internal();

  factory AudioRecordingService() {
    return _instance;
  }

  AudioRecordingService._internal();

  final _recorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();

  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  /// Start recording audio. Throws if recording could not actually start
  /// (permission denied, unsupported platform, ...) so the caller's state
  /// doesn't end up claiming a recording is in progress when it isn't.
  Future<void> startRecording() async {
    if (kIsWeb) {
      throw UnsupportedError('Audio recording is not supported on web.');
    }
    if (!await _recorder.hasPermission()) {
      throw StateError('Microphone permission was denied.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio_notes');
    if (!audioDir.existsSync()) {
      audioDir.createSync(recursive: true);
    }

    final timestamp = DateFormat(
      'yyyy-MM-dd_HH-mm-ss-SSS',
    ).format(DateTime.now());
    _currentRecordingPath = '${audioDir.path}/audio_$timestamp.m4a';

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentRecordingPath!,
    );

    _isRecording = true;
  }

  /// Stop recording and return AudioNote
  Future<AudioNote?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final result = await _recorder.stop();
      _isRecording = false;

      if (result != null && _currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (file.existsSync()) {
          final duration = await _getDuration(_currentRecordingPath!);

          final audioNote = AudioNote(
            filename:
                'audio_${DateFormat('HH:mm:ss').format(DateTime.now())}.m4a',
            filepath: _currentRecordingPath!,
            duration: duration,
          );

          _currentRecordingPath = null;
          return audioNote;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Stop recording error: $e');
      _isRecording = false;
    }
    return null;
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (file.existsSync()) {
            await file.delete();
          }
        }
        _isRecording = false;
        _currentRecordingPath = null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Cancel recording error: $e');
    }
  }

  /// Play audio file
  Future<void> playAudio(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Play audio error: $e');
      _isPlaying = false;
    }
  }

  /// Pause audio
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) debugPrint('Pause audio error: $e');
    }
  }

  /// Resume audio
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Resume audio error: $e');
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) debugPrint('Stop audio error: $e');
    }
  }

  /// Get current position
  Duration? getCurrentPosition() {
    return _audioPlayer.position;
  }

  /// Get total duration
  Duration? getDuration() {
    return _audioPlayer.duration;
  }

  /// Listen to playback state changes
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// Listen to position changes
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  /// Seek to position
  Future<void> seek(Duration duration) async {
    try {
      await _audioPlayer.seek(duration);
    } catch (e) {
      if (kDebugMode) debugPrint('Seek error: $e');
    }
  }

  /// Get duration of a file
  Future<Duration> _getDuration(String filePath) async {
    try {
      final player = AudioPlayer();
      await player.setFilePath(filePath);
      final duration = player.duration ?? Duration.zero;
      await player.dispose();
      return duration;
    } catch (e) {
      if (kDebugMode) debugPrint('Get duration error: $e');
      return Duration.zero;
    }
  }

  /// Delete audio file
  Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Delete audio file error: $e');
      return false;
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await cancelRecording();
      }
      if (_isPlaying) {
        await stopAudio();
      }
      await _recorder.dispose();
      await _audioPlayer.dispose();
    } catch (e) {
      if (kDebugMode) debugPrint('Dispose error: $e');
    }
  }
}
