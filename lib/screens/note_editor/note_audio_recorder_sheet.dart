// Noteep — Copyright © 2026 Nicola De Nicolais — All Rights Reserved.
// Licensed under the GNU GPL v3 with Additional Commercial Restrictions.
//
// Commercial use, including publishing or monetizing on any app store,
// requires explicit written permission from the copyright holder.
//
// Author: Nicola De Nicolais
// Contact: ndn21dev@gmail.com
// GitHub: https://github.com/ndenicolais

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/audio_provider.dart';

/// Bottom sheet with record/stop controls. Pops with the resulting
/// `AudioNote` once the user stops a recording, or `null` if cancelled.
class AudioRecorderSheet extends ConsumerStatefulWidget {
  const AudioRecorderSheet({super.key});

  @override
  ConsumerState<AudioRecorderSheet> createState() =>
      _AudioRecorderSheetState();
}

class _AudioRecorderSheetState extends ConsumerState<AudioRecorderSheet> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    await ref.read(recordingStateProvider.notifier).startRecording();
    if (!mounted) return;
    if (ref.read(recordingStateProvider).errorMessage != null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    await ref.read(recordingStateProvider.notifier).stopRecording();
    if (!mounted) return;
    final note = ref.read(recordingStateProvider).lastRecordedNote;
    Navigator.pop(context, note);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final recording = ref.watch(recordingStateProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (recording.errorMessage != null) ...[
              Text(
                recording.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Chiudi'),
              ),
            ] else ...[
              Icon(
                Icons.mic,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                _format(_elapsed),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _stop,
                icon: const Icon(Icons.stop),
                label: const Text('Ferma e allega'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
