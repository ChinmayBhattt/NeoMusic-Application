import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/models/song.dart';
import '../../services/audio_player_service.dart';
import 'music_library_provider.dart';

/// Singleton audio player service provider
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Current playing song StreamProvider
final currentSongStreamProvider = StreamProvider<Song?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.currentSongStream;
});

/// Playback state stream provider
final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playerStateStream;
});

/// Current playback position stream
final playbackPositionStreamProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.positionStream;
});

/// Total duration stream
final playbackDurationStreamProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.durationStream;
});

/// Buffered playback position stream
final playbackBufferedStreamProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.bufferedPositionStream;
});

/// Shuffle state stream provider
final shuffleStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.shuffleStream;
});

/// Repeat mode stream provider
final repeatStreamProvider = StreamProvider<LoopMode>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.repeatStream;
});

/// Current queue stream provider
final queueStreamProvider = StreamProvider<List<Song>>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.queueStream;
});

/// Playback Controller Class for clean presentation actions
class PlaybackController {
  final Ref ref;
  PlaybackController(this.ref);

  AudioPlayerService get _service => ref.read(audioPlayerServiceProvider);

  Future<void> playSong(Song song, {List<Song>? queueContext}) async {
    await _service.playSong(song, queueContext: queueContext);
    // Add to recently played history
    ref.read(recentlyPlayedProvider.notifier).addSong(song);
  }

  Future<void> togglePlayPause() => _service.togglePlayPause();
  Future<void> play() => _service.play();
  Future<void> pause() => _service.pause();
  Future<void> seek(Duration position) => _service.seek(position);
  Future<void> skipToNext() => _service.skipToNext();
  Future<void> skipToPrevious() => _service.skipToPrevious();
  void toggleShuffle() => _service.toggleShuffle();
  void toggleRepeatMode() => _service.toggleRepeatMode();
  void reorderQueue(int oldIndex, int newIndex) => _service.reorderQueue(oldIndex, newIndex);
  void removeSongFromQueue(int index) => _service.removeSongFromQueue(index);
}

final playbackControllerProvider = Provider<PlaybackController>((ref) {
  return PlaybackController(ref);
});
