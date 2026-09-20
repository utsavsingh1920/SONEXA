import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/songs_data.dart';
import '../models/song_model.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';
import '../services/audius_api_service.dart';
import '../services/itunes_api_service.dart';
import '../services/jamendo_api_service.dart';
import 'playback_screen.dart';

enum _SearchFilter { all, indian, fullSongs }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  bool _isFocused = false;

  Timer? _searchDebounce;
  List<SongModel> _searchResults = <SongModel>[];
  bool _isSearching = false;
  String? _searchError;
  int _searchRequestId = 0;
  _SearchFilter _selectedFilter = _SearchFilter.all;

  // ============================================================
  // PLAYBACK ROUTE GUARD
  // ============================================================

  bool _isOpeningPlayback = false;

  // ============================================================
  // RECENT SEARCHES
  // ============================================================

  final List<String> _recentSearches = [
    'Hawayein',
    'Arijit Singh',
    'Romantic',
    'Bollywood',
  ];

  // ============================================================
  // TRENDING SEARCHES
  // ============================================================

  final List<String> _trendingSearches = const [
    'Arijit Singh',
    'Hawayein',
    'Romantic Songs',
    'Bollywood Hits',
    'Chill',
    'Rahat Fateh Ali Khan',
  ];

  // ============================================================
  // ARTISTS
  // ============================================================

  final List<_ArtistData> _artists = const [
    _ArtistData(
      name: 'Arijit Singh',
      imagePath: 'assets/images/artists/arijit_singh.jpg',
      colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
    ),
    _ArtistData(
      name: 'Rahat Fateh Ali Khan',
      imagePath: 'assets/images/artists/rahat_fateh_ali_khan.jpg',
      colors: [Color(0xFFFF4B2B), Color(0xFFB31217)],
    ),
    _ArtistData(
      name: 'Mohit Chauhan',
      imagePath: 'assets/images/artists/mohit_chauhan.jpg',
      colors: [Color(0xFF64748B), Color(0xFF1E293B)],
    ),
    _ArtistData(
      name: 'Atif Aslam',
      imagePath: 'assets/images/artists/atif_aslam.jpg',
      colors: [Color(0xFF0F9BA8), Color(0xFF075985)],
    ),
    _ArtistData(
      name: 'Javed Bashir',
      imagePath: 'assets/images/artists/javed_bashir.jpg',
      colors: [Color(0xFF64748B), Color(0xFF334155)],
    ),
    _ArtistData(
      name: 'Pritam',
      imagePath: 'assets/images/kesariya.jpg',
      colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
    ),
    _ArtistData(
      name: 'Shreya Ghoshal',
      imagePath: 'assets/images/janam_janam.jpg',
      colors: [Color(0xFFEC4899), Color(0xFF9D174D)],
    ),
    _ArtistData(
      name: 'Jubin Nautiyal',
      imagePath: 'assets/images/tera_deedar_hua.jpg',
      colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
    ),
    _ArtistData(
      name: 'Neha Kakkar',
      imagePath: 'assets/images/dagabaaz_re.jpg',
      colors: [Color(0xFFF97316), Color(0xFF9A3412)],
    ),
    _ArtistData(
      name: 'Badshah',
      imagePath: 'assets/images/pee_loon.jpg',
      colors: [Color(0xFF06B6D4), Color(0xFF155E75)],
    ),
    _ArtistData(
      name: 'Sonu Nigam',
      imagePath: 'assets/images/hawayein.jpg',
      colors: [Color(0xFF8B5CF6), Color(0xFF312E81)],
    ),
    _ArtistData(
      name: 'KK',
      imagePath: 'assets/images/tu_jaane_na.jpg',
      colors: [Color(0xFF475569), Color(0xFF0F172A)],
    ),
    _ArtistData(
      name: 'Sunidhi Chauhan',
      imagePath: 'assets/images/mast_magan.jpg',
      colors: [Color(0xFFDB2777), Color(0xFF831843)],
    ),
    _ArtistData(
      name: 'A. R. Rahman',
      imagePath: 'assets/images/tum_jo_aaye.jpg',
      colors: [Color(0xFF0D9488), Color(0xFF134E4A)],
    ),
    _ArtistData(
      name: 'Vishal Mishra',
      imagePath: 'assets/images/ye_tune_kya_kiya.jpg',
      colors: [Color(0xFF7C3AED), Color(0xFF581C87)],
    ),
    _ArtistData(
      name: 'Darshan Raval',
      imagePath: 'assets/images/tera_deedar_hua.jpg',
      colors: [Color(0xFF2563EB), Color(0xFF172554)],
    ),
    _ArtistData(
      name: 'Diljit Dosanjh',
      imagePath: 'assets/images/dagabaaz_re.jpg',
      colors: [Color(0xFFF59E0B), Color(0xFF78350F)],
    ),
    _ArtistData(
      name: 'AP Dhillon',
      imagePath: 'assets/images/kesariya.jpg',
      colors: [Color(0xFFEF4444), Color(0xFF7F1D1D)],
    ),
  ];

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<_CategoryData> _categories = const [
    _CategoryData(
      title: 'Trending India',
      icon: Icons.local_fire_department_rounded,
      colors: [Color(0xFFFF7043), Color(0xFFD84315)],
      searchValue: 'Bollywood Hits',
    ),
    _CategoryData(
      title: 'Bollywood',
      icon: Icons.movie_creation_rounded,
      colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
      searchValue: 'Bollywood',
    ),
    _CategoryData(
      title: 'Romantic',
      icon: Icons.favorite_rounded,
      colors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
      searchValue: 'Romantic',
    ),
    _CategoryData(
      title: 'Punjabi',
      icon: Icons.nightlight_round,
      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      searchValue: 'Punjabi Hits',
    ),
    _CategoryData(
      title: 'Hindi Pop',
      icon: Icons.fitness_center_rounded,
      colors: [Color(0xFFF97316), Color(0xFFC2410C)],
      searchValue: 'Hindi Pop',
    ),
    _CategoryData(
      title: 'Indie India',
      icon: Icons.graphic_eq_rounded,
      colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
      searchValue: 'Indian Indie',
    ),
    _CategoryData(
      title: 'Chill',
      icon: Icons.music_note_rounded,
      colors: [Color(0xFF8B20F5), Color(0xFF5E18D0)],
      searchValue: 'Hindi Chill',
    ),
    _CategoryData(
      title: 'Party',
      icon: Icons.headphones_rounded,
      colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
      searchValue: 'Bollywood Party',
    ),
    _CategoryData(
      title: 'Dance',
      icon: Icons.mic_rounded,
      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      searchValue: 'Bollywood Dance',
    ),
    _CategoryData(
      title: 'Workout',
      icon: Icons.piano_rounded,
      colors: [Color(0xFF0891B2), Color(0xFF155E75)],
      searchValue: 'Indian Workout',
    ),
    _CategoryData(
      title: 'Sad Songs',
      icon: Icons.album_rounded,
      colors: [Color(0xFFEC4899), Color(0xFF9D174D)],
      searchValue: 'Hindi Sad Songs',
    ),
    _CategoryData(
      title: 'Devotional',
      icon: Icons.celebration_rounded,
      colors: [Color(0xFFA855F7), Color(0xFF6D28D9)],
      searchValue: 'Indian Devotional',
    ),
    _CategoryData(
      title: 'Classical',
      icon: Icons.sentiment_dissatisfied_rounded,
      colors: [Color(0xFF6366F1), Color(0xFF3730A3)],
      searchValue: 'Indian Classical',
    ),
    _CategoryData(
      title: 'Ghazal',
      icon: Icons.directions_run_rounded,
      colors: [Color(0xFFD946EF), Color(0xFF86198F)],
      searchValue: 'Hindi Ghazal',
    ),
    _CategoryData(
      title: 'Sufi',
      icon: Icons.music_note_rounded,
      colors: [Color(0xFFF59E0B), Color(0xFF92400E)],
      searchValue: 'Hindi Sufi',
    ),
    _CategoryData(
      title: '90s Bollywood',
      icon: Icons.speaker_rounded,
      colors: [Color(0xFF14B8A6), Color(0xFF115E59)],
      searchValue: '90s Bollywood',
    ),
    _CategoryData(
      title: '2000s Hits',
      icon: Icons.bolt_rounded,
      colors: [Color(0xFF06B6D4), Color(0xFF155E75)],
      searchValue: '2000s Bollywood Hits',
    ),
    _CategoryData(
      title: 'Acoustic',
      icon: Icons.music_note_rounded,
      colors: [Color(0xFF84CC16), Color(0xFF3F6212)],
      searchValue: 'Acoustic',
    ),
    _CategoryData(
      title: 'Hip-Hop India',
      icon: Icons.library_music_rounded,
      colors: [Color(0xFF9333EA), Color(0xFF581C87)],
      searchValue: 'Indian Hip-Hop',
    ),
    _CategoryData(
      title: 'Global Music',
      icon: Icons.cloud_rounded,
      colors: [Color(0xFFF472B6), Color(0xFF9D174D)],
      searchValue: 'Global Music',
    ),
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(_handleFocusChange);
    _searchController.addListener(_handleSearchChange);
  }

  // ============================================================
  // FOCUS CHANGE
  // ============================================================

  void _handleFocusChange() {
    if (!mounted) return;

    final bool focused = _searchFocusNode.hasFocus;

    if (_isFocused == focused) return;

    setState(() {
      _isFocused = focused;
    });
  }

  // ============================================================
  // SEARCH TEXT CHANGE
  // ============================================================

  void _handleSearchChange() {
    if (!mounted) return;

    final String query = _query;

    setState(() {
      if (query.isEmpty) {
        _searchResults = <SongModel>[];
        _isSearching = false;
        _searchError = null;
      }
    });

    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _searchRequestId++;
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _performSearch(query),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_handleFocusChange);
    _searchController.removeListener(_handleSearchChange);

    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // GETTERS
  // ============================================================

  bool get _hasQuery {
    return _searchController.text.trim().isNotEmpty;
  }

  String get _query {
    return _searchController.text.trim();
  }

  // ============================================================
  // LOCAL FALLBACK RESULTS
  // ============================================================

  List<SongModel> _localMatches(String value) {
    final String query = value.toLowerCase().trim();

    if (query.isEmpty) {
      return [];
    }

    return allSongs.where((song) {
      final String title = song.title.toLowerCase();

      final String artist = song.artist.toLowerCase();

      final String album = song.album.toLowerCase();

      final String tags = song.tags.map((tag) => tag.toLowerCase()).join(' ');

      return title.contains(query) ||
          artist.contains(query) ||
          album.contains(query) ||
          tags.contains(query);
    }).toList();
  }

  Future<void> _performSearch(String value) async {
    final String query = value.trim();
    if (query.isEmpty) return;

    final int requestId = ++_searchRequestId;

    if (mounted) {
      setState(() {
        _isSearching = true;
        _searchError = null;
      });
    }

    try {
      final List<Future<List<SongModel>>> requests = <Future<List<SongModel>>>[
        if (_selectedFilter != _SearchFilter.fullSongs)
          _safeITunesSearch(query),
        if (_selectedFilter != _SearchFilter.indian) _safeJamendoSearch(query),
      ];

      final List<List<SongModel>> responses = await Future.wait(requests);
      final List<SongModel> onlineSongs = responses
          .expand((songs) => songs)
          .toList();

      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _searchResults = _mergeSongs(_localMatches(query), onlineSongs);
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _searchResults = _localMatches(query);
        _isSearching = false;
        _searchError = error.toString();
      });
    }
  }

  Future<List<SongModel>> _safeITunesSearch(String query) async {
    try {
      return await ITunesApiService.instance.searchSongs(query, limit: 20);
    } catch (error) {
      debugPrint('SONEXA iTunes partial search error: $error');
      return const <SongModel>[];
    }
  }

  Future<List<SongModel>> _safeJamendoSearch(String query) async {
    try {
      return await JamendoApiService.instance.searchTracks(query, limit: 20);
    } catch (error) {
      debugPrint('SONEXA Jamendo partial search error: $error');
      return const <SongModel>[];
    }
  }

  void _changeSearchFilter(_SearchFilter filter) {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _searchResults = <SongModel>[];
      _searchError = null;
    });

    if (_hasQuery) {
      _searchDebounce?.cancel();
      _performSearch(_query);
    }
  }

  Future<void> _loadTrending() async {
    const String label = 'Global Music';
    final int requestId = ++_searchRequestId;

    _searchDebounce?.cancel();

    if (mounted) {
      setState(() {
        _isSearching = true;
        _searchError = null;
        _searchResults = <SongModel>[];
      });
    }

    try {
      final List<SongModel> onlineSongs = await AudiusApiService.instance
          .getTrendingTracks(limit: 30);

      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _searchResults = _mergeSongs(_localMatches(label), onlineSongs);
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) return;

      setState(() {
        _searchResults = _localMatches(label);
        _isSearching = false;
        _searchError = error.toString();
      });
    }
  }

  List<SongModel> _mergeSongs(
    List<SongModel> localSongs,
    List<SongModel> onlineSongs,
  ) {
    final List<SongModel> merged = <SongModel>[];
    final Set<String> usedKeys = <String>{};

    for (final SongModel song in <SongModel>[...localSongs, ...onlineSongs]) {
      final String key = '${song.source}:${song.id}';
      if (usedKeys.add(key)) merged.add(song);
    }

    return merged;
  }

  // ============================================================
  // KEYBOARD
  // ============================================================

  void _hideKeyboard() {
    _searchFocusNode.unfocus();

    FocusManager.instance.primaryFocus?.unfocus();

    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  void _showKeyboard() {
    if (!mounted) return;

    _searchFocusNode.requestFocus();
  }

  // ============================================================
  // SEARCH ACTIONS
  // ============================================================

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchRequestId++;
    _searchController.clear();

    _showKeyboard();
  }

  void _closeSearch() {
    _searchDebounce?.cancel();
    _searchRequestId++;
    _searchController.clear();

    _hideKeyboard();
  }

  void _addRecentSearch(String value) {
    final String search = value.trim();

    if (search.isEmpty) return;
    if (!mounted) return;

    setState(() {
      _recentSearches.removeWhere(
        (item) => item.toLowerCase() == search.toLowerCase(),
      );

      _recentSearches.insert(0, search);

      if (_recentSearches.length > 6) {
        _recentSearches.removeLast();
      }
    });
  }

  // ============================================================
  // SET SEARCH
  // ============================================================

  void _setSearch(String value, {bool useTrending = false}) {
    final String search = value.trim();

    if (search.isEmpty) return;

    _addRecentSearch(search);

    _searchController.value = TextEditingValue(
      text: search,
      selection: TextSelection.collapsed(offset: search.length),
    );

    if (useTrending) {
      _searchDebounce?.cancel();
      _loadTrending();
    }

    _hideKeyboard();
  }

  void _clearRecentSearches() {
    if (!mounted) return;

    setState(() {
      _recentSearches.clear();
    });
  }

  // ============================================================
  // BACK TO NORMAL SEARCH
  // ============================================================

  void _clearActiveSearchAndStay() {
    if (!_hasQuery) return;

    _searchController.clear();

    _hideKeyboard();
  }

  // ============================================================
  // PLAY SONG
  // ============================================================
  //
  // IMPORTANT:
  //
  // Search result par song tap karne par:
  //
  //     tap song
  //        ↓
  //     PlaybackScreen OPEN
  //        ↓
  //     selectedSong pass
  //        ↓
  //     PlaybackScreen selected song play karega
  //
  // PlaybackScreen open hone se pehle
  // playSongModel() nahi chalega.
  //
  // Isse route immediately open hota hai.
  //
  // ============================================================

  Future<void> _playSong(
    BuildContext context,
    SongModel song, {
    bool openPlayer = true,
  }) async {
    // ----------------------------------------------------------
    // DUPLICATE PLAYBACK ROUTE GUARD
    // ----------------------------------------------------------

    if (_isOpeningPlayback) {
      return;
    }

    // ----------------------------------------------------------
    // HIDE KEYBOARD
    // ----------------------------------------------------------

    _hideKeyboard();

    _addRecentSearch(song.title);

    // ----------------------------------------------------------
    // PLAY ONLY
    //
    // Safety path:
    // Agar kahin se openPlayer:false aata hai,
    // to sirf song play hoga.
    // ----------------------------------------------------------

    if (!openPlayer) {
      final PlayerController player = PlayerScope.read(context);

      await player.playSongModel(song, playbackSongs: _searchResults);
      return;
    }

    // ----------------------------------------------------------
    // LOCK PLAYBACK ROUTE
    // ----------------------------------------------------------

    _isOpeningPlayback = true;

    try {
      if (!context.mounted) {
        return;
      }

      // --------------------------------------------------------
      // OPEN PLAYBACK SCREEN IMMEDIATELY
      // --------------------------------------------------------
      //
      // Song ko PlaybackScreen ke andar start karwayenge.
      //
      // --------------------------------------------------------

      PlayerScope.read(context).setPlaybackSongs(_searchResults);

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlaybackScreen(selectedSong: song)),
      );
    } finally {
      // --------------------------------------------------------
      // PLAYBACK CLOSED
      // --------------------------------------------------------

      _isOpeningPlayback = false;

      if (context.mounted) {
        _hideKeyboard();
      }
    }
  }

  // ============================================================
  // PLAY ALL RESULTS
  // ============================================================

  Future<void> _playAllResults(
    BuildContext context,
    List<SongModel> songs,
  ) async {
    if (songs.isEmpty) return;

    _hideKeyboard();

    await _playSong(context, songs.first, openPlayer: true);
  }

  List<SongModel> _matchingSongs(
    SongModel selected,
    bool Function(SongModel song) predicate,
  ) {
    final List<SongModel> matchedSongs = _searchResults
        .where(predicate)
        .toList();
    return matchedSongs.isEmpty ? <SongModel>[selected] : matchedSongs;
  }

  void _showSongActions(BuildContext context, SongModel song) {
    final PlayerController player = PlayerScope.read(context);
    final bool albumSaved =
        song.album.trim().isNotEmpty && player.isAlbumSaved(song.album);
    final bool artistSaved = player.isArtistSaved(song.artist);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  player.isSongLiked(song)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
                title: Text(
                  player.isSongLiked(song)
                      ? 'Remove from Liked Songs'
                      : 'Add to Liked Songs',
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await player.toggleLikeSong(song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _choosePlaylist(context, player, song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.queue_music_rounded),
                title: const Text('Add to Queue'),
                onTap: () {
                  player.addToQueue(song);
                  Navigator.pop(sheetContext);
                  _showActionMessage(context, '${song.title} added to queue');
                },
              ),
              if (song.album.trim().isNotEmpty)
                ListTile(
                  leading: Icon(
                    albumSaved
                        ? Icons.bookmark_remove_rounded
                        : Icons.bookmark_add_rounded,
                  ),
                  title: Text(albumSaved ? 'Remove saved album' : 'Save album'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    if (albumSaved) {
                      await player.removeSavedAlbum(song.album);
                    } else {
                      await player.saveAlbum(
                        song.album,
                        _matchingSongs(
                          song,
                          (item) =>
                              item.album.trim().toLowerCase() ==
                              song.album.trim().toLowerCase(),
                        ),
                      );
                    }
                    if (context.mounted) {
                      _showActionMessage(
                        context,
                        albumSaved ? 'Album removed' : 'Album saved to Library',
                      );
                    }
                  },
                ),
              ListTile(
                leading: Icon(
                  artistSaved
                      ? Icons.bookmark_remove_rounded
                      : Icons.person_add_alt_1_rounded,
                ),
                title: Text(
                  artistSaved ? 'Remove saved artist' : 'Save artist',
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (artistSaved) {
                    await player.removeSavedArtist(song.artist);
                  } else {
                    await player.saveArtist(
                      song.artist,
                      _matchingSongs(
                        song,
                        (item) =>
                            item.artist.trim().toLowerCase() ==
                            song.artist.trim().toLowerCase(),
                      ),
                    );
                  }
                  if (context.mounted) {
                    _showActionMessage(
                      context,
                      artistSaved
                          ? 'Artist removed'
                          : 'Artist saved to Library',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _choosePlaylist(
    BuildContext context,
    PlayerController player,
    SongModel song,
  ) {
    if (player.playlistNames.isEmpty) {
      _showActionMessage(context, 'Create a playlist from Library first');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Choose playlist',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            ...player.playlistNames.map(
              (name) => ListTile(
                leading: const Icon(Icons.queue_music_rounded),
                title: Text(name),
                trailing: player.playlistContainsSong(name, song)
                    ? const Icon(Icons.check_rounded)
                    : const Icon(Icons.add_rounded),
                onTap: () async {
                  await player.addSongToPlaylist(name, song);
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  _showActionMessage(context, 'Added to $name');
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showActionMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _showAllArtists(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);
        final Color textColor = theme.colorScheme.onSurface;

        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'All Artists',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 28),
                  itemCount: _artists.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 15,
                    mainAxisExtent: 106,
                  ),
                  itemBuilder: (gridContext, index) {
                    final _ArtistData artist = _artists[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _setSearch(artist.name);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: artist.colors),
                              boxShadow: [
                                BoxShadow(
                                  color: artist.colors.first.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(
                              child: Image.asset(
                                artist.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: artist.colors,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            artist.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.82),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color textColor = theme.colorScheme.onSurface;

    final Color secondaryText = textColor.withValues(alpha: 0.62);

    final bool showRecent =
        _isFocused && !_hasQuery && _recentSearches.isNotEmpty;

    final List<SongModel> results = _searchResults;

    // ==========================================================
    // KEYBOARD SAFE BOTTOM SPACE
    // ==========================================================

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final double bottomPadding = keyboardHeight > 0 ? keyboardHeight + 24 : 140;

    return PopScope(
      canPop: !_hasQuery && !_isFocused,

      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }

        if (_hasQuery) {
          _clearActiveSearchAndStay();
          return;
        }

        if (_isFocused) {
          _hideKeyboard();
        }
      },

      child: Scaffold(
        resizeToAvoidBottomInset: true,

        backgroundColor: theme.scaffoldBackgroundColor,

        body: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // FIXED HEADER - DOES NOT SCROLL
              // ==================================================
              Container(
                width: double.infinity,
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 10),
                child: Text(
                  'Search',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                  ),
                ),
              ),

              // ==================================================
              // SCROLLABLE SEARCH CONTENT
              // ==================================================
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, bottomPadding),
                  children: [
                    // ==================================================
                    // SEARCH BOX
                    // ==================================================

                    _SearchBox(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      isFocused: _isFocused,
                      showRecent: showRecent,
                      recentSearches: _recentSearches,
                      onClear: _clearSearch,
                      onClose: _closeSearch,
                      onRecentTap: _setSearch,
                      onClearRecent: _clearRecentSearches,
                    ),

                    // ==================================================
                    // HOME SEARCH CONTENT
                    // ==================================================
                    if (!_hasQuery) ...[
                      const SizedBox(height: 16),

                      const _SectionTitle(title: 'Trending Searches'),

                      const SizedBox(height: 7),

                      // ==================================================
                      // TRENDING SEARCHES
                      // ==================================================
                      SizedBox(
                        height: 36,

                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,

                          physics: const BouncingScrollPhysics(),

                          padding: const EdgeInsets.only(right: 4),

                          itemCount: _trendingSearches.length,

                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 7);
                          },

                          itemBuilder: (context, index) {
                            final String item = _trendingSearches[index];

                            return GestureDetector(
                              onTap: () {
                                _setSearch(item);
                              },

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,

                                  borderRadius: BorderRadius.circular(19),

                                  border: Border.all(color: theme.dividerColor),
                                ),

                                child: Row(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      color: Color(0xFFA855F7),
                                      size: 15,
                                    ),

                                    const SizedBox(width: 5),

                                    Text(
                                      item,
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==================================================
                      // POPULAR ARTISTS
                      // ==================================================
                      Row(
                        children: [
                          const Expanded(
                            child: _SectionTitle(title: 'Popular Artists'),
                          ),

                          GestureDetector(
                            onTap: () {
                              _showAllArtists(context);
                            },

                            child: const Text(
                              'See all',
                              style: TextStyle(
                                color: Color(0xFFB77CFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        height: 91,

                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,

                          physics: const BouncingScrollPhysics(),

                          padding: const EdgeInsets.only(right: 4),

                          itemCount: _artists.take(10).length,

                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 10);
                          },

                          itemBuilder: (context, index) {
                            final _ArtistData artist = _artists[index];

                            return GestureDetector(
                              onTap: () {
                                _setSearch(artist.name);
                              },

                              child: SizedBox(
                                width: 78,

                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: artist.colors,
                                        ),

                                        boxShadow: [
                                          BoxShadow(
                                            color: artist.colors.first
                                                .withValues(alpha: 0.22),
                                            blurRadius: 9,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),

                                      padding: const EdgeInsets.all(2),

                                      child: ClipOval(
                                        child: Image.asset(
                                          artist.imagePath,

                                          width: 56,
                                          height: 56,

                                          fit: BoxFit.cover,

                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,

                                                    gradient: LinearGradient(
                                                      colors: artist.colors,
                                                    ),
                                                  ),

                                                  child: const Icon(
                                                    Icons.person_rounded,
                                                    color: Colors.white,
                                                    size: 28,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      artist.name,

                                      maxLines: 1,

                                      overflow: TextOverflow.ellipsis,

                                      textAlign: TextAlign.center,

                                      style: TextStyle(
                                        color: textColor.withValues(
                                          alpha: 0.78,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // CATEGORIES
                      // ==================================================
                      const _SectionTitle(title: 'Browse All Categories'),

                      const SizedBox(height: 8),

                      GridView.builder(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: _categories.length,

                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 9,
                              mainAxisSpacing: 9,
                              mainAxisExtent: 84,
                            ),

                        itemBuilder: (context, index) {
                          final _CategoryData category = _categories[index];

                          return _CategoryCard(
                            category: category,

                            onTap: () {
                              _setSearch(
                                category.searchValue,
                                useTrending: category.title == 'Global Music',
                              );
                            },
                          );
                        },
                      ),
                    ],

                    // ==================================================
                    // SEARCH RESULTS
                    // ==================================================
                    if (_hasQuery)
                      _SearchResults(
                        query: _query,
                        songs: results,
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _changeSearchFilter,
                        isLoading: _isSearching,
                        errorMessage: _searchError,
                        onRetry: _query.toLowerCase() == 'global music'
                            ? _loadTrending
                            : () => _performSearch(_query),

                        onPlay: (song) {
                          _playSong(context, song);
                        },

                        onPlayAll: () {
                          _playAllResults(context, results);
                        },
                        onMore: (song) => _showSongActions(context, song),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH BOX
// ============================================================================

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool showRecent;
  final List<String> recentSearches;

  final VoidCallback onClear;
  final VoidCallback onClose;
  final Function(String) onRecentTap;
  final VoidCallback onClearRecent;

  const _SearchBox({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.showRecent,
    required this.recentSearches,
    required this.onClear,
    required this.onClose,
    required this.onRecentTap,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color textColor = theme.colorScheme.onSurface;

    final Color secondaryText = textColor.withValues(alpha: 0.62);

    final Color searchSurface = theme.colorScheme.surface;

    final Color outlineColor = isFocused
        ? const Color(0xFFA855F7)
        : theme.colorScheme.onSurface.withValues(alpha: 0.34);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),

      curve: Curves.easeOutCubic,

      clipBehavior: Clip.antiAlias,

      decoration: BoxDecoration(
        color: searchSurface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: outlineColor, width: isFocused ? 1.4 : 1),

        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.07),
            blurRadius: showRecent ? 18 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: TextField(
              controller: controller,

              focusNode: focusNode,

              textInputAction: TextInputAction.search,

              keyboardType: TextInputType.text,

              autocorrect: false,

              enableSuggestions: true,

              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),

              cursorColor: const Color(0xFFA855F7),

              onSubmitted: (_) {
                _hideKeyboardFromField(focusNode);
              },

              decoration: InputDecoration(
                isDense: true,

                filled: false,

                border: InputBorder.none,

                enabledBorder: InputBorder.none,

                focusedBorder: InputBorder.none,

                disabledBorder: InputBorder.none,

                errorBorder: InputBorder.none,

                focusedErrorBorder: InputBorder.none,

                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFA855F7),
                  size: 22,
                ),

                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,

                  builder: (context, value, child) {
                    if (value.text.isNotEmpty) {
                      return IconButton(
                        padding: EdgeInsets.zero,

                        onPressed: onClear,

                        tooltip: 'Clear search',

                        icon: Icon(
                          Icons.close_rounded,
                          color: secondaryText,
                          size: 19,
                        ),
                      );
                    }

                    if (isFocused) {
                      return IconButton(
                        padding: EdgeInsets.zero,

                        onPressed: onClose,

                        tooltip: 'Close search',

                        icon: Icon(
                          Icons.close_rounded,
                          color: secondaryText,
                          size: 19,
                        ),
                      );
                    }

                    return IconButton(
                      padding: EdgeInsets.zero,

                      onPressed: () {
                        focusNode.requestFocus();
                      },

                      tooltip: 'Search',

                      icon: const Icon(
                        Icons.mic_none_rounded,
                        color: Color(0xFFA855F7),
                        size: 21,
                      ),
                    );
                  },
                ),

                hintText: 'Find your next favorite music',

                hintStyle: TextStyle(
                  color: textColor.withValues(alpha: 0.48),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),

                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 2,
                ),
              ),
            ),
          ),

          // ========================================================
          // RECENT SEARCHES
          // ========================================================
          if (showRecent)
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 3, 9, 8),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),

                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          color: Color(0xFFA855F7),
                          size: 16,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            'Recent Searches',

                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: onClearRecent,

                          child: const Text(
                            'Clear',

                            style: TextStyle(
                              color: Color(0xFFA855F7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...recentSearches
                      .take(5)
                      .map(
                        (search) => _RecentSearchItem(
                          title: search,

                          onTap: () {
                            onRecentTap(search);
                          },
                        ),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _hideKeyboardFromField(FocusNode node) {
    node.unfocus();

    FocusManager.instance.primaryFocus?.unfocus();

    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }
}

// ============================================================================
// RECENT SEARCH ITEM
// ============================================================================

class _RecentSearchItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _RecentSearchItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color textColor = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(10),

        onTap: onTap,

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: textColor.withValues(alpha: 0.40),
                size: 17,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.78),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                Icons.north_west_rounded,
                color: textColor.withValues(alpha: 0.40),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECTION TITLE
// ============================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      title,

      textAlign: TextAlign.left,

      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.35,
      ),
    );
  }
}

// ============================================================================
// ARTIST DATA
// ============================================================================

class _ArtistData {
  final String name;
  final String imagePath;
  final List<Color> colors;

  const _ArtistData({
    required this.name,
    required this.imagePath,
    required this.colors,
  });
}

// ============================================================================
// CATEGORY DATA
// ============================================================================

class _CategoryData {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final String searchValue;

  const _CategoryData({
    required this.title,
    required this.icon,
    required this.colors,
    required this.searchValue,
  });
}

// ============================================================================
// CATEGORY CARD
// ============================================================================

class _CategoryCard extends StatelessWidget {
  final _CategoryData category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(15),

        onTap: onTap,

        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),

          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: category.colors,
              ),

              boxShadow: [
                BoxShadow(
                  color: category.colors.first.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -22,

                  child: Container(
                    width: 70,
                    height: 70,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: Colors.white.withValues(alpha: 0.09),
                    ),
                  ),
                ),

                Positioned(
                  right: -23,
                  bottom: -36,

                  child: Container(
                    width: 84,
                    height: 84,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                Positioned(
                  top: 9,
                  right: 9,

                  child: SizedBox(
                    width: 34,
                    height: 34,

                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.13),

                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Center(
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 12,
                  right: 10,
                  bottom: 10,

                  child: Text(
                    category.title,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH RESULTS
// ============================================================================

class _SearchResults extends StatelessWidget {
  final String query;
  final List<SongModel> songs;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Function(SongModel) onPlay;
  final VoidCallback onPlayAll;
  final ValueChanged<SongModel> onMore;
  final _SearchFilter selectedFilter;
  final ValueChanged<_SearchFilter> onFilterChanged;

  const _SearchResults({
    required this.query,
    required this.songs,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onPlay,
    required this.onPlayAll,
    required this.onMore,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color textColor = theme.colorScheme.onSurface;

    if (isLoading && songs.isEmpty) {
      return _withFilters(const _SearchLoading());
    }

    if (errorMessage != null && songs.isEmpty) {
      return _withFilters(
        _SearchError(message: errorMessage!, onRetry: onRetry),
      );
    }

    if (songs.isEmpty) {
      return _withFilters(_NoSearchResults(query: query));
    }

    return _withFilters(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 16),

          if (isLoading) ...[
            const LinearProgressIndicator(
              minHeight: 2,
              color: Color(0xFFA855F7),
            ),
            const SizedBox(height: 10),
          ],

          if (errorMessage != null) ...[
            _InlineSearchWarning(onRetry: onRetry),
            const SizedBox(height: 10),
          ],

          Row(
            children: [
              Expanded(
                child: Text(
                  'Search Results',

                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Text(
                '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',

                style: TextStyle(
                  color: textColor.withValues(alpha: 0.52),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ==========================================================
          // PLAY FIRST RESULT
          // ==========================================================
          Material(
            color: Colors.transparent,

            child: InkWell(
              borderRadius: BorderRadius.circular(14),

              onTap: onPlayAll,

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),

                  borderRadius: BorderRadius.circular(14),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Text(
                        'Play first result',

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
                      size: 21,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          ...songs.map(
            (song) => _SearchSongTile(
              song: song,
              onMore: () => onMore(song),

              onTap: () {
                onPlay(song);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _withFilters(Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _SearchFilterBar(
          selectedFilter: selectedFilter,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ============================================================================
// SEARCH FILTERS
// ============================================================================

class _SearchFilterBar extends StatelessWidget {
  final _SearchFilter selectedFilter;
  final ValueChanged<_SearchFilter> onChanged;

  const _SearchFilterBar({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterChip(context, label: 'All', filter: _SearchFilter.all),
          const SizedBox(width: 8),
          _filterChip(context, label: 'Indian', filter: _SearchFilter.indian),
          const SizedBox(width: 8),
          _filterChip(
            context,
            label: 'Full Songs',
            filter: _SearchFilter.fullSongs,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required _SearchFilter filter,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool selected = selectedFilter == filter;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(filter),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.68),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackTypeBadge extends StatelessWidget {
  final SongModel song;

  const _TrackTypeBadge({required this.song});

  @override
  Widget build(BuildContext context) {
    final bool preview = song.isPreview;
    final Color color = preview
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Text(
          preview ? '30-SEC PREVIEW' : 'FULL TRACK',
          style: TextStyle(
            color: color,
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH SONG TILE
// ============================================================================

class _SearchSongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _SearchSongTile({
    required this.song,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final PlayerController player = PlayerScope.of(context);

    final Color textColor = theme.colorScheme.onSurface;

    final bool isCurrent = player.currentSongData.id == song.id;

    final bool isLiked = player.isSongLiked(song);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      decoration: BoxDecoration(
        color: isCurrent
            ? theme.colorScheme.primary.withValues(alpha: 0.10)
            : theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: isCurrent
              ? theme.colorScheme.primary.withValues(alpha: 0.55)
              : theme.dividerColor,
        ),
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(15),

          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.all(8),

            child: Row(
              children: [
                // ==================================================
                // SONG IMAGE
                // ==================================================

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: song.imagePath.trim().isEmpty
                      ? _SongArtworkFallback(theme: theme)
                      : song.isNetwork
                      ? Image.network(
                          song.imagePath,
                          width: 53,
                          height: 53,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : _SongArtworkFallback(theme: theme),
                          errorBuilder: (context, error, stackTrace) =>
                              _SongArtworkFallback(theme: theme),
                        )
                      : Image.asset(
                          song.imagePath,
                          width: 53,
                          height: 53,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _SongArtworkFallback(theme: theme),
                        ),
                ),

                const SizedBox(width: 11),

                // ==================================================
                // SONG DETAILS
                // ==================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        song.title,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: isCurrent
                              ? theme.colorScheme.primary
                              : textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        song.artist,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.60),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        song.album,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.40),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      _TrackTypeBadge(song: song),
                    ],
                  ),
                ),

                // ==================================================
                // LIKE
                // ==================================================
                IconButton(
                  visualDensity: VisualDensity.compact,

                  onPressed: () async {
                    await player.toggleLikeSong(song);
                  },

                  icon: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,

                    color: isLiked
                        ? theme.colorScheme.primary
                        : textColor.withValues(alpha: 0.48),

                    size: 19,
                  ),
                ),

                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onMore,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: textColor.withValues(alpha: 0.55),
                    size: 20,
                  ),
                ),

                // ==================================================
                // PLAY BUTTON
                // ==================================================
                Container(
                  width: 36,
                  height: 36,

                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),

                    shape: BoxShape.circle,
                  ),

                  child: IconButton(
                    padding: EdgeInsets.zero,

                    onPressed: onTap,

                    icon: Icon(
                      isCurrent && player.isPlaying
                          ? Icons.graphic_eq_rounded
                          : Icons.play_arrow_rounded,

                      color: theme.colorScheme.primary,

                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH LOADING
// ============================================================================

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 42),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFFA855F7),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Searching songs...',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SearchError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFFA855F7),
            size: 34,
          ),
          const SizedBox(height: 12),
          Text(
            'Could not load online songs',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.52),
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _InlineSearchWarning extends StatelessWidget {
  final VoidCallback onRetry;

  const _InlineSearchWarning({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA000).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFFFA000),
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Showing available local songs.',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SongArtworkFallback extends StatelessWidget {
  final ThemeData theme;

  const _SongArtworkFallback({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 53,
      height: 53,
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Icon(
        Icons.music_note_rounded,
        color: Color(0xFFA855F7),
        size: 24,
      ),
    );
  }
}

// ============================================================================
// NO SEARCH RESULTS
// ============================================================================

class _NoSearchResults extends StatelessWidget {
  final String query;

  const _NoSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color textColor = theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(top: 16),

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: theme.dividerColor),
      ),

      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,

            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),

              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.search_off_rounded,

              color: theme.colorScheme.primary,

              size: 30,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'No songs found',

            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'We couldn’t find anything for "$query".',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: textColor.withValues(alpha: 0.55),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Try another song, artist or category.',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: textColor.withValues(alpha: 0.40),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
