import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/songs_data.dart';
import '../models/song_model.dart';

class PlayerController extends ChangeNotifier {
  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _likedSongsKey =
      'sonexa_liked_song_ids';

  static const String _recentlyPlayedKey =
      'sonexa_recently_played_song_ids';

  static const String _queueKey =
      'sonexa_queue_song_ids';

  static const String _playlistNamesKey =
      'sonexa_playlist_names';

  static const String _playlistPrefix =
      'sonexa_playlist_';

  // SettingsScreen already uses this exact key.
  static const String _autoplayKey =
      'settings_autoplay';

  // ============================================================
  // PERSISTENCE
  // ============================================================

  SharedPreferences? _preferences;

  bool _persistenceRestored = false;

  bool _stateChangedBeforeRestore = false;

  Future<void> _pendingSave =
      Future<void>.value();

  // ============================================================
  // REAL AUDIO EQUALIZER
  // ============================================================

  final AndroidEqualizer _equalizer =
      AndroidEqualizer();

  AndroidEqualizer get equalizer =>
      _equalizer;

  // ============================================================
  // AUDIO PLAYER
  // ============================================================

  late final AudioPlayer _audioPlayer =
      AudioPlayer(
    audioPipeline: AudioPipeline(
      androidAudioEffects: <AndroidAudioEffect>[
        _equalizer,
      ],
    ),
  );

  StreamSubscription<Duration>?
      _positionSubscription;

  StreamSubscription<Duration?>?
      _durationSubscription;

  StreamSubscription<PlayerState>?
      _playerStateSubscription;

  // ============================================================
  // SONG LIST
  // ============================================================

  // allSongs is the single source of truth.
  List<SongModel> get songs => allSongs;

  // ============================================================
  // CURRENT SONG
  // ============================================================

  int currentIndex = 0;

  SongModel get currentSongData {
    if (songs.isEmpty) {
      throw StateError(
        'SONEXA has no songs.',
      );
    }

    if (currentIndex < 0 ||
        currentIndex >= songs.length) {
      currentIndex = 0;
    }

    return songs[currentIndex];
  }

  String get currentSong =>
      currentSongData.title;

  String get currentArtist =>
      currentSongData.artist;

  String get currentImage =>
      currentSongData.imagePath;

  String get currentAudio =>
      currentSongData.audioPath;

  // ============================================================
  // PLAYING STATE
  // ============================================================

  bool isPlaying = false;

  // ============================================================
  // ACTIVE SONG STATE
  // ============================================================
  //
  // false:
  // - Login ke baad
  // - Initial controller load
  // - Logout ke baad
  //
  // true:
  // - User ne song play kiya
  // - Next / Previous song play hua
  // - Queue se song play hua
  //
  // MiniPlayer isi state ke basis par visible hoga.
  // ============================================================

  bool hasActiveSong = false;

  // ============================================================
  // AUTOPLAY STATE
  // ============================================================

  bool _autoplay = true;

  bool get autoplay => _autoplay;

  // Prevents the completed listener from firing
  // more than once for the same song transition.
  bool _handlingCompletion = false;

  // ============================================================
  // LIKE STATE
  // ============================================================

  final List<SongModel> _likedSongs =
      <SongModel>[];

  List<SongModel> get likedSongs =>
      List<SongModel>.unmodifiable(
        _likedSongs,
      );

  int get likedSongsCount =>
      _likedSongs.length;

  bool isLiked = false;

  // ============================================================
  // RECENTLY PLAYED
  // ============================================================

  final List<SongModel> _recentlyPlayed =
      <SongModel>[];

  List<SongModel> get recentlyPlayed =>
      List<SongModel>.unmodifiable(
        _recentlyPlayed,
      );

  int get recentlyPlayedCount =>
      _recentlyPlayed.length;

  // ============================================================
  // QUEUE
  // ============================================================

  final List<SongModel> _queue =
      <SongModel>[];

  List<SongModel> get queue =>
      List<SongModel>.unmodifiable(
        _queue,
      );

  bool get hasQueue =>
      _queue.isNotEmpty;

  // ============================================================
  // PLAYLISTS
  // ============================================================

  final Map<String, List<SongModel>>
      _playlists =
      <String, List<SongModel>>{};

  List<String> get playlistNames =>
      List<String>.unmodifiable(
        _playlists.keys,
      );

  // ============================================================
  // POSITION / DURATION
  // ============================================================

  Duration position =
      Duration.zero;

  Duration duration =
      Duration.zero;

  double get progress {
    if (duration.inMilliseconds <= 0) {
      return 0.0;
    }

    final double value =
        position.inMilliseconds /
            duration.inMilliseconds;

    return value.clamp(0.0, 1.0);
  }

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  PlayerController() {
    _listenToAudio();

    unawaited(
      _initializeController(),
    );
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initializeController() async {
    await _restoreSavedData();

    await _loadAutoplaySetting();

    if (songs.isNotEmpty) {
      await _loadSong(
        0,
        autoPlay: false,
        addToRecentlyPlayed: false,
      );
    }

    _updateCurrentLikeState();

    notifyListeners();
  }

  // ============================================================
  // LOAD AUTOPLAY SETTING
  // ============================================================

  Future<void> _loadAutoplaySetting() async {
    try {
      final SharedPreferences prefs =
          _preferences ??
              await SharedPreferences.getInstance();

      _preferences = prefs;

      await prefs.reload();

      _autoplay =
          prefs.getBool(
                _autoplayKey,
              ) ??
              true;
    } catch (error) {
      debugPrint(
        'SONEXA Autoplay Load Error: $error',
      );

      // SettingsScreen also defaults to true.
      _autoplay = true;
    }
  }

  // ============================================================
  // REFRESH AUTOPLAY SETTING
  // ============================================================
  //
  // Useful if the user changes Autoplay in Settings
  // while PlayerController is already alive.
  // ============================================================

  Future<void> refreshAutoplaySetting() async {
    await _loadAutoplaySetting();

    notifyListeners();
  }

  // ============================================================
  // RESTORE ALL SAVED DATA
  // ============================================================

  Future<void> _restoreSavedData() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      _preferences = prefs;

      if (_stateChangedBeforeRestore) {
        _persistenceRestored = true;

        await _persistAll();

        return;
      }

      // --------------------------------------------------------
      // LIKED SONGS
      // --------------------------------------------------------

      final List<String> likedIds =
          prefs.getStringList(
                _likedSongsKey,
              ) ??
              <String>[];

      _likedSongs.clear();

      for (final String id in likedIds) {
        final SongModel? song =
            findSongById(id);

        if (song != null &&
            !_likedSongs.any(
              (SongModel item) =>
                  item.id == song.id,
            )) {
          _likedSongs.add(song);
        }
      }

      // --------------------------------------------------------
      // RECENTLY PLAYED
      // --------------------------------------------------------

      final List<String> recentIds =
          prefs.getStringList(
                _recentlyPlayedKey,
              ) ??
              <String>[];

      _recentlyPlayed.clear();

      for (final String id in recentIds) {
        final SongModel? song =
            findSongById(id);

        if (song != null &&
            !_recentlyPlayed.any(
              (SongModel item) =>
                  item.id == song.id,
            )) {
          _recentlyPlayed.add(song);
        }
      }

      // --------------------------------------------------------
      // QUEUE
      // --------------------------------------------------------

      final List<String> queueIds =
          prefs.getStringList(
                _queueKey,
              ) ??
              <String>[];

      _queue.clear();

      for (final String id in queueIds) {
        final SongModel? song =
            findSongById(id);

        if (song != null &&
            !_queue.any(
              (SongModel item) =>
                  item.id == song.id,
            )) {
          _queue.add(song);
        }
      }

      // --------------------------------------------------------
      // PLAYLISTS
      // --------------------------------------------------------

      final List<String> savedPlaylistNames =
          prefs.getStringList(
                _playlistNamesKey,
              ) ??
              <String>[];

      _playlists.clear();

      for (final String playlistName
          in savedPlaylistNames) {
        final String storageKey =
            _playlistStorageKey(
          playlistName,
        );

        final List<String> songIds =
            prefs.getStringList(
                  storageKey,
                ) ??
                <String>[];

        final List<SongModel> playlist =
            <SongModel>[];

        for (final String id in songIds) {
          final SongModel? song =
              findSongById(id);

          if (song != null &&
              !playlist.any(
                (SongModel item) =>
                    item.id == song.id,
              )) {
            playlist.add(song);
          }
        }

        _playlists[playlistName] =
            playlist;
      }

      _persistenceRestored = true;
    } catch (error) {
      debugPrint(
        'SONEXA Restore Error: $error',
      );

      _persistenceRestored = true;
    }
  }

  // ============================================================
  // MARK STATE CHANGE
  // ============================================================

  void _markStateChanged() {
    if (!_persistenceRestored) {
      _stateChangedBeforeRestore = true;
    }

    _schedulePersist();
  }

  // ============================================================
  // SCHEDULE SAVE
  // ============================================================

  void _schedulePersist() {
    _pendingSave = _pendingSave.then(
      (_) => _persistAll(),
    );
  }

  // ============================================================
  // PERSIST ALL DATA
  // ============================================================

  Future<void> _persistAll() async {
    final SharedPreferences? prefs =
        _preferences;

    if (prefs == null) {
      return;
    }

    try {
      // --------------------------------------------------------
      // LIKES
      // --------------------------------------------------------

      await prefs.setStringList(
        _likedSongsKey,
        _likedSongs
            .map(
              (SongModel song) => song.id,
            )
            .toList(),
      );

      // --------------------------------------------------------
      // RECENTLY PLAYED
      // --------------------------------------------------------

      await prefs.setStringList(
        _recentlyPlayedKey,
        _recentlyPlayed
            .map(
              (SongModel song) => song.id,
            )
            .toList(),
      );

      // --------------------------------------------------------
      // QUEUE
      // --------------------------------------------------------

      await prefs.setStringList(
        _queueKey,
        _queue
            .map(
              (SongModel song) => song.id,
            )
            .toList(),
      );

      // --------------------------------------------------------
      // PLAYLIST NAMES
      // --------------------------------------------------------

      await prefs.setStringList(
        _playlistNamesKey,
        _playlists.keys.toList(),
      );

      // --------------------------------------------------------
      // REMOVE OLD PLAYLIST DATA
      // --------------------------------------------------------

      final Set<String> currentKeys =
          <String>{
        for (final String name
            in _playlists.keys)
          _playlistStorageKey(name),
      };

      final Set<String> oldKeys =
          prefs
              .getKeys()
              .where(
                (String key) =>
                    key.startsWith(
                      _playlistPrefix,
                    ) &&
                    key !=
                        _playlistNamesKey,
              )
              .toSet();

      for (final String oldKey
          in oldKeys.difference(
        currentKeys,
      )) {
        await prefs.remove(oldKey);
      }

      // --------------------------------------------------------
      // SAVE EACH PLAYLIST
      // --------------------------------------------------------

      for (final MapEntry<String,
              List<SongModel>> entry
          in _playlists.entries) {
        await prefs.setStringList(
          _playlistStorageKey(
            entry.key,
          ),
          entry.value
              .map(
                (SongModel song) => song.id,
              )
              .toList(),
        );
      }
    } catch (error) {
      debugPrint(
        'SONEXA Persistence Error: $error',
      );
    }
  }

  // ============================================================
  // STORAGE - PLAYLIST KEY
  // ============================================================

  String _playlistStorageKey(
    String playlistName,
  ) {
    return '$_playlistPrefix$playlistName';
  }

  // ============================================================
  // AUDIO LISTENERS
  // ============================================================

  void _listenToAudio() {
    _positionSubscription =
        _audioPlayer.positionStream.listen(
      (Duration newPosition) {
        position = newPosition;
        notifyListeners();
      },
    );

    _durationSubscription =
        _audioPlayer.durationStream.listen(
      (Duration? newDuration) {
        duration =
            newDuration ?? Duration.zero;

        notifyListeners();
      },
    );

    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen(
      (PlayerState state) {
        isPlaying = state.playing;

        // ======================================================
        // AUTOPLAY
        // ======================================================
        //
        // This triggers ONLY when the current audio has
        // actually reached the completed state.
        //
        // Autoplay ON:
        //   -> automatically play next song
        //
        // Autoplay OFF:
        //   -> stop and keep the current song selected
        //
        // Manual Next/Previous are NOT controlled by this.
        // ======================================================

        if (state.processingState ==
            ProcessingState.completed) {
          unawaited(
            _handleSongCompleted(),
          );
        }

        notifyListeners();
      },
    );
  }

  // ============================================================
  // HANDLE SONG COMPLETED
  // ============================================================

  Future<void> _handleSongCompleted() async {
    if (_handlingCompletion) {
      return;
    }

    _handlingCompletion = true;

    try {
      final bool shouldAutoplay =
          await _isAutoplayEnabled();

      if (!shouldAutoplay) {
        // Autoplay OFF:
        // Do not move to another song.
        isPlaying = false;
        position = duration;

        notifyListeners();

        return;
      }

      // Autoplay ON:
      // Move to the next song automatically.
      await nextSong();
    } catch (error) {
      debugPrint(
        'SONEXA Autoplay Error: $error',
      );
    } finally {
      _handlingCompletion = false;
    }
  }

  // ============================================================
  // CHECK AUTOPLAY
  // ============================================================

  Future<bool> _isAutoplayEnabled() async {
    try {
      final SharedPreferences prefs =
          _preferences ??
              await SharedPreferences.getInstance();

      _preferences = prefs;

      await prefs.reload();

      _autoplay =
          prefs.getBool(
                _autoplayKey,
              ) ??
              true;

      return _autoplay;
    } catch (error) {
      debugPrint(
        'SONEXA Autoplay Read Error: $error',
      );

      return _autoplay;
    }
  }

  // ============================================================
  // LOAD SONG
  // ============================================================

  Future<void> _loadSong(
    int index, {
    bool autoPlay = true,
    bool addToRecentlyPlayed = true,
  }) async {
    if (songs.isEmpty) {
      return;
    }

    if (index < 0 ||
        index >= songs.length) {
      return;
    }

    currentIndex = index;

    position = Duration.zero;
    duration = Duration.zero;
    isPlaying = false;

    // ----------------------------------------------------------
    // IMPORTANT:
    // Initial controller load uses autoPlay:false,
    // so Mini Player will remain hidden.
    //
    // When the user actually plays a song,
    // autoPlay:true and hasActiveSong becomes true.
    // ----------------------------------------------------------

    if (autoPlay) {
      hasActiveSong = true;
    }

    _updateCurrentLikeState();

    if (addToRecentlyPlayed) {
      _addToRecentlyPlayed(
        songs[index],
      );
    }

    notifyListeners();

    try {
      await _audioPlayer.stop();

      await _audioPlayer.setAsset(
        songs[index].audioPath,
      );

      duration =
          _audioPlayer.duration ??
              Duration.zero;

      notifyListeners();

      if (autoPlay) {
        await _audioPlayer.play();
      }
    } catch (error) {
      debugPrint(
        'SONEXA Audio Error: $error',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // PLAY SONG BY TITLE + ARTIST
  // ============================================================

  Future<void> playSong(
    String song,
    String artist,
  ) async {
    final int index =
        songs.indexWhere(
      (SongModel item) =>
          item.title.toLowerCase() ==
              song.toLowerCase() &&
          item.artist.toLowerCase() ==
              artist.toLowerCase(),
    );

    if (index == -1) {
      return;
    }

    await _loadSong(
      index,
      autoPlay: true,
      addToRecentlyPlayed: true,
    );
  }

  // ============================================================
  // PLAY SONG MODEL
  // ============================================================

  Future<void> playSongModel(
    SongModel song,
  ) async {
    int index =
        songs.indexWhere(
      (SongModel item) =>
          item.id == song.id,
    );

    if (index == -1) {
      index =
          songs.indexWhere(
        (SongModel item) =>
            item.title == song.title &&
            item.artist == song.artist,
      );
    }

    if (index == -1) {
      return;
    }

    await _loadSong(
      index,
      autoPlay: true,
      addToRecentlyPlayed: true,
    );
  }

  // ============================================================
  // PLAY SONG BY ID
  // ============================================================

  Future<void> playSongById(
    String id,
  ) async {
    final int index =
        songs.indexWhere(
      (SongModel item) =>
          item.id == id,
    );

    if (index == -1) {
      return;
    }

    await _loadSong(
      index,
      autoPlay: true,
      addToRecentlyPlayed: true,
    );
  }

  // ============================================================
  // PLAY / PAUSE
  // ============================================================

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.duration == null) {
          await _loadSong(
            currentIndex,
            autoPlay: true,
            addToRecentlyPlayed: false,
          );

          return;
        }

        // If Mini Player is being used to resume
        // an already selected song, it is active.
        hasActiveSong = true;

        await _audioPlayer.play();
      }
    } catch (error) {
      debugPrint(
        'SONEXA Play/Pause Error: $error',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // PLAY
  // ============================================================

  Future<void> play() async {
    try {
      hasActiveSong = true;

      await _audioPlayer.play();
    } catch (error) {
      debugPrint(
        'SONEXA Play Error: $error',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // PAUSE
  // ============================================================

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (error) {
      debugPrint(
        'SONEXA Pause Error: $error',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // SEEK PROGRESS
  // ============================================================

  Future<void> seekToProgress(
    double value,
  ) async {
    if (duration.inMilliseconds <= 0) {
      return;
    }

    final double safeValue =
        value.clamp(0.0, 1.0);

    final Duration newPosition =
        Duration(
      milliseconds:
          (duration.inMilliseconds *
                  safeValue)
              .round(),
    );

    try {
      await _audioPlayer.seek(
        newPosition,
      );
    } catch (error) {
      debugPrint(
        'SONEXA Seek Error: $error',
      );
    }
  }

  // ============================================================
  // SEEK TO POSITION
  // ============================================================

  Future<void> seekTo(
    Duration newPosition,
  ) async {
    try {
      await _audioPlayer.seek(
        newPosition,
      );
    } catch (error) {
      debugPrint(
        'SONEXA Seek Error: $error',
      );
    }
  }

  // ============================================================
  // STOP
  // ============================================================
  //
  // Used during logout.
  //
  // This will:
  // 1. Stop the actual audio.
  // 2. Reset position.
  // 3. Reset duration.
  // 4. Set playing to false.
  // 5. Hide Mini Player through hasActiveSong:false.
  // ============================================================

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();

      position = Duration.zero;
      duration = Duration.zero;
      isPlaying = false;
      hasActiveSong = false;

      _handlingCompletion = false;

      notifyListeners();
    } catch (error) {
      debugPrint(
        'SONEXA Stop Error: $error',
      );
    }
  }

  // ============================================================
  // SEEK FORWARD
  // ============================================================

  Future<void> seekForward([
    Duration amount =
        const Duration(seconds: 10),
  ]) async {
    final Duration target =
        position + amount;

    final Duration safeTarget =
        target > duration
            ? duration
            : target;

    await seekTo(safeTarget);
  }

  // ============================================================
  // SEEK BACKWARD
  // ============================================================

  Future<void> seekBackward([
    Duration amount =
        const Duration(seconds: 10),
  ]) async {
    final Duration target =
        position - amount;

    final Duration safeTarget =
        target < Duration.zero
            ? Duration.zero
            : target;

    await seekTo(safeTarget);
  }

  // ============================================================
  // NEXT SONG
  // ============================================================

  Future<void> nextSong() async {
    if (songs.isEmpty) {
      return;
    }

    // Manual Next should always work,
    // regardless of Autoplay setting.
    _handlingCompletion = true;

    try {
      final int nextIndex =
          currentIndex + 1;

      if (nextIndex >= songs.length) {
        await _loadSong(
          0,
          autoPlay: true,
          addToRecentlyPlayed: true,
        );

        return;
      }

      await _loadSong(
        nextIndex,
        autoPlay: true,
        addToRecentlyPlayed: true,
      );
    } finally {
      _handlingCompletion = false;
    }
  }

  // ============================================================
  // PREVIOUS SONG
  // ============================================================

  Future<void> previousSong() async {
    if (songs.isEmpty) {
      return;
    }

    _handlingCompletion = true;

    try {
      final int previousIndex =
          currentIndex - 1;

      if (previousIndex < 0) {
        await _loadSong(
          songs.length - 1,
          autoPlay: true,
          addToRecentlyPlayed: true,
        );

        return;
      }

      await _loadSong(
        previousIndex,
        autoPlay: true,
        addToRecentlyPlayed: true,
      );
    } finally {
      _handlingCompletion = false;
    }
  }

  // ============================================================
  // LIKE CURRENT SONG
  // ============================================================

  void toggleLike() {
    final SongModel song =
        currentSongData;

    final int index =
        _likedSongs.indexWhere(
      (SongModel item) =>
          item.id == song.id,
    );

    if (index >= 0) {
      _likedSongs.removeAt(index);
      isLiked = false;
    } else {
      _likedSongs.add(song);
      isLiked = true;
    }

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // LIKE SONG
  // ============================================================

  Future<void> toggleLikeSong(
    SongModel song,
  ) async {
    final int index =
        _likedSongs.indexWhere(
      (SongModel item) =>
          item.id == song.id,
    );

    if (index >= 0) {
      _likedSongs.removeAt(index);
    } else {
      _likedSongs.add(song);
    }

    if (songs.isNotEmpty &&
        song.id == currentSongData.id) {
      isLiked = index < 0;
    }

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // CHECK LIKE
  // ============================================================

  bool isSongLiked(
    SongModel song,
  ) {
    return _likedSongs.any(
      (SongModel item) =>
          item.id == song.id,
    );
  }

  // ============================================================
  // UPDATE CURRENT LIKE STATE
  // ============================================================

  void _updateCurrentLikeState() {
    if (songs.isEmpty) {
      isLiked = false;
      return;
    }

    final String currentId =
        currentSongData.id;

    isLiked = _likedSongs.any(
      (SongModel item) =>
          item.id == currentId,
    );
  }

  // ============================================================
  // RECENTLY PLAYED
  // ============================================================

  void _addToRecentlyPlayed(
    SongModel song,
  ) {
    _recentlyPlayed.removeWhere(
      (SongModel item) =>
          item.id == song.id,
    );

    _recentlyPlayed.insert(
      0,
      song,
    );

    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed.removeRange(
        20,
        _recentlyPlayed.length,
      );
    }

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // CLEAR RECENTLY PLAYED
  // ============================================================

  void clearRecentlyPlayed() {
    if (_recentlyPlayed.isEmpty) {
      return;
    }

    _recentlyPlayed.clear();

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // QUEUE - ADD ONE SONG
  // ============================================================

  void addToQueue(
    SongModel song,
  ) {
    final bool exists =
        _queue.any(
      (SongModel item) =>
          item.id == song.id,
    );

    if (exists) {
      return;
    }

    _queue.add(song);

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // QUEUE - ADD MULTIPLE SONGS
  // ============================================================

  void addSongsToQueue(
    List<SongModel> songsToAdd,
  ) {
    bool changed = false;

    for (final SongModel song
        in songsToAdd) {
      final bool exists =
          _queue.any(
        (SongModel item) =>
            item.id == song.id,
      );

      if (!exists) {
        _queue.add(song);
        changed = true;
      }
    }

    if (!changed) {
      return;
    }

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // QUEUE - REMOVE BY INDEX
  // ============================================================

  void removeFromQueue(
    int index,
  ) {
    if (index < 0 ||
        index >= _queue.length) {
      return;
    }

    _queue.removeAt(index);

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // QUEUE - REMOVE SONG MODEL
  // ============================================================

  void removeSongFromQueue(
    SongModel song,
  ) {
    final int oldLength =
        _queue.length;

    _queue.removeWhere(
      (SongModel item) =>
          item.id == song.id,
    );

    if (_queue.length == oldLength) {
      return;
    }

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // QUEUE - CLEAR
  // ============================================================

  void clearQueue() {
    if (_queue.isEmpty) {
      return;
    }

    _queue.clear();

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // QUEUE - PLAY SONG
  // ============================================================

  Future<void> playQueueSong(
    Object item,
  ) async {
    if (_queue.isEmpty) {
      return;
    }

    int index = -1;

    if (item is int) {
      index = item;
    } else if (item is SongModel) {
      index = _queue.indexWhere(
        (SongModel song) =>
            song.id == item.id,
      );
    }

    if (index < 0 ||
        index >= _queue.length) {
      return;
    }

    final SongModel song =
        _queue[index];

    await playSongModel(song);
  }

  // ============================================================
  // PLAY ENTIRE QUEUE
  // ============================================================

  Future<void> playQueue() async {
    if (_queue.isEmpty) {
      return;
    }

    await playSongModel(
      _queue.first,
    );
  }

  // ============================================================
  // PLAYLIST - CREATE
  // ============================================================

  Future<void> createPlaylist(
    String name,
  ) async {
    final String playlistName =
        name.trim();

    if (playlistName.isEmpty) {
      return;
    }

    if (_playlists.containsKey(
      playlistName,
    )) {
      return;
    }

    _playlists[playlistName] =
        <SongModel>[];

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // PLAYLIST - DELETE
  // ============================================================

  Future<void> deletePlaylist(
    String name,
  ) async {
    final bool removed =
        _playlists.remove(name) != null;

    if (!removed) {
      return;
    }

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // PLAYLIST - GET SONGS
  // ============================================================

  List<SongModel> getPlaylistSongs(
    String name,
  ) {
    final List<SongModel>? playlist =
        _playlists[name];

    if (playlist == null) {
      return const <SongModel>[];
    }

    return List<SongModel>.unmodifiable(
      playlist,
    );
  }

  // ============================================================
  // PLAYLIST - ADD SONG
  // ============================================================

  Future<void> addSongToPlaylist(
    String playlistName,
    SongModel song,
  ) async {
    final List<SongModel>? playlist =
        _playlists[playlistName];

    if (playlist == null) {
      return;
    }

    final bool alreadyExists =
        playlist.any(
      (SongModel item) =>
          item.id == song.id,
    );

    if (alreadyExists) {
      return;
    }

    playlist.add(song);

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // PLAYLIST - REMOVE SONG
  // ============================================================

  Future<void> removeSongFromPlaylist(
    String playlistName,
    SongModel song,
  ) async {
    final List<SongModel>? playlist =
        _playlists[playlistName];

    if (playlist == null) {
      return;
    }

    final int oldLength =
        playlist.length;

    playlist.removeWhere(
      (SongModel item) =>
          item.id == song.id,
    );

    if (playlist.length == oldLength) {
      return;
    }

    _markStateChanged();

    notifyListeners();
  }

  // ============================================================
  // PLAYLIST - ADD CURRENT SONG
  // ============================================================

  Future<void> addCurrentSongToPlaylist(
    String playlistName,
  ) async {
    await addSongToPlaylist(
      playlistName,
      currentSongData,
    );
  }

  // ============================================================
  // PLAYLIST - REMOVE CURRENT SONG
  // ============================================================

  Future<void> removeCurrentSongFromPlaylist(
    String playlistName,
  ) async {
    await removeSongFromPlaylist(
      playlistName,
      currentSongData,
    );
  }

  // ============================================================
  // PLAYLIST - CHECK SONG
  // ============================================================

  bool playlistContainsSong(
    String playlistName,
    SongModel song,
  ) {
    final List<SongModel>? playlist =
        _playlists[playlistName];

    if (playlist == null) {
      return false;
    }

    return playlist.any(
      (SongModel item) =>
          item.id == song.id,
    );
  }

  // ============================================================
  // FIND SONG BY ID
  // ============================================================

  SongModel? findSongById(
    String id,
  ) {
    for (final SongModel song
        in songs) {
      if (song.id == id) {
        return song;
      }
    }

    return null;
  }

  // ============================================================
  // FIND SONG BY TITLE
  // ============================================================

  SongModel? findSongByTitle(
    String title,
  ) {
    for (final SongModel song
        in songs) {
      if (song.title.toLowerCase() ==
          title.toLowerCase()) {
        return song;
      }
    }

    return null;
  }

  // ============================================================
  // FORMAT DURATION
  // ============================================================

  String formatDuration(
    Duration value,
  ) {
    if (value.inMilliseconds <= 0) {
      return '0:00';
    }

    final int minutes =
        value.inMinutes;

    final int seconds =
        value.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // CURRENT POSITION TEXT
  // ============================================================

  String get currentPositionText {
    return formatDuration(position);
  }

  // ============================================================
  // TOTAL DURATION TEXT
  // ============================================================

  String get totalDurationText {
    return formatDuration(duration);
  }

  // ============================================================
  // AUDIO PLAYER ACCESS
  // ============================================================

  AudioPlayer get audioPlayer =>
      _audioPlayer;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();

    _positionSubscription = null;
    _durationSubscription = null;
    _playerStateSubscription = null;

    _audioPlayer.dispose();

    super.dispose();
  }
}

