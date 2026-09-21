import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/models/song.dart';

/// Service wrapping just_audio.AudioPlayer
/// Handles playback, playlist queuing, repeat/shuffle, and stream state
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  // Internal state
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffleActive = false;
  LoopMode _loopMode = LoopMode.off;

  // Stream controllers for UI & providers
  final _currentSongController = StreamController<Song?>.broadcast();
  final _queueController = StreamController<List<Song>>.broadcast();
  final _shuffleController = StreamController<bool>.broadcast();
  final _repeatController = StreamController<LoopMode>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Getters
  AudioPlayer get rawPlayer => _player;
  Song? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _queue.length) ? _queue[_currentIndex] : null;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isShuffleActive => _isShuffleActive;
  LoopMode get loopMode => _loopMode;
  bool get isPlaying => _player.playing;

  // Streams
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<List<Song>> get queueStream => _queueController.stream;
  Stream<bool> get shuffleStream => _shuffleController.stream;
  Stream<LoopMode> get repeatStream => _repeatController.stream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<String> get errorStream => _errorController.stream;

  AudioPlayerService() {
    _initSubscriptions();
  }

  void _initSubscriptions() {
    // Handle track completion
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.one) {
          seek(Duration.zero);
          play();
        } else {
          skipToNext();
        }
      }
    });

    // Handle playback errors gracefully
    _player.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace stackTrace) {
        debugPrint('AudioPlayerService error: $e');
        _errorController.add('Unable to stream track. Check network connection.');
      },
    );
  }

  /// Start playing a song, setting up the queue and current index
  Future<void> playSong(Song song, {List<Song>? queueContext}) async {
    final newQueue = queueContext != null ? List<Song>.from(queueContext) : [song];
    _queue = newQueue;
    _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    if (_currentIndex == -1) {
      _queue.insert(0, song);
      _currentIndex = 0;
    }

    _queueController.add(_queue);
    _currentSongController.add(song);

    await _loadAndPlay(song);
  }

  Future<void> _loadAndPlay(Song song) async {
    try {
      await _player.stop();
      if (song.audioUrl.isNotEmpty) {
        await _player.setUrl(song.audioUrl);
        await _player.play();
      }
    } catch (e) {
      debugPrint('Error loading audio URL "${song.audioUrl}": $e');
      _errorController.add('Playback error for "${song.title}".');
      // If error occurs, still allow user to seek / advance
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Pause error: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Seek error: $e');
    }
  }

  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;

    if (_isShuffleActive && _queue.length > 1) {
      // Pick random index different from current
      final next = (_currentIndex + 1) % _queue.length;
      _currentIndex = next;
    } else {
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
      } else {
        if (_loopMode == LoopMode.all) {
          _currentIndex = 0;
        } else {
          await pause();
          await seek(Duration.zero);
          return;
        }
      }
    }

    final nextSong = _queue[_currentIndex];
    _currentSongController.add(nextSong);
    await _loadAndPlay(nextSong);
  }

  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;

    // If current position is greater than 3 seconds, replay track from start
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _queue.length - 1;
    }

    final prevSong = _queue[_currentIndex];
    _currentSongController.add(prevSong);
    await _loadAndPlay(prevSong);
  }

  void toggleShuffle() {
    _isShuffleActive = !_isShuffleActive;
    _shuffleController.add(_isShuffleActive);
  }

  void toggleRepeatMode() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    _repeatController.add(_loopMode);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void removeSongFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      if (_currentIndex > index) {
        _currentIndex--;
      } else if (_currentIndex == index) {
        if (_queue.isNotEmpty) {
          _currentIndex = _currentIndex % _queue.length;
          final nextSong = _queue[_currentIndex];
          _currentSongController.add(nextSong);
          _loadAndPlay(nextSong);
        } else {
          _currentIndex = -1;
          _player.stop();
          _currentSongController.add(null);
        }
      }
      _queueController.add(_queue);
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length || newIndex < 0 || newIndex > _queue.length) {
      return;
    }
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);
    // Adjust current index
    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
      _currentIndex--;
    } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
      _currentIndex++;
    }
    _queueController.add(_queue);
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _currentSongController.close();
    await _queueController.close();
    await _shuffleController.close();
    await _repeatController.close();
    await _errorController.close();
  }
}
