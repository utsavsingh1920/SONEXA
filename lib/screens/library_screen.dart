import 'package:flutter/material.dart';

import '../data/songs_data.dart';
import '../models/song_model.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';

import 'playback_screen.dart';

class LibraryScreen extends StatefulWidget {
  final int? initialFilter;

  const LibraryScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const Color purple = Color(0xFF9B6BFF);
  static const Color purpleDark = Color(0xFF5B21B6);

  int _selectedFilter = -1;

  @override
  void initState() {
    super.initState();

    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
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

  List<SongModel> _songsForFilter(
    PlayerController player,
  ) {
    switch (_selectedFilter) {
      case 0:
        return player.likedSongs;
      case 1:
        return player.recentlyPlayed;
      default:
        return allSongs;
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

  Future<void> _openPlayback(
    BuildContext context,
    SongModel song,
  ) async {
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaybackScreen(
          selectedSong: song,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final PlayerController player = PlayerScope.of(context);

    final List<SongModel> filteredSongs =
        _songsForFilter(player);

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
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                0,
              ),
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
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildFilters(
                    context,
                    player,
                  ),
                ),
              ),

            // ====================================================
            // PLAYLISTS
            // ====================================================

            if (!_showingFilteredSongs)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildPlaylistsSection(
                    context,
                    player,
                  ),
                ),
              ),

            // ====================================================
            // ALBUMS
            // ====================================================

            if (!_showingFilteredSongs)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildAlbumsSection(
                    context,
                  ),
                ),
              ),

            // ====================================================
            // ARTISTS
            // ====================================================

            if (!_showingFilteredSongs)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildArtistsSection(
                    context,
                  ),
                ),
              ),

            // ====================================================
            // SONG HEADER
            // ====================================================

            if (!_showingFilteredSongs)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  26,
                  16,
                  12,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSongsHeader(
                    context,
                  ),
                ),
              ),

            // ====================================================
            // FILTERED SONG COUNT
            // ====================================================

            if (_showingFilteredSongs)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  12,
                ),
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

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildSongsList(
                  context,
                  player,
                ),
              ),
            ),

            // ====================================================
            // SPACE FOR MINI PLAYER + BOTTOM NAV
            // ====================================================

            const SliverToBoxAdapter(
              child: SizedBox(height: 140),
            ),
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
    final bool showingFiltered =
        _showingFilteredSongs;

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
                border: Border.all(
                  color: _border(context),
                ),
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
            showingFiltered
                ? _filterTitle
                : 'Library',
            style: TextStyle(
              color: _text(context),
              fontSize: 28,
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

  Widget _buildFilters(
    BuildContext context,
    PlayerController player,
  ) {
    return Row(
      children: [
        Expanded(
          child: _filterCard(
            context: context,
            title: 'Liked',
            subtitle:
                '${player.likedSongsCount} songs',
            icon: Icons.favorite_rounded,
            onTap: () {
              setState(() {
                _selectedFilter = 0;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _filterCard(
            context: context,
            title: 'Recently',
            subtitle:
                '${player.recentlyPlayedCount} songs',
            icon: Icons.history_rounded,
            onTap: () {
              setState(() {
                _selectedFilter = 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _filterCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 82,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              purple.withValues(alpha: 0.18),
              purpleDark.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: purple.withValues(alpha: 0.13),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _muted(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
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
    PlayerController player,
  ) {
    final List<String> playlistNames =
        player.playlistNames;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
                _showCreatePlaylistDialog(
                  context,
                  player,
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                      purple.withValues(alpha: 0.14),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        purple.withValues(alpha: 0.20),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: purple,
                      size: 17,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Create',
                      style: TextStyle(
                        color: purple,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (playlistNames.isEmpty)
          _emptyPlaylistCard(context)
        else
          SizedBox(
            height: 138,
            child: ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              physics:
                  const BouncingScrollPhysics(),
              itemCount:
                  playlistNames.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 11),
              itemBuilder:
                  (context, index) {
                return _playlistCard(
                  context,
                  player,
                  playlistNames[index],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _emptyPlaylistCard(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        final PlayerController player =
            PlayerScope.of(context);

        _showCreatePlaylistDialog(
          context,
          player,
        );
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: _border(context),
          ),
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
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create your first playlist',
                    style: TextStyle(
                      color: _text(context),
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organize your favorite songs',
                    style: TextStyle(
                      color: _muted(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(right: 16),
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
    final List<SongModel> playlistSongs =
        player.getPlaylistSongs(
      playlistName,
    );

    final SongModel? coverSong =
        playlistSongs.isNotEmpty
            ? playlistSongs.first
            : null;

    return GestureDetector(
      onTap: () {
        _showPlaylistSongs(
          context,
          player,
          playlistName,
        );
      },
      child: Container(
        width: 126,
        decoration: BoxDecoration(
          color: _surface(context),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: _border(context),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: coverSong != null
                        ? Image.asset(
                            coverSong.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, _, _) {
                              return _playlistPlaceholder();
                            },
                          )
                        : _playlistPlaceholder(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end:
                              Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(
                              alpha: 0.68,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                10,
                7,
                8,
                9,
              ),
              child: Text(
                playlistName,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text(context),
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playlistPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9B6BFF),
            Color(0xFF401080),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.queue_music_rounded,
          color: Colors.white,
          size: 34,
        ),
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
    final TextEditingController controller =
        TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final ThemeData theme =
            Theme.of(dialogContext);

        return AlertDialog(
          backgroundColor:
              theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: Text(
            'Create Playlist',
            style: TextStyle(
              color:
                  theme.colorScheme.onSurface,
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color:
                  theme.colorScheme.onSurface,
            ),
            cursorColor: purple,
            textInputAction:
                TextInputAction.done,
            decoration:
                InputDecoration(
              hintText:
                  'Playlist name',
              hintStyle: TextStyle(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
              filled: true,
              fillColor:
                  theme.colorScheme.surface,
              prefixIcon:
                  const Icon(
                Icons.queue_music_rounded,
                color: purple,
              ),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
                borderSide:
                    BorderSide(
                  color:
                      theme.dividerColor,
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
                borderSide:
                    BorderSide(
                  color:
                      theme.dividerColor,
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
                borderSide:
                    BorderSide(
                  color:
                      purple.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
            onSubmitted: (_) {
              _createPlaylist(
                dialogContext,
                player,
                controller.text,
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _createPlaylist(
                  dialogContext,
                  player,
                  controller.text,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
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
    final String playlistName =
        name.trim();

    if (playlistName.isEmpty) {
      return;
    }

    // Prevent duplicate playlist names.
    if (player.playlistNames
        .any(
          (existing) =>
              existing.trim().toLowerCase() ==
              playlistName.toLowerCase(),
        )) {
      Navigator.of(dialogContext).pop();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '"$playlistName" already exists',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: purpleDark,
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    player.createPlaylist(
      playlistName,
    );

    Navigator.of(
      dialogContext,
    ).pop();

    setState(() {});

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '"$playlistName" playlist created',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: purpleDark,
        behavior:
            SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
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
    final List<SongModel> playlistSongs =
        player.getPlaylistSongs(
      playlistName,
    );

    final Set<String> existingIds =
        playlistSongs
            .map((song) => song.id)
            .toSet();

    final List<SongModel> availableSongs =
        allSongs
            .where(
              (song) =>
                  !existingIds.contains(song.id),
            )
            .toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        final ThemeData theme =
            Theme.of(sheetContext);

        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.78,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(
                      alpha: 0.25,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    18,
                    16,
                    14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Add Songs',
                              style:
                                  TextStyle(
                                color: theme
                                    .colorScheme
                                    .onSurface,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Choose songs for your playlist',
                              style:
                                  TextStyle(
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            sheetContext,
                          ).pop();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme
                              .colorScheme
                              .onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: availableSongs
                          .isEmpty
                      ? Center(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .all(24),
                            child: Text(
                              'All songs are already in this playlist',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            16,
                            4,
                            16,
                            25,
                          ),
                          physics:
                              const BouncingScrollPhysics(),
                          itemCount:
                              availableSongs
                                  .length,
                          separatorBuilder:
                              (_, _) =>
                                  const SizedBox(
                            height: 8,
                          ),
                          itemBuilder:
                              (context, index) {
                            final SongModel
                                song =
                                availableSongs[
                                    index];

                            return GestureDetector(
                              onTap: () {
                                player
                                    .addSongToPlaylist(
                                  playlistName,
                                  song,
                                );

                                Navigator.of(
                                  sheetContext,
                                ).pop();

                                _showPlaylistSongs(
                                  this.context,
                                  player,
                                  playlistName,
                                );

                                setState(() {});
                              },
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .all(9),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      _surface(
                                    context,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        _border(
                                      context,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        10,
                                      ),
                                      child:
                                          Image.asset(
                                        song.imagePath,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, _, _) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color:
                                                purpleDark,
                                            child:
                                                const Icon(
                                              Icons
                                                  .music_note_rounded,
                                              color:
                                                  Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            song.title,
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                TextStyle(
                                              color:
                                                  _text(
                                                context,
                                              ),
                                              fontSize:
                                                  14,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            song.artist,
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                TextStyle(
                                              color:
                                                  _muted(
                                                context,
                                              ),
                                              fontSize:
                                                  11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            purple
                                                .withValues(
                                          alpha:
                                              0.13,
                                        ),
                                        shape:
                                            BoxShape
                                                .circle,
                                      ),
                                      child:
                                          const Icon(
                                        Icons
                                            .add_rounded,
                                        color:
                                            purple,
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
  ) {
    final Map<String, SongModel> albums = {};

    for (final SongModel song in allSongs) {
      if (song.album.isNotEmpty &&
          !albums.containsKey(song.album)) {
        albums[song.album] = song;
      }
    }

    final List<SongModel> albumSongs =
        albums.values.toList();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          'Albums',
          '${albumSongs.length} albums',
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            itemCount:
                albumSongs.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 11),
            itemBuilder:
                (context, index) {
              final SongModel song =
                  albumSongs[index];

              return GestureDetector(
                onTap: () {
                  _showAlbumSongs(
                    context,
                    song.album,
                  );
                },
                child: SizedBox(
                  width: 116,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                          child: Image.asset(
                            song.imagePath,
                            width: 116,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, _, _) {
                              return Container(
                                color:
                                    _surface(
                                  context,
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .album_rounded,
                                  color:
                                      purple,
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
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              _text(context),
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
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
    );
  }

  // ============================================================
  // ARTISTS
  // ============================================================

  Widget _buildArtistsSection(
    BuildContext context,
  ) {
    final List<_ArtistData> artists = [
      const _ArtistData(
        name: 'Arijit Singh',
        imagePath:
            'assets/images/artists/arijit_singh.jpg',
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFF4C1D95),
        ],
      ),
      const _ArtistData(
        name: 'Rahat Fateh Ali Khan',
        imagePath:
            'assets/images/artists/rahat_fateh_ali_khan.jpg',
        colors: [
          Color(0xFFFF4B2B),
          Color(0xFFB31217),
        ],
      ),
      const _ArtistData(
        name: 'Mohit Chauhan',
        imagePath:
            'assets/images/artists/mohit_chauhan.jpg',
        colors: [
          Color(0xFF64748B),
          Color(0xFF1E293B),
        ],
      ),
      const _ArtistData(
        name: 'Atif Aslam',
        imagePath:
            'assets/images/artists/atif_aslam.jpg',
        colors: [
          Color(0xFF0F9BA8),
          Color(0xFF075985),
        ],
      ),
      const _ArtistData(
        name: 'Javed Bashir',
        imagePath:
            'assets/images/artists/javed_bashir.jpg',
        colors: [
          Color(0xFF64748B),
          Color(0xFF334155),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          context,
          'Artists',
          '${artists.length} artists',
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 113,
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            itemCount: artists.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 14),
            itemBuilder:
                (context, index) {
              final _ArtistData artist =
                  artists[index];

              return GestureDetector(
                onTap: () {
                  _showArtistSongs(
                    context,
                    artist.name,
                  );
                },
                child: SizedBox(
                  width: 78,
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          gradient:
                              LinearGradient(
                            colors:
                                artist.colors,
                            begin:
                                Alignment.topLeft,
                            end:
                                Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: artist
                                  .colors
                                  .first
                                  .withValues(
                                alpha: 0.20,
                              ),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        padding:
                            const EdgeInsets.all(
                          2,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            artist.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, _, _) {
                              return Container(
                                decoration:
                                    BoxDecoration(
                                  gradient:
                                      LinearGradient(
                                    colors:
                                        artist.colors,
                                  ),
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .person_rounded,
                                  color:
                                      Colors.white,
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
                        textAlign:
                            TextAlign.center,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              _text(context),
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
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
    );
  }

  // ============================================================
  // ARTIST SONGS
  // ============================================================

  void _showArtistSongs(
    BuildContext context,
    String artistName,
  ) {
    final PlayerController player =
        PlayerScope.of(context);

    final List<SongModel> songs =
        allSongs
            .where(
              (song) =>
                  song.artist.trim().toLowerCase() ==
                  artistName.trim().toLowerCase(),
            )
            .toList();

    _showSongListBottomSheet(
      context,
      title: artistName,
      subtitle: '${songs.length} songs',
      songs: songs,
      player: player,
    );
  }

  // ============================================================
  // SONG HEADER
  // ============================================================

  Widget _buildSongsHeader(
    BuildContext context,
  ) {
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
          '${allSongs.length} songs',
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

  Widget _buildSongsList(
    BuildContext context,
    PlayerController player,
  ) {
    final List<SongModel> songs =
        _songsForFilter(player);

    if (songs.isEmpty) {
      return _emptySongsState(context);
    }

    return Column(
      children: List.generate(
        songs.length,
        (index) {
          final SongModel song =
              songs[index];

          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 9,
            ),
            child: _songRow(
              context,
              player,
              song,
              index,
            ),
          );
        },
      ),
    );
  }

  Widget _songRow(
    BuildContext context,
    PlayerController player,
    SongModel song,
    int index,
  ) {
    final bool isCurrent =
        player.currentSongData.id ==
            song.id;

    final bool isLiked =
        player.isSongLiked(song);

    return GestureDetector(
      onTap: () async {
        await _openPlayback(
          context,
          song,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isCurrent
              ? purple.withValues(
                  alpha: 0.10,
                )
              : _surface(context),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: isCurrent
                ? purple.withValues(
                    alpha: 0.22,
                  )
                : _border(context),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: isCurrent &&
                      player.isPlaying
                  ? const Icon(
                      Icons
                          .equalizer_rounded,
                      color: purple,
                      size: 19,
                    )
                  : Text(
                      '${index + 1}',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            _muted(context),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 9),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
              child: Image.asset(
                song.imagePath,
                width: 49,
                height: 49,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, _, _) {
                  return Container(
                    width: 49,
                    height: 49,
                    color: purpleDark,
                    child: const Icon(
                      Icons
                          .music_note_rounded,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent
                          ? purple
                          : _text(context),
                      fontSize: 13,
                      fontWeight: isCurrent
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          _muted(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                await player.toggleLikeSong(
                  song,
                );

                if (mounted) {
                  setState(() {});
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.all(7),
                child: Icon(
                  isLiked
                      ? Icons
                          .favorite_rounded
                      : Icons
                          .favorite_border_rounded,
                  color: isLiked
                      ? purple
                      : _muted(context),
                  size: 20,
                ),
              ),
            ),
            Icon(
              Icons.more_vert_rounded,
              color: _muted(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptySongsState(
    BuildContext context,
  ) {
    final bool liked =
        _selectedFilter == 0;

    final bool recent =
        _selectedFilter == 1;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 25,
      ),
      decoration: BoxDecoration(
        color: _surface(context),
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: _border(context),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:
                  purple.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              liked
                  ? Icons
                      .favorite_border_rounded
                  : recent
                      ? Icons
                          .history_rounded
                      : Icons
                          .music_note_rounded,
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
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your songs will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    BuildContext context,
    String title,
    String trailing,
  ) {
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
    final List<SongModel> songs =
        player.getPlaylistSongs(
      playlistName,
    );

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
    String albumName,
  ) {
    final PlayerController player =
        PlayerScope.of(context);

    final List<SongModel> songs =
        allSongs
            .where(
              (song) =>
                  song.album == albumName,
            )
            .toList();

    _showSongListBottomSheet(
      context,
      title: albumName,
      subtitle: '${songs.length} songs',
      songs: songs,
      player: player,
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
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        final ThemeData theme =
            Theme.of(sheetContext);

        final Color textColor =
            theme.colorScheme.onSurface;

        final Color mutedColor =
            theme.colorScheme
                .onSurfaceVariant;

        final Color surfaceColor =
            theme.colorScheme.surface;

        final Color borderColor =
            theme.dividerColor;

        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.72,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 42,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color: mutedColor
                        .withValues(
                      alpha: 0.25,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    18,
                    10,
                    12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  TextStyle(
                                color:
                                    textColor,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              subtitle,
                              style:
                                  TextStyle(
                                color:
                                    mutedColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add songs button only
                      // for actual playlists.
                      if (playlistName != null)
                        IconButton(
                          onPressed: () {
                            Navigator.of(
                              sheetContext,
                            ).pop();

                            _showAddSongsToPlaylist(
                              context,
                              player,
                              playlistName,
                            );
                          },
                          icon:
                              const Icon(
                            Icons.add_rounded,
                            color: purple,
                          ),
                        ),

                      IconButton(
                        onPressed: () {
                          Navigator.of(
                            sheetContext,
                          ).pop();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: songs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons
                                    .music_off_rounded,
                                color:
                                    mutedColor,
                                size: 34,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                playlistName !=
                                        null
                                    ? 'No songs in this playlist'
                                    : 'No songs in this collection',
                                style:
                                    TextStyle(
                                  color:
                                      mutedColor,
                                  fontSize: 13,
                                ),
                              ),
                              if (playlistName !=
                                  null) ...[
                                const SizedBox(
                                  height: 14,
                                ),
                                ElevatedButton
                                    .icon(
                                  onPressed: () {
                                    Navigator.of(
                                      sheetContext,
                                    ).pop();

                                    _showAddSongsToPlaylist(
                                      context,
                                      player,
                                      playlistName,
                                    );
                                  },
                                  icon:
                                      const Icon(
                                    Icons
                                        .add_rounded,
                                    size: 17,
                                  ),
                                  label:
                                      const Text(
                                    'Add Songs',
                                  ),
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        purple,
                                    foregroundColor:
                                        Colors
                                            .white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            16,
                            4,
                            16,
                            25,
                          ),
                          physics:
                              const BouncingScrollPhysics(),
                          itemCount:
                              songs.length,
                          separatorBuilder:
                              (_, _) =>
                                  const SizedBox(
                            height: 8,
                          ),
                          itemBuilder:
                              (context, index) {
                            final SongModel
                                song =
                                songs[index];

                            final bool liked =
                                player
                                    .isSongLiked(
                              song,
                            );

                            return GestureDetector(
                              onTap: () async {
                                Navigator.of(
                                  sheetContext,
                                ).pop();

                                if (!this.context
                                    .mounted) {
                                  return;
                                }

                                // Exact selected
                                // song opens in
                                // PlaybackScreen.
                                await _openPlayback(
                                  this.context,
                                  song,
                                );
                              },
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .all(9),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      surfaceColor,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                  border:
                                      Border.all(
                                    color:
                                        borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        10,
                                      ),
                                      child:
                                          Image.asset(
                                        song.imagePath,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, _, _) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color:
                                                purpleDark,
                                            child:
                                                const Icon(
                                              Icons
                                                  .music_note_rounded,
                                              color:
                                                  Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            song.title,
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                TextStyle(
                                              color:
                                                  textColor,
                                              fontSize:
                                                  13,
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            song.artist,
                                            maxLines:
                                                1,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style:
                                                TextStyle(
                                              color:
                                                  mutedColor,
                                              fontSize:
                                                  10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // LIKE
                                    IconButton(
                                      onPressed:
                                          () async {
                                        await player
                                            .toggleLikeSong(
                                          song,
                                        );

                                        if (mounted) {
                                          setState(
                                            () {},
                                          );
                                        }
                                      },
                                      icon:
                                          Icon(
                                        liked
                                            ? Icons
                                                .favorite_rounded
                                            : Icons
                                                .favorite_border_rounded,
                                        color: liked
                                            ? purple
                                            : mutedColor,
                                        size: 20,
                                      ),
                                    ),

                                    // REMOVE FROM
                                    // PLAYLIST
                                    if (playlistName !=
                                        null)
                                      IconButton(
                                        onPressed:
                                            () {
                                          player
                                              .removeSongFromPlaylist(
                                            playlistName,
                                            song,
                                          );

                                          Navigator.of(
                                            sheetContext,
                                          ).pop();

                                          _showPlaylistSongs(
                                            context,
                                            player,
                                            playlistName,
                                          );

                                          setState(
                                            () {},
                                          );
                                        },
                                        icon:
                                            Icon(
                                          Icons
                                              .remove_circle_outline_rounded,
                                          color:
                                              mutedColor,
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