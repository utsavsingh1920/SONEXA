import 'dart:async';

import 'package:flutter/material.dart';

import '../data/songs_data.dart';
import '../models/song_model.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';
import '../services/audius_api_service.dart';
import '../services/itunes_api_service.dart';
import '../services/jamendo_api_service.dart';
import 'playback_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  static const Color _background = Color(0xFF0B0712);
  static const Color _surface = Color(0xFF15101F);
  static const Color _border = Color(0xFF2A2235);
  static const Color _purple = Color(0xFF9B5CFF);
  static const Color _purpleLight = Color(0xFFB77CFF);
  static const Color _muted = Color(0xFFA8A0B3);
  static const Color _mutedDark = Color(0xFF70677C);

  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _loadError;
  List<SongModel> _apiSongs = const <SongModel>[];

  static const List<String> _filters = <String>[
    'All',
    'Recently Played',
    'Favorites',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCatalogue());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalogue() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    final List<SongModel> loaded = <SongModel>[];
    int failedSources = 0;

    try {
      loaded.addAll(
        await ITunesApiService.instance.searchSongs(
          'Bollywood hits',
          limit: 35,
        ),
      );
    } catch (_) {
      failedSources++;
    }

    try {
      loaded.addAll(
        await JamendoApiService.instance.getPopularTracks(limit: 35),
      );
    } catch (_) {
      failedSources++;
    }

    try {
      loaded.addAll(
        await AudiusApiService.instance.getTrendingTracks(limit: 25),
      );
    } catch (_) {
      failedSources++;
    }

    if (!mounted) return;

    setState(() {
      _apiSongs = _uniqueSongs(loaded);
      _isLoading = false;
      _loadError = failedSources == 3
          ? 'Online songs could not be loaded. Local songs are still available.'
          : null;
    });
  }

  List<SongModel> _uniqueSongs(Iterable<SongModel> songs) {
    final Set<String> keys = <String>{};
    return songs.where((SongModel song) {
      return song.hasValidAudio && keys.add('${song.source}:${song.id}');
    }).toList();
  }

  List<SongModel> get _catalogue {
    return _uniqueSongs(<SongModel>[...allSongs, ..._apiSongs]);
  }

  List<SongModel> _visibleSongs(PlayerController player) {
    List<SongModel> songs;

    if (_selectedFilter == 1) {
      songs = List<SongModel>.from(player.recentlyPlayed);
    } else if (_selectedFilter == 2) {
      songs = List<SongModel>.from(player.likedSongs);
    } else {
      songs = _catalogue;
    }

    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return songs;

    return songs.where((SongModel song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openSong(
    BuildContext context,
    PlayerController player,
    SongModel song,
    List<SongModel> playbackSongs,
  ) async {
    player.setPlaybackSongs(playbackSongs);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlaybackScreen(selectedSong: song),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController player = PlayerScope.of(context);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        final List<SongModel> visibleSongs = _visibleSongs(player);

        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: RefreshIndicator(
              color: _purple,
              backgroundColor: _surface,
              onRefresh: _loadCatalogue,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 150),
                children: <Widget>[
                  _buildHeader(context, player, visibleSongs),
                  const SizedBox(height: 22),
                  _buildSearch(),
                  const SizedBox(height: 18),
                  _buildFilters(),
                  const SizedBox(height: 22),
                  _buildSectionHeader(visibleSongs.length),
                  if (_isLoading && _apiSongs.isEmpty) ...<Widget>[
                    const SizedBox(height: 18),
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: _purple,
                      backgroundColor: _surface,
                    ),
                  ],
                  if (_loadError != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _buildWarning(),
                  ],
                  const SizedBox(height: 12),
                  if (visibleSongs.isEmpty && !_isLoading)
                    _buildEmptyState()
                  else
                    ...List<Widget>.generate(visibleSongs.length, (int index) {
                      final SongModel song = visibleSongs[index];
                      final bool isCurrent =
                          player.currentSongData.id == song.id &&
                          player.currentSongData.source == song.source;

                      return _SongItem(
                        index: index,
                        song: song,
                        isCurrent: isCurrent,
                        isPlaying: isCurrent && player.isPlaying,
                        isLiked: player.isSongLiked(song),
                        onTap: () =>
                            _openSong(context, player, song, visibleSongs),
                        onLike: () => player.toggleLikeSong(song),
                        onMore: () => _showSongActions(
                          context,
                          player,
                          song,
                          visibleSongs,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PlayerController player,
    List<SongModel> visibleSongs,
  ) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your Music',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Songs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _topButton(
          icon: Icons.shuffle_rounded,
          onTap: () {
            if (visibleSongs.isEmpty) return;
            final int index =
                DateTime.now().microsecondsSinceEpoch % visibleSongs.length;
            _openSong(context, player, visibleSongs[index], visibleSongs);
          },
        ),
        const SizedBox(width: 8),
        _topButton(icon: Icons.refresh_rounded, onTap: _loadCatalogue),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (String value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        cursorColor: _purpleLight,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _mutedDark,
            size: 21,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _mutedDark,
                    size: 20,
                  ),
                ),
          hintText: 'Search in your songs...',
          hintStyle: const TextStyle(color: _mutedDark, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final bool selected = _selectedFilter == index;
          return InkWell(
            onTap: () => setState(() => _selectedFilter = index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _purple : _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _purple : _border),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            _selectedFilter == 0 ? 'All Songs' : _filters[_selectedFilter],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$count ${count == 1 ? 'song' : 'songs'}',
          style: const TextStyle(color: _mutedDark, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF261B19),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF5D3B27)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFFFFA45B),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _loadError!,
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          ),
          TextButton(onPressed: _loadCatalogue, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool favorites = _selectedFilter == 2;
    final bool recent = _selectedFilter == 1;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            favorites
                ? Icons.favorite_border_rounded
                : recent
                ? Icons.history_rounded
                : Icons.music_off_rounded,
            color: _mutedDark,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            favorites
                ? 'No favorite songs'
                : recent
                ? 'No recently played songs'
                : 'No songs found',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            favorites
                ? 'Songs you like will appear here.'
                : recent
                ? 'Songs you play will appear here.'
                : 'Try another search or pull down to refresh.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _mutedDark, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _topButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF20182D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Icon(icon, color: _purpleLight, size: 20),
        ),
      ),
    );
  }

  void _showSongActions(
    BuildContext context,
    PlayerController player,
    SongModel song,
    List<SongModel> playbackSongs,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  player.isSongLiked(song)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _purpleLight,
                ),
                title: Text(
                  player.isSongLiked(song)
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await player.toggleLikeSong(song);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.queue_music_rounded,
                  color: _purpleLight,
                ),
                title: const Text(
                  'Add to Queue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  player.addToQueue(song);
                  Navigator.pop(sheetContext);
                  _message(context, '${song.title} added to queue');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.playlist_add_rounded,
                  color: _purpleLight,
                ),
                title: const Text(
                  'Add to Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _choosePlaylist(context, player, song);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.play_arrow_rounded,
                  color: _purpleLight,
                ),
                title: const Text(
                  'Play from here',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openSong(context, player, song, playbackSongs);
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
      _message(context, 'Create a playlist from Library first');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              title: Text(
                'Choose playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ...player.playlistNames.map(
              (String name) => ListTile(
                leading: const Icon(
                  Icons.queue_music_rounded,
                  color: _purpleLight,
                ),
                title: Text(name, style: const TextStyle(color: Colors.white)),
                trailing: player.playlistContainsSong(name, song)
                    ? const Icon(Icons.check_rounded, color: _purpleLight)
                    : const Icon(Icons.add_rounded, color: _purpleLight),
                onTap: () async {
                  await player.addSongToPlaylist(name, song);
                  if (!sheetContext.mounted) return;
                  Navigator.pop(sheetContext);
                  _message(context, 'Added to $name');
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _message(BuildContext context, String message) {
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
}

class _SongItem extends StatelessWidget {
  const _SongItem({
    required this.index,
    required this.song,
    required this.isCurrent,
    required this.isPlaying,
    required this.isLiked,
    required this.onTap,
    required this.onLike,
    required this.onMore,
  });

  final int index;
  final SongModel song;
  final bool isCurrent;
  final bool isPlaying;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFF21172E) : _SongsScreenState._surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isCurrent ? const Color(0xFF5A397A) : const Color(0xFF211A2B),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 22,
                  child: isPlaying
                      ? const Icon(
                          Icons.graphic_eq_rounded,
                          color: _SongsScreenState._purpleLight,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isCurrent
                                ? _SongsScreenState._purpleLight
                                : _SongsScreenState._mutedDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(width: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _SongArtwork(path: song.imagePath),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isCurrent
                              ? _SongsScreenState._purpleLight
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _SongsScreenState._muted,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _SourceBadge(song: song),
                    ],
                  ),
                ),
                Text(
                  song.formattedDuration,
                  style: const TextStyle(
                    color: _SongsScreenState._mutedDark,
                    fontSize: 9.5,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onLike,
                  icon: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isLiked
                        ? _SongsScreenState._purpleLight
                        : _SongsScreenState._mutedDark,
                    size: 18,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onMore,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: _SongsScreenState._mutedDark,
                    size: 20,
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

class _SongArtwork extends StatelessWidget {
  const _SongArtwork({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFB77CFF), Color(0xFF7138C8)],
        ),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.white),
    );

    if (path.trim().isEmpty) return fallback();

    if (path.startsWith('http://') || path.startsWith('https://')) {
      final String safeUrl = path.startsWith('http://')
          ? path.replaceFirst('http://', 'https://')
          : path;
      return Image.network(
        safeUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback(),
        loadingBuilder: (_, Widget child, ImageChunkEvent? progress) {
          return progress == null ? child : fallback();
        },
      );
    }

    return Image.asset(
      path,
      width: 52,
      height: 52,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback(),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    final bool preview = song.isPreview;
    final Color color = preview
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Text(
          preview ? 'PREVIEW' : 'FULL TRACK',
          style: TextStyle(
            color: color,
            fontSize: 7,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
