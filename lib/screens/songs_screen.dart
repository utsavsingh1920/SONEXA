import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../player/player_scope.dart';
import 'playback_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  int selectedFilter = 0;

  final List<String> filters = const [
    'All',
    'Recently Played',
    'Favorites',
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        // ============================================================
        // ALL SONGS
        // ============================================================

        final List<SongModel> allSongs = player.songs;

        // ============================================================
        // FILTER SONGS
        // ============================================================

        List<SongModel> filteredSongs =
            List<SongModel>.from(allSongs);

        // ============================================================
        // RECENTLY PLAYED
        // ============================================================

        if (selectedFilter == 1) {
          filteredSongs =
              List<SongModel>.from(player.recentlyPlayed);
        }

        // ============================================================
        // FAVORITES
        // ============================================================

        if (selectedFilter == 2) {
          filteredSongs =
              List<SongModel>.from(player.likedSongs);
        }

        // ============================================================
        // SEARCH
        // ============================================================

        if (searchQuery.trim().isNotEmpty) {
          final String query =
              searchQuery.toLowerCase().trim();

          filteredSongs = filteredSongs.where((SongModel song) {
            return song.title
                    .toLowerCase()
                    .contains(query) ||
                song.artist
                    .toLowerCase()
                    .contains(query);
          }).toList();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0B0712),
          body: SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              children: [
                // ========================================================
                // HEADER
                // ========================================================

                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Music',
                            style: TextStyle(
                              color: Color(0xFFA8A0B3),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Songs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ====================================================
                    // SHUFFLE
                    // ====================================================

                    _topButton(
                      icon: Icons.shuffle_rounded,
                      onTap: () async {
                        if (player.songs.isEmpty) {
                          return;
                        }

                        final int index =
                            DateTime.now().millisecond %
                                player.songs.length;

                        final SongModel song =
                            player.songs[index];

                        await player.playSongModel(song);

                        if (!context.mounted) {
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PlaybackScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    // ====================================================
                    // MORE
                    // ====================================================

                    _topButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: () {
                        _showMoreMenu(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ========================================================
                // SEARCH
                // ========================================================

                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15101F),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2A2235),
                    ),
                  ),
                  child: TextField(
                    onChanged: (String value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    cursorColor:
                        const Color(0xFFB77CFF),
                    decoration:
                        const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF70677C),
                        size: 22,
                      ),
                      hintText:
                          'Search in your songs...',
                      hintStyle: TextStyle(
                        color: Color(0xFF70677C),
                        fontSize: 14,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ========================================================
                // FILTERS
                // ========================================================

                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      final bool isSelected =
                          selectedFilter == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFilter = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds: 200,
                          ),
                          margin:
                              const EdgeInsets.only(
                            right: 10,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 17,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(
                                    0xFF9B5CFF,
                                  )
                                : const Color(
                                    0xFF15101F,
                                  ),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(
                                      0xFF9B5CFF,
                                    )
                                  : const Color(
                                      0xFF2A2235,
                                    ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            filters[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(
                                      0xFFA8A0B3,
                                    ),
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ========================================================
                // SECTION HEADER
                // ========================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedFilter == 0
                          ? 'All Songs'
                          : filters[selectedFilter],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${filteredSongs.length} songs',
                      style: const TextStyle(
                        color: Color(0xFF70677C),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ========================================================
                // SONG LIST
                // ========================================================

                if (filteredSongs.isEmpty)
                  _emptyState(
                    isFavorites: selectedFilter == 2,
                    isRecentlyPlayed:
                        selectedFilter == 1,
                  )
                else
                  ...List.generate(
                    filteredSongs.length,
                    (int index) {
                      final SongModel song =
                          filteredSongs[index];

                      // ==================================================
                      // CURRENT SONG
                      // ==================================================

                      final bool isCurrent =
                          player.currentSongData.id ==
                              song.id;

                      return _SongItem(
                        title: song.title,
                        artist: song.artist,
                        imagePath: song.imagePath,
                        duration: _formatDuration(
                          _getKnownDuration(
                            song.title,
                          ),
                        ),
                        isCurrent: isCurrent,
                        isPlaying:
                            isCurrent &&
                                player.isPlaying,

                        // =================================================
                        // PLAY SONG
                        // =================================================

                        onTap: () async {
                          await player.playSongModel(
                            song,
                          );

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PlaybackScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TOP BUTTON
  // ============================================================

  static Widget _topButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF20182D),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF2A2235),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB77CFF),
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  static Widget _emptyState({
    bool isFavorites = false,
    bool isRecentlyPlayed = false,
  }) {
    final IconData icon;
    final String title;
    final String subtitle;

    if (isFavorites) {
      icon = Icons.favorite_border_rounded;
      title = 'No favorite songs';
      subtitle =
          'Favorite songs will appear here.';
    } else if (isRecentlyPlayed) {
      icon = Icons.history_rounded;
      title = 'No recently played songs';
      subtitle =
          'Songs you play will appear here.';
    } else {
      icon = Icons.music_off_rounded;
      title = 'No songs found';
      subtitle =
          'Try another search or filter.';
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF15101F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2235),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF70677C),
            size: 45,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF70677C),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MORE MENU
  // ============================================================

  static void _showMoreMenu(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15101F),
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFF4A4055),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const ListTile(
                  leading: Icon(
                    Icons.sort_rounded,
                    color:
                        Color(0xFFB77CFF),
                  ),
                  title: Text(
                    'Sort Songs',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                const ListTile(
                  leading: Icon(
                    Icons.view_list_rounded,
                    color:
                        Color(0xFFB77CFF),
                  ),
                  title: Text(
                    'List View',
                    style: TextStyle(
                      color: Colors.white,
                    ),
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
  // KNOWN SONG DURATIONS
  // ============================================================

  static Duration _getKnownDuration(
    String title,
  ) {
    switch (title) {
      case 'Kesariya':
        return const Duration(
          minutes: 4,
          seconds: 28,
        );

      case 'Hawayein':
        return const Duration(
          minutes: 4,
          seconds: 49,
        );

      case 'Pee Loon':
        return const Duration(
          minutes: 4,
          seconds: 45,
        );

      case 'Mast Magan':
        return const Duration(
          minutes: 4,
          seconds: 40,
        );

      case 'Dagabaaz Re':
        return const Duration(
          minutes: 4,
          seconds: 45,
        );

      case 'Tum Jo Aaye':
        return const Duration(
          minutes: 4,
          seconds: 48,
        );

      case 'Janam Janam':
        return const Duration(
          minutes: 3,
          seconds: 57,
        );

      case 'Tu Jaane Na':
        return const Duration(
          minutes: 5,
          seconds: 41,
        );

      case 'Ye Tune Kya Kiya':
        return const Duration(
          minutes: 5,
          seconds: 12,
        );

      case 'Tera Deedar Hua':
        return const Duration(
          minutes: 5,
          seconds: 45,
        );

      default:
        return Duration.zero;
    }
  }

  // ============================================================
  // FORMAT DURATION
  // ============================================================

  static String _formatDuration(
    Duration duration,
  ) {
    final int minutes =
        duration.inMinutes;

    final int seconds =
        duration.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// SONG ITEM
// ============================================================================

class _SongItem extends StatelessWidget {
  final String title;
  final String artist;
  final String imagePath;
  final String duration;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _SongItem({
    required this.title,
    required this.artist,
    required this.imagePath,
    required this.duration,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFF21172E)
            : const Color(0xFF15101F),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF5A397A)
              : const Color(0xFF211A2B),
        ),
      ),
      child: Row(
        children: [
          // ================================================================
          // NUMBER / PLAYING ICON
          // ================================================================

          SizedBox(
            width: 22,
            child: isPlaying
                ? const Icon(
                    Icons.graphic_eq_rounded,
                    color:
                        Color(0xFFB77CFF),
                    size: 19,
                  )
                : Text(
                    _getDisplayNumber(),
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: isCurrent
                          ? const Color(
                              0xFFB77CFF,
                            )
                          : const Color(
                              0xFF70677C,
                            ),
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          // ================================================================
          // ARTWORK
          // ================================================================

          ClipRRect(
            borderRadius:
                BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration:
                      const BoxDecoration(
                    gradient:
                        LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        Color(
                          0xFFB77CFF,
                        ),
                        Color(
                          0xFF7138C8,
                        ),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 14),

          // ================================================================
          // SONG INFO
          // ================================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: isCurrent
                        ? FontWeight.w800
                        : FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  artist,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        Color(0xFFA8A0B3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // ================================================================
          // DURATION
          // ================================================================

          Text(
            duration,
            style: const TextStyle(
              color:
                  Color(0xFF70677C),
              fontSize: 11,
            ),
          ),

          const SizedBox(width: 8),

          // ================================================================
          // PLAY BUTTON
          // ================================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(12),
              onTap: onTap,
              child: Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(
                  color: isCurrent
                      ? const Color(
                          0xFF9B5CFF,
                        )
                      : const Color(
                          0xFF241A32,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons
                          .play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPLAY NUMBER
  // ============================================================

  String _getDisplayNumber() {
    return '${title.hashCode.abs() % 99 + 1}';
  }
}