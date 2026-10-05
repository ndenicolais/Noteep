// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audio_note.dart';
import '../utils/audio_service.dart';

// Audio service singleton provider
final audioServiceProvider = Provider((ref) {
  return AudioRecordingService();
});

// Recording state
class RecordingState {
  final bool isRecording;
  final Duration? currentDuration;
  final String? errorMessage;
  final AudioNote? lastRecordedNote;

  const RecordingState({
    this.isRecording = false,
    this.currentDuration,
    this.errorMessage,
    this.lastRecordedNote,
  });

  RecordingState copyWith({
    bool? isRecording,
    Duration? currentDuration,
    String? errorMessage,
    bool clearErrorMessage = false,
    AudioNote? lastRecordedNote,
    bool clearLastRecordedNote = false,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      currentDuration: currentDuration ?? this.currentDuration,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastRecordedNote:
          clearLastRecordedNote
              ? null
              : (lastRecordedNote ?? this.lastRecordedNote),
    );
  }
}

class RecordingStateNotifier extends StateNotifier<RecordingState> {
  RecordingStateNotifier(this._audioService) : super(const RecordingState());

  final AudioRecordingService _audioService;

  Future<void> startRecording() async {
    try {
      await _audioService.startRecording();
      state = state.copyWith(
        isRecording: true,
        clearErrorMessage: true,
        clearLastRecordedNote: true,
      );
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: 'Failed to start recording: $e',
      );
    }
  }

  /// Stops the underlying recorder and stores the resulting [AudioNote] (if
  /// any) on `state.lastRecordedNote` for the caller to pick up.
  Future<void> stopRecording() async {
    try {
      final note = await _audioService.stopRecording();
      state = state.copyWith(isRecording: false, lastRecordedNote: note);
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: 'Failed to stop recording: $e',
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioService.cancelRecording();
      state = const RecordingState();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to cancel recording: $e');
    }
  }
}

final recordingStateProvider =
    StateNotifierProvider<RecordingStateNotifier, RecordingState>((ref) {
      final audioService = ref.watch(audioServiceProvider);
      return RecordingStateNotifier(audioService);
    });
