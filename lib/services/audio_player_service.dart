import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song_model.dart';

class AudioPlayerService {
  AudioPlayerService._();

  static final AudioPlayerService instance =
      AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();

  // ============================================================
  // PLAYER
  // ============================================================

  AudioPlayer get player => _player;

  // ============================================================
  // STREAMS
  // ============================================================

  Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream;

  Stream<Duration?> get durationStream =>
      _player.durationStream;

  Stream<Duration> get positionStream =>
      _player.positionStream;

  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  // ============================================================
  // PLAYER DATA
  // ============================================================

  bool get isPlaying => _player.playing;

  Duration get position => _player.position;

  Duration? get duration => _player.duration;

  // ============================================================
  // PLAY SONG
  // ============================================================

  Future<void> playSong(SongModel song) async {
    try {
      if (song.audioPath.isEmpty) {
        debugPrint(
          'Audio path is empty for: ${song.title}',
        );
        return;
      }

      final AudioSource source =
          AudioSource.asset(song.audioPath);

      await _player.setAudioSource(source);

      await _player.play();
    } catch (e, stackTrace) {
      debugPrint(
        'Audio play error: $e',
      );

      debugPrint(
        'Audio stack trace: $stackTrace',
      );
    }
  }

  // ============================================================
  // PLAY
  // ============================================================

  Future<void> play() async {
    await _player.play();
  }

  // ============================================================
  // PAUSE
  // ============================================================

  Future<void> pause() async {
    await _player.pause();
  }

  // ============================================================
  // STOP
  // ============================================================

  Future<void> stop() async {
    await _player.stop();
  }

  // ============================================================
  // SEEK
  // ============================================================

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // ============================================================
  // NEXT
  // ============================================================

  Future<void> next() async {
    // Next song PlayerController se handle hoga.
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  Future<void> previous() async {
    // Previous song PlayerController se handle hoga.
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await _player.dispose();
  }
}