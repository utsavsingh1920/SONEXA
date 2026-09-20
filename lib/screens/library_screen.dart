import 'dart:async';

import 'package:flutter/material.dart';

import '../data/songs_data.dart';
import '../models/song_model.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';
import '../services/itunes_api_service.dart';
import '../services/jamendo_api_service.dart';

import 'playback_screen.dart';

class LibraryScreen extends StatefulWidget {
  final int? initialFilter;
  final int initialTab;
  final String? initialAlbum;
  final String? initialArtist;
  final bool showAllCollections;

  const LibraryScreen({
    super.key,
    this.initialFilter,
    this.initialTab = 0,
    this.initialAlbum,
    this.initialArtist,
    this.showAllCollections = false,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const Color purple = Color(0xFF9B6BFF);
  static const Color purpleDark = Color(0xFF5B21B6);

  int _selectedFilter = -1;
  int _selectedTab = 0;
  List<SongModel> _indianSongs = const <SongModel>[];
  List<SongModel> _fullSongs = const <SongModel>[];
  bool _isLoadingCatalogue = true;
  bool _initialCollectionOpened = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _selectedTab = widget.initialTab.clamp(0, 4);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCatalogue();
    });
  }

  Future<void> _loadCatalogue() async {
    try {
      final List<List<SongModel>> results = await Future.wait([
        ITunesApiService.instance.searchSongs('Bollywood hits', limit: 35),
        JamendoApiService.instance.getPopularTracks(limit: 35),
      ]);

      if (!mounted) return;
      setState(() {
        _indianSongs = results[0];
        _fullSongs = results[1];
        _isLoadingCatalogue = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openInitialCollectionIfNeeded();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCatalogue = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openInitialCollectionIfNeeded();
      });
    }
  }

  Future<void> _openInitialCollectionIfNeeded() async {
    if (!mounted || _initialCollectionOpened) return;

    final String albumName = widget.initialAlbum?.trim() ?? '';
    final String artistName = widget.initialArtist?.trim() ?? '';
    if (albumName.isEmpty && artistName.isEmpty) return;

    _initialCollectionOpened = true;
    final PlayerController player = PlayerScope.of(context);

    if (albumName.isNotEmpty) {
      final List<SongModel> songs = await _loadAlbumSongs(albumName);
      if (mounted) _showAlbumSongs(context, player, albumName, songs);
      return;
    }

    final List<SongModel> songs = await _loadArtistSongs(artistName);
    if (mounted) _showArtistSongs(context, player, artistName, songs);
  }

  Future<List<SongModel>> _loadAlbumSongs(String albumName) async {
    final String normalized = albumName.trim().toLowerCase();
    final List<SongModel> songs = _catalogue.where((SongModel song) {
      return song.album.trim().toLowerCase() == normalized;
    }).toList();

    if (songs.length < 3) {
      try {
        final List<SongModel> fetched = await ITunesApiService.instance
            .searchSongs(albumName, limit: 30);
        songs.addAll(
          fetched.where((SongModel song) {
            final String album = song.album.trim().toLowerCase();
            return album == normalized ||
                album.contains(normalized) ||
                normalized.contains(album);
          }),
        );
      } catch (_) {}
    }

    return _uniqueCollection(songs);
  }

  Future<List<SongModel>> _loadArtistSongs(String artistName) async {
    final String normalized = artistName.trim().toLowerCase();
    final List<SongModel> songs = _catalogue.where((SongModel song) {
      return song.artist.trim().toLowerCase().contains(normalized);
    }).toList();

    if (songs.length < 3) {
      try {
        final List<SongModel> fetched = await ITunesApiService.instance
            .searchSongs(artistName, limit: 30);
        songs.addAll(
          fetched.where((SongModel song) {
            return song.artist.trim().toLowerCase().contains(normalized);
          }),
        );
      } catch (_) {}
    }

    return _uniqueCollection(songs);
  }

  List<SongModel> _uniqueCollection(Iterable<SongModel> songs) {
    final Set<String> keys = <String>{};
    return songs.where((SongModel song) {
      return keys.add('${song.source}:${song.id}');
    }).toList();
  }

  List<SongModel> get _catalogue {
    final List<SongModel> songs = <SongModel>[
      ..._indianSongs,
      ..._fullSongs,
      ...allSongs,
    ];
    final Set<String> keys = <String>{};

    return songs.where((song) {
      return keys.add('${song.source}:${song.id}');
    }).toList();
  }

  bool get _showingFilteredSongs => _selectedFilter >= 0;

  String get _filterTitle {
    switch (_selectedFilter) {
      case 0:
        return 'Liked Songs';
      case 1:
        return 'Recently Played';
      default:
        return 'Library';
    }
  }

  List<SongModel> _songsForFilter(PlayerController player) {
    switch (_selectedFilter) {
      case 0:
        return player.likedSongs;
      case 1:
        return player.recentlyPlayed;
      default:
        return _catalogue;
    }
  }

  // ============================================================
  // THEME COLORS
  // ============================================================

  Color _surface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color _text(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _muted(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _border(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  // ============================================================
  // OPEN PLAYBACK
  // ============================================================

  Future<void> _openPlayback(BuildContext context, SongModel song) async {
    if (!context.mounted) {
      return;
    }

    final PlayerController player = PlayerScope.read(context);
    player.setPlaybackSongs(_catalogue);

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaybackScreen(selectedSong: song)),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final PlayerController player = PlayerScope.of(context);

    final List<SongModel> filteredSongs = _songsForFilter(player);

    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ====================================================
            // FIXED HEADER
            // ====================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
              child: _buildHeader(context),
            ),

            // ====================================================
            // SCROLLABLE CONTENT
            // ====================================================
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ====================================================
                  // FILTERS
                  // ====================================================

                  if (!_showingFilteredSongs)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      sliver: SliverToBoxAdapter(child: _buildFilters(context)),
                    ),

                  // ====================================================
                  // PLAYLISTS
                  // ====================================================
                  if (!_showingFilteredSongs &&
                      (_selectedTab == 0 || _selectedTab == 4))
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildLibrarySummary(context, player),
                      ),
                    ),

                  if (!_showingFilteredSongs &&
                      (_selectedTab == 0 || _selectedTab == 4))
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 24, 10, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildPlaylistsSection(
                          context,
                          player,
                          vertical: _selectedTab == 4,
                        ),
                      ),
                    ),

                  // ====================================================
                  // ALBUMS
                  // ====================================================
                  if (!_showingFilteredSongs &&
                      (_selectedTab == 0 || _selectedTab == 2))
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 24, 10, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildAlbumsSection(
                          context,
                          player,
                          vertical: _selectedTab == 2,
                        ),
                      ),
                    ),

                  // ====================================================
                  // ARTISTS
                  // ====================================================
                  if (!_showingFilteredSongs &&
                      (_selectedTab == 0 || _selectedTab == 3))
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 24, 10, 0),
                      sliver: SliverToBoxAdapter(
                        child: _buildArtistsSection(
                          context,
                          player,
                          vertical: _selectedTab == 3,
                        ),
                      ),
                    ),

                  // ====================================================
                  // SONG HEADER
                  // ====================================================
                  if (!_showingFilteredSongs && _selectedTab == 1)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 26, 10, 12),
                      sliver: SliverToBoxAdapter(
                        child: _buildSongsHeader(context),
                      ),
                    ),

                  // ====================================================
                  // FILTERED SONG COUNT
                  // ====================================================
                  if (_showingFilteredSongs)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 24, 10, 12),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          '${filteredSongs.length} '
                          '${filteredSongs.length == 1 ? 'Song' : 'Songs'}',
                          style: TextStyle(
                            color: _muted(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // ====================================================
                  // SONG LIST
                  // ====================================================
                  if (_showingFilteredSongs || _selectedTab == 1)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      sliver: SliverToBoxAdapter(
                        child: _buildSongsList(context, player),
                      ),
                    ),

                  // ====================================================
                  // SPACE FOR MINI PLAYER + BOTTOM NAV
                  // ====================================================
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final bool showingFiltered = _showingFilteredSongs;

    return Row(
      children: [
        if (showingFiltered) ...[
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = -1;
              });
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border(context)),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: _text(context),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            showingFiltered ? _filterTitle : 'Library',
            style: TextStyle(
              color: _text(context),
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters(BuildContext context) {
    const List<String> labels = <String>[
      'All',
      'Songs',
      'Albums',
      'Artists',
      'Playlists',
    ];

    return Row(
      children: List<Widget>.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          return const SizedBox(width: 4);
        }

        final int tabIndex = index ~/ 2;
        final bool selected = _selectedTab == tabIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = tabIndex;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF9B6BFF), Color(0xFF6D32D1)],
                      )
                    : null,
                color: selected ? null : _surface(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? purple : _border(context)),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x443F1675),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                labels[tabIndex],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : _muted(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLibrarySummary(BuildContext context, PlayerController player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Quick Access',
                style: TextStyle(
                  color: _text(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'See All',
              style: TextStyle(
                color: purple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right_rounded, color: purple, size: 19),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                context,
                icon: Icons.favorite_rounded,
                title: 'Liked Songs',
                count: player.likedSongs.length,
                onTap: () => setState(() => _selectedFilter = 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                context,
                icon: Icons.history_rounded,
                title: 'Recently Played',
                count: player.recentlyPlayed.length,
                onTap: () => setState(() => _selectedFilter = 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF171126), Color(0xFF110D1B)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: purple.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: purple, size: 24),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count ${count == 1 ? 'song' : 'songs'}',
                    style: TextStyle(color: _muted(context), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _muted(context), size: 17),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLAYLISTS
  // ============================================================

  Widget _buildPlaylistsSection(
    BuildContext context,
    PlayerController player, {
    bool vertical = false,
  }) {
    final List<String> playlistNames = player.playlistNames;

    const List<String> sampleTitles = <String>[
      'Bollywood Essentials',
      'Chill Nights',
      'Full Track Mix',
    ];

    final int totalItems = sampleTitles.length + playlistNames.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Playlists',
                style: TextStyle(
                  color: _text(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showCreatePlaylistDialog(context, player);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: purple.withValues(alpha: 0.20)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_rounded, color: purple, size: 17),
                    SizedBox(width: 4),
                    Text(
                      'Create',
                      style: TextStyle(
                        color: purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!vertical)
          SizedBox(
            height: 154,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: totalItems,
              separatorBuilder: (_, _) => const SizedBox(width: 11),
              itemBuilder: (context, index) {
                if (index < sampleTitles.length) {
                  return _smartPlaylistCard(
                    context,
                    player,
                    sampleTitles[index],
                    index,
                  );
                }

                return _playlistCard(
                  context,
                  player,
                  playlistNames[index - sampleTitles.length],
                );
              },
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalItems,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  if (index < sampleTitles.length) {
                    return _smartPlaylistCard(
                      context,
                      player,
                      sampleTitles[index],
                      index,
                      width: double.infinity,
                    );
                  }

                  return _playlistCard(
                    context,
                    player,
                    playlistNames[index - sampleTitles.length],
                  );
                },
              ),
              if (playlistNames.isEmpty) ...[
                const SizedBox(height: 16),
                _emptyPlaylistCard(context),
              ],
            ],
          ),
      ],
    );
  }

  Widget _emptyPlaylistCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final PlayerController player = PlayerScope.of(context);

        _showCreatePlaylistDialog(context, player);
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border(context)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 18),
            const Icon(
              Icons.add_circle_outline_rounded,
              color: purple,
              size: 30,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your first playlist',
                    style: TextStyle(
                      color: _text(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize your favorite songs',
                    style: TextStyle(color: _muted(context), fontSize: 11),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.chevron_right_rounded,
                color: _muted(context),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PLAYLIST CARD
  // Purple play-circle removed.
  // Card tap only opens playlist songs.
  // ============================================================

  Widget _playlistCard(
    BuildContext context,
    PlayerController player,
    String playlistName,
  ) {
    final List<SongModel> playlistSongs = player.getPlaylistSongs(playlistName);

    final SongModel? coverSong = playlistSongs.isNotEmpty
        ? playlistSongs.first
        : null;

    return GestureDetector(
      onTap: () {
        _showPlaylistSongs(context, player, playlistName);
      },
      child: Container(
        width: 126,
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: coverSong != null
                        ? _libraryImage(
                            coverSong.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) {
                              return _playlistPlaceholder();
                            },
                          )
                        : _playlistPlaceholder(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.68),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 7, 8, 9),
              child: Text(
                playlistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smartPlaylistCard(
    BuildContext context,
    PlayerController player,
    String title,
    int index, {
    double width = 104,
  }) {
    final List<SongModel> songs = _smartPlaylistSongs(index);
    final SongModel? cover = songs.isEmpty ? null : songs.first;

    return GestureDetector(
      onTap: () {
        _showSongListBottomSheet(
          context,
          title: title,
          subtitle: '${songs.length} songs',
          songs: songs,
          player: player,
        );
      },
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: cover == null
                    ? _playlistPlaceholder()
                    : _libraryImage(
                        cover.imagePath,
                        width: width,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _playlistPlaceholder(),
                      ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text(context),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'SONEXA Mix',
              style: TextStyle(color: _muted(context), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  List<SongModel> _smartPlaylistSongs(int index) {
    if (_catalogue.isEmpty) return const <SongModel>[];

    const List<List<String>> keywords = <List<String>>[
      <String>['bollywood', 'hindi', 'india'],
      <String>['chill', 'lo-fi', 'acoustic'],
      <String>['jamendo', 'audius', 'full'],
    ];

    final List<String> selected = keywords[index];
    if (selected.isEmpty) return _catalogue.take(20).toList();

    final List<SongModel> matches = _catalogue
        .where((song) {
          final String text = <String>[
            song.title,
            song.album,
            song.artist,
            song.source,
            ...song.tags,
          ].join(' ').toLowerCase();
          return selected.any(text.contains);
        })
        .take(20)
        .toList();

    return matches.isEmpty ? _catalogue.take(20).toList() : matches;
  }

  Widget _playlistPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9B6BFF), Color(0xFF401080)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.queue_music_rounded, color: Colors.white, size: 34),
      ),
    );
  }

  // ============================================================
  // CREATE PLAYLIST
  // ============================================================

  void _showCreatePlaylistDialog(
    BuildContext context,
    PlayerController player,
  ) {
    final TextEditingController controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final ThemeData theme = Theme.of(dialogContext);

        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Create Playlist',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: theme.colorScheme.onSurface),
            cursorColor: purple,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: theme.colorScheme.surface,
              prefixIcon: const Icon(Icons.queue_music_rounded, color: purple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: purple.withValues(alpha: 0.5)),
              ),
            ),
            onSubmitted: (_) {
              _createPlaylist(dialogContext, player, controller.text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _createPlaylist(dialogContext, player, controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _createPlaylist(
    BuildContext dialogContext,
    PlayerController player,
    String name,
  ) {
    final String playlistName = name.trim();

    if (playlistName.isEmpty) {
      return;
    }

    // Prevent duplicate playlist names.
    if (player.playlistNames.any(
      (existing) => existing.trim().toLowerCase() == playlistName.toLowerCase(),
    )) {
      Navigator.of(dialogContext).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"$playlistName" already exists',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: purpleDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    player.createPlaylist(playlistName);

    Navigator.of(dialogContext).pop();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"$playlistName" playlist created',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: purpleDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // ADD SONGS TO PLAYLIST
  // ============================================================

  void _showAddSongsToPlaylist(
    BuildContext context,
    PlayerController player,
    String playlistName,
  ) {
    final List<SongModel> playlistSongs = player.getPlaylistSongs(playlistName);

    final Set<String> existingIds = playlistSongs
        .map((song) => song.id)
        .toSet();

    final List<SongModel> availableSongs = _catalogue
        .where((song) => !existingIds.contains(song.id))
        .toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.78,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Songs',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose songs for your playlist',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: availableSongs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'All songs are already in this playlist',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 25),
                          physics: const BouncingScrollPhysics(),
                          itemCount: availableSongs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final SongModel song = availableSongs[index];

                            return GestureDetector(
                              onTap: () {
                                player.addSongToPlaylist(playlistName, song);

                                Navigator.of(sheetContext).pop();

                                _showPlaylistSongs(
                                  this.context,
                                  player,
                                  playlistName,
                                );

                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: _surface(context),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _border(context)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _libraryImage(
                                        song.imagePath,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color: purpleDark,
                                            child: const Icon(
                                              Icons.music_note_rounded,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: _text(context),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            song.artist,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: _muted(context),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: purple.withValues(alpha: 0.13),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_rounded,
                                        color: purple,
                                        size: 19,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ALBUMS
  // ============================================================

  Widget _buildAlbumsSection(
    BuildContext context,
    PlayerController player, {
    bool vertical = false,
  }) {
    final Map<String, SongModel> catalogueAlbums = <String, SongModel>{};

    for (final SongModel song in _catalogue) {
      if (song.album.trim().isNotEmpty) {
        catalogueAlbums.putIfAbsent(song.album.trim(), () => song);
      }
    }

    final List<SongModel> sampleAlbums = catalogueAlbums.values
        .take(4)
        .toList();

    final List<SongModel> savedAlbums = player.savedAlbumNames
        .map((String name) => player.getSavedAlbumSongs(name))
        .where((List<SongModel> songs) => songs.isNotEmpty)
        .map((List<SongModel> songs) => songs.first)
        .toList();

    final List<SongModel> albumSongs = vertical
        ? (widget.showAllCollections
              ? catalogueAlbums.values.toList()
              : savedAlbums)
        : sampleAlbums;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          'Albums',
          vertical
              ? widget.showAllCollections
                    ? '${albumSongs.length} albums'
                    : '${albumSongs.length} saved'
              : '${albumSongs.length} samples',
        ),
        const SizedBox(height: 11),
        if (vertical && albumSongs.isEmpty)
          _emptySavedCollection(
            context,
            icon: Icons.album_outlined,
            title: 'No saved albums yet',
            message: 'Open a sample album and tap the save icon.',
          )
        else if (!vertical)
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: albumSongs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 11),
              itemBuilder: (context, index) {
                final SongModel song = albumSongs[index];

                return GestureDetector(
                  onTap: () async {
                    final List<SongModel> songs = await _loadAlbumSongs(
                      song.album,
                    );
                    if (!context.mounted) return;
                    _showAlbumSongs(context, player, song.album, songs);
                  },
                  child: SizedBox(
                    width: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: _libraryImage(
                              song.imagePath,
                              width: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Container(
                                  color: _surface(context),
                                  child: const Icon(
                                    Icons.album_rounded,
                                    color: purple,
                                    size: 36,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          song.album,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _text(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: albumSongs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final SongModel song = albumSongs[index];
              final List<SongModel> songs = widget.showAllCollections
                  ? const <SongModel>[]
                  : player.getSavedAlbumSongs(song.album);
              return _albumGridCard(context, player, song, songs);
            },
          ),
      ],
    );
  }

  Widget _albumGridCard(
    BuildContext context,
    PlayerController player,
    SongModel song,
    List<SongModel> songs,
  ) {
    return GestureDetector(
      onTap: () async {
        final List<SongModel> collection = songs.isNotEmpty
            ? songs
            : await _loadAlbumSongs(song.album);
        if (!context.mounted) return;
        _showAlbumSongs(context, player, song.album, collection);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _libraryImage(
                song.imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: _surface(context),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.album_rounded,
                    color: purple,
                    size: 44,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.album,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _muted(context), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _emptySavedCollection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: purple, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text(context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted(context), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ARTISTS
  // ============================================================

  Widget _buildArtistsSection(
    BuildContext context,
    PlayerController player, {
    bool vertical = false,
  }) {
    final Map<String, SongModel> uniqueArtists = <String, SongModel>{};
    for (final SongModel song in _catalogue) {
      if (song.artist.trim().isNotEmpty) {
        uniqueArtists.putIfAbsent(song.artist.trim(), () => song);
      }
    }

    const List<List<Color>> palettes = <List<Color>>[
      <Color>[Color(0xFF8B5CF6), Color(0xFF4C1D95)],
      <Color>[Color(0xFFFF4B2B), Color(0xFFB31217)],
      <Color>[Color(0xFF0F9BA8), Color(0xFF075985)],
      <Color>[Color(0xFF64748B), Color(0xFF1E293B)],
    ];

    final List<_ArtistData> artists = <_ArtistData>[];
    final List<MapEntry<String, SongModel>> entries =
        <MapEntry<String, SongModel>>[];

    if (vertical && !widget.showAllCollections) {
      for (final String name in player.savedArtistNames) {
        final List<SongModel> songs = player.getSavedArtistSongs(name);
        if (songs.isNotEmpty) {
          entries.add(MapEntry<String, SongModel>(name, songs.first));
        }
      }
    } else {
      entries.addAll(
        vertical ? uniqueArtists.entries : uniqueArtists.entries.take(4),
      );
    }

    for (int index = 0; index < entries.length; index++) {
      artists.add(
        _ArtistData(
          name: entries[index].key,
          imagePath: _artistPhotoFor(
            entries[index].key,
            entries[index].value.imagePath,
          ),
          colors: palettes[index % palettes.length],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          'Artists',
          vertical
              ? widget.showAllCollections
                    ? '${artists.length} artists'
                    : '${artists.length} saved'
              : '${artists.length} samples',
        ),
        const SizedBox(height: 11),
        if (vertical && artists.isEmpty)
          _emptySavedCollection(
            context,
            icon: Icons.person_outline_rounded,
            title: 'No saved artists yet',
            message: 'Open a sample artist and tap the save icon.',
          )
        else if (!vertical)
          SizedBox(
            height: 113,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: artists.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final _ArtistData artist = artists[index];

                return GestureDetector(
                  onTap: () async {
                    final List<SongModel> songs = await _loadArtistSongs(
                      artist.name,
                    );
                    if (!context.mounted) return;
                    _showArtistSongs(context, player, artist.name, songs);
                  },
                  child: SizedBox(
                    width: 78,
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: artist.colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: artist.colors.first.withValues(
                                  alpha: 0.20,
                                ),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipOval(
                            child: _libraryImage(
                              artist.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Container(
                                  decoration: BoxDecoration(
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
                        const SizedBox(height: 7),
                        Text(
                          artist.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _text(context),
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
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: artists.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 18,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) => _artistGridCard(
              context,
              player,
              artists[index],
              widget.showAllCollections
                  ? const <SongModel>[]
                  : player.getSavedArtistSongs(artists[index].name),
            ),
          ),
      ],
    );
  }

  String _artistPhotoFor(String artistName, String fallback) {
    final String name = artistName.trim().toLowerCase();

    if (name.contains('arijit singh')) {
      return 'assets/images/artists/arijit_singh.jpg';
    }
    if (name.contains('rahat fateh ali khan')) {
      return 'assets/images/artists/rahat_fateh_ali_khan.jpg';
    }
    if (name.contains('mohit chauhan')) {
      return 'assets/images/artists/mohit_chauhan.jpg';
    }
    if (name.contains('atif aslam')) {
      return 'assets/images/artists/atif_aslam.jpg';
    }
    if (name.contains('javed bashir')) {
      return 'assets/images/artists/javed_bashir.jpg';
    }

    return fallback;
  }

  Widget _artistGridCard(
    BuildContext context,
    PlayerController player,
    _ArtistData artist,
    List<SongModel> songs,
  ) {
    return GestureDetector(
      onTap: () async {
        final List<SongModel> collection = songs.isNotEmpty
            ? songs
            : await _loadArtistSongs(artist.name);
        if (!context.mounted) return;
        _showArtistSongs(context, player, artist.name, collection);
      },
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: artist.colors),
                  boxShadow: [
                    BoxShadow(
                      color: artist.colors.first.withValues(alpha: 0.22),
                      blurRadius: 12,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: _libraryImage(
                    artist.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: artist.colors),
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
            ),
          ),
          const SizedBox(height: 7),
          Text(
            artist.name,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text(context),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ARTIST SONGS
  // ============================================================

  void _showArtistSongs(
    BuildContext context,
    PlayerController player,
    String artistName,
    List<SongModel> songs,
  ) {
    _showSongListBottomSheet(
      context,
      title: artistName,
      subtitle: '${songs.length} songs',
      songs: songs,
      player: player,
      collectionSaved: player.isArtistSaved(artistName),
      onCollectionAction: () async {
        if (player.isArtistSaved(artistName)) {
          await player.removeSavedArtist(artistName);
        } else {
          await player.saveArtist(artistName, songs);
        }
        if (mounted) setState(() {});
      },
    );
  }

  // ============================================================
  // SONG HEADER
  // ============================================================

  Widget _buildSongsHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'All Songs',
            style: TextStyle(
              color: _text(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          _isLoadingCatalogue ? 'Loading songs…' : '${_catalogue.length} songs',
          style: TextStyle(
            color: _muted(context),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SONG LIST
  // ============================================================

  Widget _buildSongsList(BuildContext context, PlayerController player) {
    final List<SongModel> songs = _songsForFilter(player);

    if (songs.isEmpty) {
      return _emptySongsState(context);
    }

    return Column(
      children: List.generate(songs.length, (index) {
        final SongModel song = songs[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _songRow(context, player, song, index),
        );
      }),
    );
  }

  Widget _songRow(
    BuildContext context,
    PlayerController player,
    SongModel song,
    int index,
  ) {
    final bool isCurrent = player.currentSongData.id == song.id;

    final bool isLiked = player.isSongLiked(song);

    return GestureDetector(
      onTap: () async {
        await _openPlayback(context, song);
      },
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isCurrent ? purple.withValues(alpha: 0.10) : _surface(context),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isCurrent
                ? purple.withValues(alpha: 0.22)
                : _border(context),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: isCurrent && player.isPlaying
                  ? const Icon(Icons.equalizer_rounded, color: purple, size: 19)
                  : Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _libraryImage(
                song.imagePath,
                width: 49,
                height: 49,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    width: 49,
                    height: 49,
                    color: purpleDark,
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent ? purple : _text(context),
                      fontSize: 13,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _muted(context), fontSize: 10),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await player.toggleLikeSong(song);

                if (mounted) {
                  setState(() {});
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isLiked ? purple : _muted(context),
                  size: 20,
                ),
              ),
            ),
            Icon(Icons.more_vert_rounded, color: _muted(context), size: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptySongsState(BuildContext context) {
    final bool liked = _selectedFilter == 0;

    final bool recent = _selectedFilter == 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 25),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              liked
                  ? Icons.favorite_border_rounded
                  : recent
                  ? Icons.history_rounded
                  : Icons.music_note_rounded,
              color: purple,
              size: 28,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            liked
                ? 'No liked songs yet'
                : recent
                ? 'Nothing played recently'
                : 'No songs available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your songs will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted(context), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _libraryImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    final String cleanPath = path.trim();

    Widget fallback(BuildContext context, Object error, StackTrace? stack) {
      if (errorBuilder != null) {
        return errorBuilder(context, error, stack);
      }

      return Container(
        width: width,
        height: height,
        color: purpleDark,
        alignment: Alignment.center,
        child: const Icon(Icons.music_note_rounded, color: Colors.white),
      );
    }

    if (cleanPath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: purpleDark,
        alignment: Alignment.center,
        child: const Icon(Icons.music_note_rounded, color: Colors.white),
      );
    }

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      final String url = cleanPath.startsWith('http://')
          ? cleanPath.replaceFirst('http://', 'https://')
          : cleanPath;

      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        headers: const <String, String>{
          'Accept': 'image/*',
          'User-Agent': 'SONEXA/1.0 (Android; Flutter)',
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: purpleDark.withValues(alpha: 0.35),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: purple),
            ),
          );
        },
        errorBuilder: fallback,
      );
    }

    return Image.asset(
      cleanPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: fallback,
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(BuildContext context, String title, String trailing) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _text(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            color: _muted(context),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PLAYLIST SONGS
  // ============================================================

  void _showPlaylistSongs(
    BuildContext context,
    PlayerController player,
    String playlistName,
  ) {
    final List<SongModel> songs = player.getPlaylistSongs(playlistName);

    _showSongListBottomSheet(
      context,
      title: playlistName,
      subtitle: '${songs.length} songs',
      songs: songs,
      player: player,
      playlistName: playlistName,
    );
  }

  // ============================================================
  // ALBUM SONGS
  // ============================================================

  void _showAlbumSongs(
    BuildContext context,
    PlayerController player,
    String albumName,
    List<SongModel> songs,
  ) {
    _showSongListBottomSheet(
      context,
      title: albumName,
      subtitle: '${songs.length} songs',
      songs: songs,
      player: player,
      collectionSaved: player.isAlbumSaved(albumName),
      onCollectionAction: () async {
        if (player.isAlbumSaved(albumName)) {
          await player.removeSavedAlbum(albumName);
        } else {
          await player.saveAlbum(albumName, songs);
        }
        if (mounted) setState(() {});
      },
    );
  }

  // ============================================================
  // BOTTOM SHEET
  // ============================================================

  void _showSongListBottomSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<SongModel> songs,
    required PlayerController player,
    String? playlistName,
    bool collectionSaved = false,
    Future<void> Function()? onCollectionAction,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);

        final Color textColor = theme.colorScheme.onSurface;

        final Color mutedColor = theme.colorScheme.onSurfaceVariant;

        final Color surfaceColor = theme.colorScheme.surface;

        final Color borderColor = theme.dividerColor;

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 10, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(color: mutedColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      if (onCollectionAction != null)
                        IconButton(
                          tooltip: collectionSaved
                              ? 'Remove from Library'
                              : 'Save to Library',
                          onPressed: () async {
                            await onCollectionAction();
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          icon: Icon(
                            collectionSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: purple,
                          ),
                        ),

                      // Add songs button only
                      // for actual playlists.
                      if (playlistName != null)
                        IconButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();

                            _showAddSongsToPlaylist(
                              context,
                              player,
                              playlistName,
                            );
                          },
                          icon: const Icon(Icons.add_rounded, color: purple),
                        ),

                      IconButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                        },
                        icon: Icon(Icons.close_rounded, color: textColor),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: songs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_off_rounded,
                                color: mutedColor,
                                size: 34,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                playlistName != null
                                    ? 'No songs in this playlist'
                                    : 'No songs in this collection',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 13,
                                ),
                              ),
                              if (playlistName != null) ...[
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();

                                    _showAddSongsToPlaylist(
                                      context,
                                      player,
                                      playlistName,
                                    );
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 17),
                                  label: const Text('Add Songs'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: purple,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 25),
                          physics: const BouncingScrollPhysics(),
                          itemCount: songs.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final SongModel song = songs[index];

                            final bool liked = player.isSongLiked(song);

                            return GestureDetector(
                              onTap: () async {
                                Navigator.of(sheetContext).pop();

                                if (!this.context.mounted) {
                                  return;
                                }

                                // Exact selected
                                // song opens in
                                // PlaybackScreen.
                                await _openPlayback(this.context, song);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _libraryImage(
                                        song.imagePath,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color: purpleDark,
                                            child: const Icon(
                                              Icons.music_note_rounded,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            song.artist,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: mutedColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // LIKE
                                    IconButton(
                                      onPressed: () async {
                                        await player.toggleLikeSong(song);

                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                      icon: Icon(
                                        liked
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        color: liked ? purple : mutedColor,
                                        size: 20,
                                      ),
                                    ),

                                    // REMOVE FROM
                                    // PLAYLIST
                                    if (playlistName != null)
                                      IconButton(
                                        onPressed: () {
                                          player.removeSongFromPlaylist(
                                            playlistName,
                                            song,
                                          );

                                          Navigator.of(sheetContext).pop();

                                          _showPlaylistSongs(
                                            context,
                                            player,
                                            playlistName,
                                          );

                                          setState(() {});
                                        },
                                        icon: Icon(
                                          Icons.remove_circle_outline_rounded,
                                          color: mutedColor,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// ARTIST MODEL
// ================================================================

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
