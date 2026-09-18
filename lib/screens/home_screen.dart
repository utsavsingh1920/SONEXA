import 'dart:async';

import 'package:flutter/material.dart';

import '../data/songs_data.dart';
import '../models/song_model.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';
import 'library_screen.dart';
import 'notifications_screen.dart';
import 'playback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _heroController;
  late final AnimationController _equalizerController;

  Timer? _heroTimer;

  static const int _heroInitialPage = 999;
  static const int _heroCount = 3;

  final List<String> _madeForYouCategories = [
    'Chill Vibes',
    'Late Night',
    'Soft & Romantic',
    'Feel Good',
    'Bollywood Mood',
    'Relax Session',
    'Love Vibes',
    'Dreamy Nights',
    'Soulful',
    'Peaceful',
  ];

  final List<String> _playlistNames = [
    'Daily Mix',
    'Night Drive',
    'Love Songs',
    'Bollywood Chill',
    'Romantic Nights',
    'Soft Vibes',
    'Late Night Mix',
    'Feel Good',
    'Soulful Collection',
    'Classic Romance',
  ];

  final List<Map<String, dynamic>> _moods = [
    {
      'title': 'Chill',
      'icon': Icons.nightlight_round,
      'color': const Color(0xFF7D65FF),
      'tag': 'Chill',
    },
    {
      'title': 'Romantic',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF6B9D),
      'tag': 'Romantic',
    },
    {
      'title': 'Bollywood',
      'icon': Icons.music_note_rounded,
      'color': const Color(0xFFFF9F5A),
      'tag': 'Bollywood',
    },
    {
      'title': 'Focus',
      'icon': Icons.center_focus_strong_rounded,
      'color': const Color(0xFF58B7FF),
      'tag': 'Chill',
    },
    {
      'title': 'Love',
      'icon': Icons.favorite_border_rounded,
      'color': const Color(0xFFC66BFF),
      'tag': 'Romantic',
    },
    {
      'title': 'Late Night',
      'icon': Icons.nightlight_rounded,
      'color': const Color(0xFF8D72FF),
      'tag': 'Chill',
    },
    {
      'title': 'Sufi',
      'icon': Icons.auto_awesome_rounded,
      'color': const Color(0xFFFF8C66),
      'tag': 'Bollywood',
    },
    {
      'title': 'Soft',
      'icon': Icons.cloud_rounded,
      'color': const Color(0xFF65C8FF),
      'tag': 'Romantic',
    },
    {
      'title': 'Vibes',
      'icon': Icons.waves_rounded,
      'color': const Color(0xFFB77CFF),
      'tag': 'Chill',
    },
    {
      'title': 'Soul',
      'icon': Icons.graphic_eq_rounded,
      'color': const Color(0xFFFF6B9D),
      'tag': 'Romantic',
    },
  ];

  @override
  void initState() {
    super.initState();

    _heroController = PageController(
      initialPage: _heroInitialPage,
    );

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startHeroTimer();
    });
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();

    _heroTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted || !_heroController.hasClients) {
          return;
        }

        if (_heroController.position.isScrollingNotifier.value) {
          return;
        }

        _heroController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    _equalizerController.dispose();
    super.dispose();
  }

  // ============================================================
  // PLAY / OPEN PLAYBACK
  // ============================================================

  Future<void> _playSong(
    BuildContext context,
    SongModel song, {
    bool openPlayer = false,
  }) async {
    final player = PlayerScope.of(context);

    if (!openPlayer) {
      await player.playSongModel(song);
      return;
    }

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaybackScreen(
          selectedSong: song,
        ),
      ),
    );
  }

  // ============================================================
  // GET CURRENT PLAYLIST SONGS
  // ============================================================

  List<SongModel> _getPlaylistSongs(
    PlayerController player,
    String playlistName,
    int index,
  ) {
    if (player.playlistNames.contains(playlistName)) {
      final savedSongs =
          player.getPlaylistSongs(playlistName);

      if (savedSongs.isNotEmpty) {
        return List<SongModel>.from(savedSongs);
      }
    }

    return _playlistSongsForIndex(index);
  }

  // ============================================================
  // SAVE PLAYLIST TO PLAYER CONTROLLER
  // ============================================================

  Future<void> _savePlaylist(
    BuildContext context,
    String playlistName,
    List<SongModel> songs,
  ) async {
    if (songs.isEmpty) return;

    final player = PlayerScope.of(context);

    if (!player.playlistNames.contains(playlistName)) {
      await player.createPlaylist(playlistName);
    }

    final existingSongs =
        player.getPlaylistSongs(playlistName);

    final existingIds =
        existingSongs.map((song) => song.id).toSet();

    for (final song in songs) {
      if (!existingIds.contains(song.id)) {
        await player.addSongToPlaylist(
          playlistName,
          song,
        );

        existingIds.add(song.id);
      }
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$playlistName saved to Library',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // ADD SONGS TO PLAYLIST
  // ============================================================

  Future<List<SongModel>?> _showAddSongsDialog(
    BuildContext context,
    List<SongModel> currentSongs,
  ) async {
    final theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color sheetColor = isDark
        ? const Color(0xFF100D16)
        : Colors.white;

    final Color primaryText = isDark
        ? Colors.white
        : const Color(0xFF17131D);

    final Color secondaryText = isDark
        ? const Color(0xFF81788D)
        : const Color(0xFF756D7D);

    final Set<String> selectedIds =
        currentSongs.map((song) => song.id).toSet();

    return showModalBottomSheet<List<SongModel>>(
      context: context,
      backgroundColor: sheetColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height * 0.78,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    14,
                    18,
                    18,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: secondaryText.withValues(
                              alpha: 0.35,
                            ),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Songs',
                                  style: TextStyle(
                                    color: primaryText,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${selectedIds.length} songs selected',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              final result = allSongs
                                  .where(
                                    (song) =>
                                        selectedIds
                                            .contains(song.id),
                                  )
                                  .toList();

                              Navigator.of(sheetContext)
                                  .pop(result);
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF7A45C4),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Expanded(
                        child: ListView.separated(
                          physics:
                              const BouncingScrollPhysics(),
                          itemCount: allSongs.length,
                          separatorBuilder:
                              (context, index) =>
                                  const SizedBox(height: 7),
                          itemBuilder:
                              (context, index) {
                            final song = allSongs[index];

                            final bool selected =
                                selectedIds.contains(song.id);

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(15),
                                onTap: () {
                                  setState(() {
                                    if (selected) {
                                      selectedIds
                                          .remove(song.id);
                                    } else {
                                      selectedIds.add(song.id);
                                    }
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(
                                            0xFF241735,
                                          )
                                        : isDark
                                            ? const Color(
                                                0xFF17131F,
                                              )
                                            : const Color(
                                                0xFFF7F3FA,
                                              ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      15,
                                    ),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(
                                              0xFF7A45C4,
                                            )
                                          : isDark
                                              ? const Color(
                                                  0xFF2C2535,
                                                )
                                              : const Color(
                                                  0xFFE5DFE9,
                                                ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius
                                                .circular(10),
                                        child: _songImage(
                                          song.imagePath,
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 10),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              song.title,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              style: TextStyle(
                                                color:
                                                    primaryText,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight
                                                        .w700,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 3),
                                            Text(
                                              song.artist,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              style: TextStyle(
                                                color:
                                                    secondaryText,
                                                fontSize: 8.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 8),

                                      Icon(
                                        selected
                                            ? Icons
                                                .check_circle_rounded
                                            : Icons
                                                .radio_button_unchecked_rounded,
                                        color: selected
                                            ? const Color(
                                                0xFFB77CFF,
                                              )
                                            : secondaryText,
                                        size: 23,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color backgroundColor =
        theme.scaffoldBackgroundColor;

    final Color cardColor = isDark
        ? const Color(0xFF12101A)
        : const Color(0xFFFFFFFF);

    final Color selectedCardColor = isDark
        ? const Color(0xFF191322)
        : const Color(0xFFF2EAF9);

    final Color borderColor = isDark
        ? const Color(0xFF292231)
        : const Color(0xFFE3DDE9);

    final Color primaryText = isDark
        ? Colors.white
        : const Color(0xFF17131D);

    final Color secondaryText = isDark
        ? const Color(0xFF797283)
        : const Color(0xFF756D7D);

    final Color tertiaryText = isDark
        ? const Color(0xFF5F5868)
        : const Color(0xFF928A99);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        if (player.isPlaying) {
          if (!_equalizerController.isAnimating) {
            _equalizerController.repeat();
          }
        } else {
          _equalizerController.stop();
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildHeader(
                    context,
                    isDark,
                    primaryText,
                    secondaryText,
                    borderColor,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          140,
                        ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _buildHero(context),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          title: 'Quick Access',
                          primaryText: primaryText,
                          accentColor:
                              theme.colorScheme.primary,
                        ),

                        const SizedBox(height: 9),

                        _buildQuickAccess(
                          context,
                          cardColor,
                          borderColor,
                          primaryText,
                          secondaryText,
                        ),

                        const SizedBox(height: 19),

                        _buildSectionTitle(
                          title: 'Continue Listening',
                          trailing: 'See all',
                          primaryText: primaryText,
                          accentColor:
                              theme.colorScheme.primary,
                          onTrailingTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LibraryScreen(
                                  initialFilter: 1,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 9),

                        _buildContinueListening(
                          context,
                          player,
                          cardColor,
                          selectedCardColor,
                          borderColor,
                          primaryText,
                          secondaryText,
                        ),

                        const SizedBox(height: 19),

                        _buildSectionTitle(
                          title: 'Made For You',
                          trailing: 'See all',
                          primaryText: primaryText,
                          accentColor:
                              theme.colorScheme.primary,
                          onTrailingTap: () {
                            _openAllSongs(context);
                          },
                        ),

                        const SizedBox(height: 9),

                        _buildMadeForYou(
                          context,
                          player,
                          primaryText,
                          secondaryText,
                        ),

                        const SizedBox(height: 19),

                        _buildSectionTitle(
                          title: 'Trending Now',
                          trailing: 'See all',
                          primaryText: primaryText,
                          accentColor:
                              theme.colorScheme.primary,
                          onTrailingTap: () {
                            _openAllSongs(context);
                          },
                        ),

                        const SizedBox(height: 9),

                        _buildTrending(
                          context,
                          player,
                          cardColor,
                          selectedCardColor,
                          borderColor,
                          primaryText,
                          secondaryText,
                          tertiaryText,
                        ),

                        const SizedBox(height: 19),

                        _buildSectionTitle(
                          title: 'Popular Playlists',
                          trailing: 'See all',
                          primaryText: primaryText,
                          accentColor:
                              theme.colorScheme.primary,
                          onTrailingTap: () {
                            _showAllPlaylists(context);
                          },
                        ),

                        const SizedBox(height: 9),

                        _buildPopularPlaylists(
                          context,
                          player,
                          isDark,
                        ),

                        const SizedBox(height: 19),

                        _buildSectionTitle(
                          title: 'Mood & Vibes',
                          trailing: 'Explore',
                          primaryText: primaryText,
                          accentColor:
                              theme.colorScheme.primary,
                          onTrailingTap: () {
                            _showAllMoods(context);
                          },
                        ),

                        const SizedBox(height: 9),

                        _buildMoodVibes(
                          context,
                          player,
                          cardColor,
                          borderColor,
                          primaryText,
                          secondaryText,
                        ),

                        const SizedBox(height: 19),

                        _buildSectionTitle(
                          title: 'Recommended For You',
                          trailing: 'See all',
                          primaryText: primaryText,
                          accentColor:
                              theme.colorScheme.primary,
                          onTrailingTap: () {
                            _openAllSongs(context);
                          },
                        ),

                        const SizedBox(height: 9),

                        _buildRecommended(
                          context,
                          player,
                          cardColor,
                          selectedCardColor,
                          borderColor,
                          primaryText,
                          secondaryText,
                          tertiaryText,
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                    ],
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
  // HEADER
  // ============================================================

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    Color primaryText,
    Color secondaryText,
    Color borderColor,
  ) {
    final hour = DateTime.now().hour;

    String greeting;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
    } else {
      greeting = 'Good Night';
    }

    final Color notificationBackground = isDark
        ? const Color(0xFF14111C)
        : Colors.white;

    final Color notificationIcon = isDark
        ? const Color(0xFFC5BECF)
        : const Color(0xFF4F4858);

    return SizedBox(
      height: 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0x442E0B59)
                      : const Color(0x222E0B59),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/sonexa_logo.png',
              width: 52,
              height: 52,
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFB77CFF),
                        Color(0xFF7138C8),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'SONEXA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationsScreen(),
                ),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: notificationBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: notificationIcon,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 185,
      child: PageView.builder(
        controller: _heroController,
        itemBuilder: (context, index) {
          final page = index % _heroCount;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 1),
            child: _buildHeroCard(
              context,
              page,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    int page,
  ) {
    final theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color heroTitleColor = isDark
        ? Colors.white
        : const Color(0xFF21152D);

    final Color heroSubtitleColor = isDark
        ? const Color(0xFFAAA1B8)
        : const Color(0xFF675A70);

    final Color heroLabelColor = isDark
        ? const Color(0xFFB77CFF)
        : const Color(0xFF7740B5);

    final Color heroBorderColor = isDark
        ? const Color(0xFF3A2850)
        : const Color(0xFFD8C5E9);

    final List<Map<String, dynamic>> data = [
      {
        'label': 'SONEXA MIX',
        'title': 'Your music,\nyour moment.',
        'subtitle':
            'A personalized mix made for your listening mood.',
        'image': 'assets/images/hero.logo.png',
        'song': allSongs.isNotEmpty
            ? allSongs[0]
            : null,
      },
      {
        'label': 'TRENDING TRACKS',
        'title': 'What’s hot\nright now.',
        'subtitle':
            'Listen to the tracks everyone is loving right now.',
        'image':
            'assets/images/headphone_hero.png',
        'song': allSongs.length > 1
            ? allSongs[1]
            : null,
      },
      {
        'label': 'STARGAZING ESSENTIALS',
        'title': 'Music for\nlate nights.',
        'subtitle':
            'Slow down, relax and enjoy your favorite sounds.',
        'image':
            'assets/images/galaxy_hero.png',
        'song': allSongs.length > 7
            ? allSongs[7]
            : null,
      },
    ];

    final item = data[page];

    final SongModel? song =
        item['song'] as SongModel?;

    return GestureDetector(
      onTap: () {
        if (song == null) return;

        _playSong(
          context,
          song,
          openPlayer: true,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF28154A),
                    Color(0xFF120D1D),
                  ]
                : const [
                    Color(0xFFEDE1FA),
                    Color(0xFFF9F6FC),
                  ],
          ),
          border: Border.all(
            color: heroBorderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x331F0B3D)
                  : const Color(0x221F0B3D),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned(
                right: page == 1 ? -2 : -8,
                top: page == 1 ? 8 : -8,
                bottom: page == 1 ? 8 : -8,
                child: Opacity(
                  opacity: isDark ? 0.88 : 0.82,
                  child: Image.asset(
                    item['image'] as String,
                    width:
                        page == 1 ? 160 : 174,
                    height:
                        page == 1 ? 176 : 188,
                    fit: page == 1
                        ? BoxFit.contain
                        : BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              Positioned(
                right: -65,
                top: -75,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        const Color(0xFF9B6BFF)
                            .withValues(
                      alpha:
                          isDark ? 0.10 : 0.08,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 230,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isDark
                          ? const [
                              Color(0xFF171020),
                              Color(0xE6171020),
                              Color(0x00171020),
                            ]
                          : const [
                              Color(0xFFF2E9F9),
                              Color(0xE6F2E9F9),
                              Color(0x00F2E9F9),
                            ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  15,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        color: heroLabelColor,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: heroTitleColor,
                        fontSize: 22,
                        height: 1.05,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 7),

                    SizedBox(
                      width: 175,
                      child: Text(
                        item['subtitle'] as String,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              heroSubtitleColor,
                          fontSize: 9.5,
                          height: 1.35,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin:
                              Alignment.topLeft,
                          end:
                              Alignment.bottomRight,
                          colors: [
                            Color(0xFF7040A8),
                            Color(0xFF45226F),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFF8052B8),
                          width: 0.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(
                                    0x542B124F,
                                  )
                                : const Color(
                                    0x302B124F,
                                  ),
                            blurRadius: 10,
                            offset:
                                const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .play_arrow_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Explore Mix',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    required Color primaryText,
    required Color accentColor,
    String? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing,
              style: TextStyle(
                color: accentColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // QUICK ACCESS
  // ============================================================

  Widget _buildQuickAccess(
    BuildContext context,
    Color cardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      children: [
        Expanded(
          child: _quickAccessCard(
            icon: Icons.favorite_rounded,
            title: 'Liked Songs',
            subtitle: 'Your favorites',
            iconColor:
                const Color(0xFFFC578E),
            cardColor: cardColor,
            borderColor: borderColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const LibraryScreen(
                    initialFilter: 0,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _quickAccessCard(
            icon: Icons.history_rounded,
            title: 'Recently Played',
            subtitle: 'Listen again',
            iconColor:
                const Color(0xFFB77CFF),
            cardColor: cardColor,
            borderColor: borderColor,
            primaryText: primaryText,
            secondaryText: secondaryText,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const LibraryScreen(
                    initialFilter: 1,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color cardColor,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color:
                      iconColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
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
                        color: primaryText,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 8.5,
                      ),
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

  // ============================================================
  // CONTINUE LISTENING
  // ============================================================

  Widget _buildContinueListening(
    BuildContext context,
    PlayerController player,
    Color cardColor,
    Color selectedCardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    final recentIds = player.recentlyPlayed
        .map((song) => song.id)
        .toSet();

    final List<SongModel> songs = [
      ...player.recentlyPlayed,
      ...allSongs.where(
        (song) =>
            !recentIds.contains(song.id),
      ),
    ];

    if (songs.isEmpty) {
      return SizedBox(
        height: 75,
        child: Center(
          child: Text(
            'Start listening to discover your music.',
            style: TextStyle(
              color: secondaryText,
              fontSize: 11,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount:
            songs.length > 5 ? 5 : songs.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(width: 9),
        itemBuilder: (context, index) {
          return _continueLargeCard(
            context,
            player,
            songs[index],
            cardColor,
            selectedCardColor,
            borderColor,
            primaryText,
            secondaryText,
          );
        },
      ),
    );
  }

  Widget _continueLargeCard(
    BuildContext context,
    PlayerController player,
    SongModel song,
    Color cardColor,
    Color selectedCardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    final bool isCurrent =
        player.currentSongData.id == song.id;

    double progress = 0.0;

    if (isCurrent &&
        player.duration.inMilliseconds > 0) {
      progress =
          player.progress.clamp(0.0, 1.0);
    }

    return GestureDetector(
      onTap: () {
        _playSong(
          context,
          song,
          openPlayer: true,
        );
      },
      child: SizedBox(
        width: 132,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCurrent
                ? selectedCardColor
                : cardColor,
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: isCurrent
                  ? const Color(0xFF493064)
                  : borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(11),
                    child: _songImage(
                      song.imagePath,
                      width: 114,
                      height: 88,
                    ),
                  ),
                  Positioned(
                    right: 5,
                    bottom: 5,
                    child: _playCircle(
                      isPlaying: isCurrent &&
                          player.isPlaying,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                song.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 10.5,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                song.artist,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 8,
                ),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor:
                      const Color(0xFF30293A),
                  valueColor:
                      const AlwaysStoppedAnimation(
                    Color(0xFFB77CFF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MADE FOR YOU
  // ============================================================

  Widget _buildMadeForYou(
    BuildContext context,
    PlayerController player,
    Color primaryText,
    Color secondaryText,
  ) {
    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount: allSongs.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final song = allSongs[index];

          return _largeSongCard(
            context,
            player,
            song,
            _madeForYouCategories[
                index %
                    _madeForYouCategories.length],
            primaryText,
            secondaryText,
          );
        },
      ),
    );
  }

  Widget _largeSongCard(
    BuildContext context,
    PlayerController player,
    SongModel song,
    String category,
    Color primaryText,
    Color secondaryText,
  ) {
    final isPlaying =
        player.currentSongData.id ==
                song.id &&
            player.isPlaying;

    return GestureDetector(
      onTap: () {
        _playSong(
          context,
          song,
          openPlayer: true,
        );
      },
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(14),
                  child: _songImage(
                    song.imagePath,
                    width: 120,
                    height: 102,
                  ),
                ),
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: _playCircle(
                    isPlaying: isPlaying,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              category,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryText,
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              song.title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: secondaryText,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRENDING
  // ============================================================

  Widget _buildTrending(
    BuildContext context,
    PlayerController player,
    Color cardColor,
    Color selectedCardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
    Color tertiaryText,
  ) {
    final songs = allSongs.length > 5
        ? allSongs.take(5).toList()
        : allSongs;

    return SizedBox(
      height: 91,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount: songs.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(width: 9),
        itemBuilder: (context, index) {
          return _trendingCard(
            context,
            player,
            songs[index],
            index + 1,
            cardColor,
            selectedCardColor,
            borderColor,
            primaryText,
            secondaryText,
            tertiaryText,
          );
        },
      ),
    );
  }

  Widget _trendingCard(
    BuildContext context,
    PlayerController player,
    SongModel song,
    int number,
    Color cardColor,
    Color selectedCardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
    Color tertiaryText,
  ) {
    final bool current =
        player.currentSongData.id ==
            song.id;

    return GestureDetector(
      onTap: () {
        _playSong(
          context,
          song,
          openPlayer: true,
        );
      },
      child: Container(
        width: 235,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: current
              ? selectedCardColor
              : cardColor,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: current
                ? const Color(0xFF493064)
                : borderColor,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                number
                    .toString()
                    .padLeft(2, '0'),
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: current
                      ? const Color(
                          0xFFB77CFF,
                        )
                      : tertiaryText,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 7),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: _songImage(
                song.imagePath,
                width: 56,
                height: 56,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 8.5,
                    ),
                  ),
                  if (song.album.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      song.album,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tertiaryText,
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 5),
            if (current && player.isPlaying)
              _EqualizerBars(
                animation:
                    _equalizerController,
              )
            else
              Icon(
                Icons.play_circle_outline_rounded,
                color: secondaryText,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // POPULAR PLAYLISTS
  // ============================================================

  Widget _buildPopularPlaylists(
    BuildContext context,
    PlayerController player,
    bool isDark,
  ) {
    if (allSongs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount: allSongs.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final String playlistName =
              _playlistNames[
                  index % _playlistNames.length];

          final List<SongModel> songs =
              _getPlaylistSongs(
            player,
            playlistName,
            index,
          );

          final List<SongModel> previewSongs =
              songs.isNotEmpty
                  ? songs
                  : _playlistSongsForIndex(index);

          while (previewSongs.length < 3 &&
              allSongs.isNotEmpty) {
            previewSongs.add(
              allSongs[
                  previewSongs.length %
                      allSongs.length],
            );
          }

          return _playlistCard(
            context,
            playlistName,
            previewSongs.first.title,
            previewSongs,
            isDark,
            player,
            index,
          );
        },
      ),
    );
  }

  Widget _playlistCard(
    BuildContext context,
    String title,
    String subtitle,
    List<SongModel> songs,
    bool isDark,
    PlayerController player,
    int playlistIndex,
  ) {
    final Color playlistStart = isDark
        ? const Color(0xFF24143A)
        : const Color(0xFFF3EAF9);

    final Color playlistEnd = isDark
        ? const Color(0xFF120E18)
        : const Color(0xFFFFFFFF);

    final Color playlistBorder = isDark
        ? const Color(0xFF352443)
        : const Color(0xFFE3DDE9);

    final Color titleColor = isDark
        ? Colors.white
        : const Color(0xFF17131D);

    final Color subtitleColor = isDark
        ? const Color(0xFF7B7385)
        : const Color(0xFF817989);

    return GestureDetector(
      onTap: () {
        if (songs.isEmpty) return;

        _showPlaylistSongs(
          context,
          title,
          songs,
          player,
          playlistIndex,
        );
      },
      child: SizedBox(
        width: 132,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(17),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                playlistStart,
                playlistEnd,
              ],
            ),
            border: Border.all(
              color: playlistBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 88,
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.only(
                          topLeft:
                              Radius.circular(11),
                          bottomLeft:
                              Radius.circular(11),
                        ),
                        child: _songImage(
                          songs[0].imagePath,
                          width:
                              double.infinity,
                          height: 88,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.only(
                                topRight:
                                    Radius.circular(
                                  11,
                                ),
                              ),
                              child: _songImage(
                                songs.length > 1
                                    ? songs[1].imagePath
                                    : songs[0].imagePath,
                                width:
                                    double.infinity,
                                height:
                                    double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.only(
                                bottomRight:
                                    Radius.circular(
                                  11,
                                ),
                              ),
                              child: _songImage(
                                songs.length > 2
                                    ? songs[2].imagePath
                                    : songs[0].imagePath,
                                width:
                                    double.infinity,
                                height:
                                    double.infinity,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PLAYLIST SONG LIST
  // ============================================================

  Future<void> _showPlaylistSongs(
    BuildContext context,
    String playlistName,
    List<SongModel> initialSongs,
    PlayerController player,
    int playlistIndex,
  ) async {
    final theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color sheetColor = isDark
        ? const Color(0xFF100D16)
        : Colors.white;

    final Color primaryText = isDark
        ? Colors.white
        : const Color(0xFF17131D);

    final Color secondaryText = isDark
        ? const Color(0xFF81788D)
        : const Color(0xFF756D7D);

    List<SongModel> currentSongs =
        List<SongModel>.from(initialSongs);

    if (player.playlistNames.contains(playlistName)) {
      final saved =
          player.getPlaylistSongs(playlistName);

      if (saved.isNotEmpty) {
        currentSongs =
            List<SongModel>.from(saved);
      }
    }

    bool isSaved =
        player.playlistNames.contains(playlistName) &&
        player
            .getPlaylistSongs(playlistName)
            .isNotEmpty;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return SafeArea(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height *
                        0.80,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    14,
                    18,
                    18,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: secondaryText
                                .withValues(
                              alpha: 0.35,
                            ),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlistName,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: primaryText,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${currentSongs.length} songs',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () async {
                              final List<SongModel>?
                                  selectedSongs =
                                  await _showAddSongsDialog(
                                context,
                                currentSongs,
                              );

                              if (selectedSongs ==
                                  null) {
                                return;
                              }

                              setSheetState(() {
                                currentSongs =
                                    selectedSongs;
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(
                                        0xFF241A30,
                                      )
                                    : const Color(
                                        0xFFF1E9F8,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(
                                          0xFF3B2B4B,
                                        )
                                      : const Color(
                                          0xFFE0D2EA,
                                        ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons
                                        .add_rounded,
                                    color:
                                        const Color(
                                      0xFFB77CFF,
                                    ),
                                    size: 17,
                                  ),
                                  const SizedBox(
                                      width: 4),
                                  Text(
                                    'Add Songs',
                                    style:
                                        TextStyle(
                                      color:
                                          primaryText,
                                      fontSize: 9,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 7),

                          GestureDetector(
                            onTap: () async {
                              await _savePlaylist(
                                context,
                                playlistName,
                                currentSongs,
                              );

                              setSheetState(() {
                                isSaved = true;
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSaved
                                    ? const Color(
                                        0xFF2A2035,
                                      )
                                    : const Color(
                                        0xFF7A45C4,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSaved
                                        ? Icons
                                            .check_rounded
                                        : Icons
                                            .bookmark_add_outlined,
                                    color:
                                        Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(
                                      width: 4),
                                  Text(
                                    isSaved
                                        ? 'Saved'
                                        : 'Save',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 9,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: currentSongs.isEmpty
                            ? Center(
                                child: Text(
                                  'No songs in this playlist.',
                                  style: TextStyle(
                                    color:
                                        secondaryText,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                physics:
                                    const BouncingScrollPhysics(),
                                itemCount:
                                    currentSongs.length,
                                separatorBuilder:
                                    (
                                      context,
                                      index,
                                    ) =>
                                        const SizedBox(
                                  height: 7,
                                ),
                                itemBuilder:
                                    (
                                      context,
                                      index,
                                    ) {
                                  final song =
                                      currentSongs[
                                          index];

                                  return Material(
                                    color:
                                        Colors.transparent,
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        15,
                                      ),
                                      onTap: () async {
                                        Navigator.of(
                                          sheetContext,
                                        ).pop();

                                        await Future.delayed(
                                          const Duration(
                                            milliseconds:
                                                100,
                                          ),
                                        );

                                        if (!context
                                            .mounted) {
                                          return;
                                        }

                                        await _playSong(
                                          context,
                                          song,
                                          openPlayer:
                                              true,
                                        );
                                      },
                                      child: Container(
                                        padding:
                                            const EdgeInsets
                                                .all(8),
                                        decoration:
                                            BoxDecoration(
                                          color: isDark
                                              ? const Color(
                                                  0xFF17131F,
                                                )
                                              : const Color(
                                                  0xFFF7F3FA,
                                                ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            15,
                                          ),
                                          border:
                                              Border.all(
                                            color: isDark
                                                ? const Color(
                                                    0xFF2C2535,
                                                  )
                                                : const Color(
                                                    0xFFE5DFE9,
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
                                                  _songImage(
                                                song.imagePath,
                                                width:
                                                    50,
                                                height:
                                                    50,
                                              ),
                                            ),

                                            const SizedBox(
                                                width: 10),

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
                                                          primaryText,
                                                      fontSize:
                                                          11,
                                                      fontWeight:
                                                          FontWeight
                                                              .w700,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                          3),
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
                                                          secondaryText,
                                                      fontSize:
                                                          8.5,
                                                    ),
                                                  ),
                                                  if (song
                                                      .album
                                                      .isNotEmpty) ...[
                                                    const SizedBox(
                                                        height:
                                                            2),
                                                    Text(
                                                      song.album,
                                                      maxLines:
                                                          1,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                      style:
                                                          TextStyle(
                                                        color:
                                                            secondaryText,
                                                        fontSize:
                                                            7.5,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),

                                            const SizedBox(
                                                width: 8),

                                            // PLAY BUTTON REMOVED
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ALL PLAYLISTS
  // ============================================================

  void _showAllPlaylists(
    BuildContext context,
  ) {
    if (allSongs.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final player = PlayerScope.of(context);

        final bool isDark =
            theme.brightness == Brightness.dark;

        final Color primaryText = isDark
            ? Colors.white
            : const Color(0xFF17131D);

        final Color secondaryText = isDark
            ? const Color(0xFF81788D)
            : const Color(0xFF756D7D);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              14,
              18,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryText
                          .withValues(alpha: 0.35),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Popular Playlists',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Choose a playlist',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 14),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount:
                        _playlistNames.length,
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(
                      height: 7,
                    ),
                    itemBuilder:
                        (context, index) {
                      final String name =
                          _playlistNames[index];

                      final List<SongModel>
                          songs =
                          _getPlaylistSongs(
                        player,
                        name,
                        index,
                      );

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        leading: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),
                          child: _songImage(
                            songs.first.imagePath,
                            width: 46,
                            height: 46,
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${songs.length} songs',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 8,
                          ),
                        ),
                        trailing: Icon(
                          Icons
                              .chevron_right_rounded,
                          color: secondaryText,
                        ),
                        onTap: () {
                          Navigator.of(
                            sheetContext,
                          ).pop();

                          Future.delayed(
                            const Duration(
                              milliseconds: 100,
                            ),
                            () {
                              if (!context.mounted) {
                                return;
                              }

                              _showPlaylistSongs(
                                context,
                                name,
                                songs,
                                player,
                                index,
                              );
                            },
                          );
                        },
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

  List<SongModel> _playlistSongsForIndex(
    int index,
  ) {
    if (allSongs.isEmpty) {
      return const <SongModel>[];
    }

    final first =
        allSongs[index % allSongs.length];

    final second =
        allSongs[(index + 1) % allSongs.length];

    final third =
        allSongs[(index + 2) % allSongs.length];

    return [
      first,
      second,
      third,
    ];
  }

  // ============================================================
  // MOOD & VIBES
  // ============================================================

  Widget _buildMoodVibes(
    BuildContext context,
    PlayerController player,
    Color cardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
  ) {
    return SizedBox(
      height: 103,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount: _moods.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final mood = _moods[index];

          final moodSongs = allSongs
              .where(
                (song) => song.tags.contains(
                  mood['tag'] as String,
                ),
              )
              .toList();

          return GestureDetector(
            onTap: () {
              if (moodSongs.isEmpty) return;

              _showMoodSongs(
                context,
                mood['title'] as String,
                moodSongs,
              );
            },
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color:
                          (mood['color'] as Color)
                              .withValues(
                        alpha: 0.13,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      mood['icon'] as IconData,
                      color:
                          mood['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    mood['title'] as String,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${moodSongs.length} songs',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 7.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // MOOD SONG LIST
  // ============================================================

  void _showMoodSongs(
    BuildContext context,
    String moodName,
    List<SongModel> songs,
  ) {
    final theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color sheetColor = isDark
        ? const Color(0xFF100D16)
        : Colors.white;

    final Color primaryText = isDark
        ? Colors.white
        : const Color(0xFF17131D);

    final Color secondaryText = isDark
        ? const Color(0xFF81788D)
        : const Color(0xFF756D7D);

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              14,
              18,
              18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryText
                          .withValues(alpha: 0.35),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '$moodName Vibes',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${songs.length} songs',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 14),

                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: songs.length,
                    separatorBuilder:
                        (context, index) =>
                            const SizedBox(
                      height: 7,
                    ),
                    itemBuilder:
                        (context, index) {
                      final song = songs[index];

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(15),
                          onTap: () async {
                            Navigator.of(
                              sheetContext,
                            ).pop();

                            await Future.delayed(
                              const Duration(
                                milliseconds: 100,
                              ),
                            );

                            if (!context.mounted) {
                              return;
                            }

                            await _playSong(
                              context,
                              song,
                              openPlayer: true,
                            );
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.all(8),
                            decoration:
                                BoxDecoration(
                              color: isDark
                                  ? const Color(
                                      0xFF17131F,
                                    )
                                  : const Color(
                                      0xFFF7F3FA,
                                    ),
                              borderRadius:
                                  BorderRadius.circular(
                                15,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? const Color(
                                        0xFF2C2535,
                                      )
                                    : const Color(
                                        0xFFE5DFE9,
                                      ),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                  child: _songImage(
                                    song.imagePath,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),

                                const SizedBox(
                                    width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        song.title,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            TextStyle(
                                          color:
                                              primaryText,
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 3),
                                      Text(
                                        song.artist,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            TextStyle(
                                          color:
                                              secondaryText,
                                          fontSize: 8.5,
                                        ),
                                      ),
                                      if (song.album
                                          .isNotEmpty) ...[
                                        const SizedBox(
                                            height: 2),
                                        Text(
                                          song.album,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              TextStyle(
                                            color:
                                                secondaryText,
                                            fontSize: 7.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // NO PLAY BUTTON HERE
                              ],
                            ),
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
  // ALL MOODS
  // ============================================================

  void _showAllMoods(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color primaryText = isDark
        ? Colors.white
        : const Color(0xFF17131D);

    final Color secondaryText = isDark
        ? const Color(0xFF81788D)
        : const Color(0xFF756D7D);

    showModalBottomSheet(
      context: context,
      backgroundColor:
          theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              14,
              18,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryText
                          .withValues(alpha: 0.35),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Mood & Vibes',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Choose your listening mood',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 14),

                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 9,
                      crossAxisSpacing: 9,
                      childAspectRatio: 2.7,
                    ),
                    itemCount: _moods.length,
                    itemBuilder:
                        (context, index) {
                      final mood =
                          _moods[index];

                      final moodSongs =
                          allSongs
                              .where(
                                (song) =>
                                    song.tags.contains(
                                  mood['tag']
                                      as String,
                                ),
                              )
                              .toList();

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(
                            sheetContext,
                          ).pop();

                          Future.delayed(
                            const Duration(
                              milliseconds: 100,
                            ),
                            () {
                              if (!context.mounted) {
                                return;
                              }

                              _showMoodSongs(
                                context,
                                mood['title']
                                    as String,
                                moodSongs,
                              );
                            },
                          );
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(
                                    0xFF17131F,
                                  )
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? const Color(
                                      0xFF2C2535,
                                    )
                                  : const Color(
                                      0xFFE5DFE9,
                                    ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      (mood['color']
                                              as Color)
                                          .withValues(
                                    alpha: 0.13,
                                  ),
                                  shape:
                                      BoxShape.circle,
                                ),
                                child: Icon(
                                  mood['icon']
                                      as IconData,
                                  color:
                                      mood['color']
                                          as Color,
                                  size: 17,
                                ),
                              ),
                              const SizedBox(
                                  width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      mood['title']
                                          as String,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          TextStyle(
                                        color:
                                            primaryText,
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 2),
                                    Text(
                                      '${moodSongs.length} songs',
                                      style:
                                          TextStyle(
                                        color:
                                            secondaryText,
                                        fontSize: 7.5,
                                      ),
                                    ),
                                  ],
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
  // RECOMMENDED
  // ============================================================

  Widget _buildRecommended(
    BuildContext context,
    PlayerController player,
    Color cardColor,
    Color selectedCardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
    Color tertiaryText,
  ) {
    final songs = allSongs.length > 5
        ? allSongs.take(5).toList()
        : allSongs;

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount: songs.length,
        separatorBuilder:
            (context, index) =>
                const SizedBox(width: 9),
        itemBuilder: (context, index) {
          return _recommendedCompactTile(
            context,
            player,
            songs[index],
            cardColor,
            selectedCardColor,
            borderColor,
            primaryText,
            secondaryText,
            tertiaryText,
          );
        },
      ),
    );
  }

  Widget _recommendedCompactTile(
    BuildContext context,
    PlayerController player,
    SongModel song,
    Color cardColor,
    Color selectedCardColor,
    Color borderColor,
    Color primaryText,
    Color secondaryText,
    Color tertiaryText,
  ) {
    final bool current =
        player.currentSongData.id ==
            song.id;

    return GestureDetector(
      onTap: () {
        _playSong(
          context,
          song,
          openPlayer: true,
        );
      },
      child: Container(
        width: 235,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: current
              ? selectedCardColor
              : cardColor,
          borderRadius:
              BorderRadius.circular(15),
          border: Border.all(
            color: current
                ? const Color(0xFF493064)
                : borderColor,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),
              child: _songImage(
                song.imagePath,
                width: 56,
                height: 56,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 8.5,
                    ),
                  ),
                  if (song.album.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      song.album,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tertiaryText,
                        fontSize: 7.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current &&
                        player.isPlaying
                    ? const Color(0xFF7A45C4)
                    : const Color(0xFF1B1624),
                border: Border.all(
                  color:
                      const Color(0xFF3B3046),
                ),
              ),
              child: Icon(
                current && player.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _songImage(
    String path, {
    required double width,
    required double height,
  }) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB77CFF),
                Color(0xFF7138C8),
                Color(0xFF241039),
              ],
            ),
          ),
          child: const Icon(
            Icons.music_note_rounded,
            color: Colors.white,
            size: 30,
          ),
        );
      },
    );
  }

  // ============================================================
  // PLAY CIRCLE
  // ============================================================

  Widget _playCircle({
    required bool isPlaying,
  }) {
    return Container(
      width: 33,
      height: 33,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFB77CFF),
            Color(0xFF7138C8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x553F1675),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isPlaying
            ? Icons.pause_rounded
            : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  // ============================================================
  // OPEN ALL SONGS
  // ============================================================

  void _openAllSongs(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const LibraryScreen(
          initialFilter: 2,
        ),
      ),
    );
  }
}

// ================================================================
// EQUALIZER BARS
// ================================================================

class _EqualizerBars extends StatelessWidget {
  final Animation<double> animation;

  const _EqualizerBars({
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = animation.value;

        return SizedBox(
          width: 21,
          height: 21,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              _bar(7 + (value * 8)),
              _bar(13 - (value * 7)),
              _bar(10 + (value * 10)),
            ],
          ),
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFB77CFF),
        borderRadius:
            BorderRadius.circular(5),
      ),
    );
  }
}

