import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/songs_data.dart';
import '../models/song_model.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';
import 'playback_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  bool _isFocused = false;

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
      colors: [
        Color(0xFF8B5CF6),
        Color(0xFF4C1D95),
      ],
    ),
    _ArtistData(
      name: 'Rahat Fateh Ali Khan',
      imagePath:
          'assets/images/artists/rahat_fateh_ali_khan.jpg',
      colors: [
        Color(0xFFFF4B2B),
        Color(0xFFB31217),
      ],
    ),
    _ArtistData(
      name: 'Mohit Chauhan',
      imagePath:
          'assets/images/artists/mohit_chauhan.jpg',
      colors: [
        Color(0xFF64748B),
        Color(0xFF1E293B),
      ],
    ),
    _ArtistData(
      name: 'Atif Aslam',
      imagePath:
          'assets/images/artists/atif_aslam.jpg',
      colors: [
        Color(0xFF0F9BA8),
        Color(0xFF075985),
      ],
    ),
    _ArtistData(
      name: 'Javed Bashir',
      imagePath:
          'assets/images/artists/javed_bashir.jpg',
      colors: [
        Color(0xFF64748B),
        Color(0xFF334155),
      ],
    ),
  ];

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<_CategoryData> _categories = const [
    _CategoryData(
      title: 'Trending',
      icon: Icons.local_fire_department_rounded,
      colors: [
        Color(0xFFFF7043),
        Color(0xFFD84315),
      ],
      searchValue: 'Bollywood',
    ),
    _CategoryData(
      title: 'Bollywood',
      icon: Icons.movie_creation_rounded,
      colors: [
        Color(0xFFEF4444),
        Color(0xFFB91C1C),
      ],
      searchValue: 'Bollywood',
    ),
    _CategoryData(
      title: 'Romantic',
      icon: Icons.favorite_rounded,
      colors: [
        Color(0xFFF43F5E),
        Color(0xFFBE123C),
      ],
      searchValue: 'Romantic',
    ),
    _CategoryData(
      title: 'Chill',
      icon: Icons.nightlight_round,
      colors: [
        Color(0xFF3B82F6),
        Color(0xFF1D4ED8),
      ],
      searchValue: 'Chill',
    ),
    _CategoryData(
      title: 'Workout',
      icon: Icons.fitness_center_rounded,
      colors: [
        Color(0xFFF97316),
        Color(0xFFC2410C),
      ],
      searchValue: 'Workout',
    ),
    _CategoryData(
      title: 'Hip-Hop',
      icon: Icons.graphic_eq_rounded,
      colors: [
        Color(0xFFE11D48),
        Color(0xFF9F1239),
      ],
      searchValue: 'Hip-Hop',
    ),
    _CategoryData(
      title: 'Pop',
      icon: Icons.music_note_rounded,
      colors: [
        Color(0xFF8B20F5),
        Color(0xFF5E18D0),
      ],
      searchValue: 'Pop',
    ),
    _CategoryData(
      title: 'Lo-Fi',
      icon: Icons.headphones_rounded,
      colors: [
        Color(0xFF7C3AED),
        Color(0xFF4C1D95),
      ],
      searchValue: 'Lo-Fi',
    ),
    _CategoryData(
      title: 'Punjabi',
      icon: Icons.mic_rounded,
      colors: [
        Color(0xFFF59E0B),
        Color(0xFFD97706),
      ],
      searchValue: 'Punjabi',
    ),
    _CategoryData(
      title: 'Classical',
      icon: Icons.piano_rounded,
      colors: [
        Color(0xFF0891B2),
        Color(0xFF155E75),
      ],
      searchValue: 'Classical',
    ),
    _CategoryData(
      title: 'Indie',
      icon: Icons.album_rounded,
      colors: [
        Color(0xFFEC4899),
        Color(0xFF9D174D),
      ],
      searchValue: 'Indie',
    ),
    _CategoryData(
      title: 'Party',
      icon: Icons.celebration_rounded,
      colors: [
        Color(0xFFA855F7),
        Color(0xFF6D28D9),
      ],
      searchValue: 'Party',
    ),
    _CategoryData(
      title: 'Sad',
      icon: Icons.sentiment_dissatisfied_rounded,
      colors: [
        Color(0xFF6366F1),
        Color(0xFF3730A3),
      ],
      searchValue: 'Sad',
    ),
    _CategoryData(
      title: 'Dance',
      icon: Icons.directions_run_rounded,
      colors: [
        Color(0xFFD946EF),
        Color(0xFF86198F),
      ],
      searchValue: 'Dance',
    ),
    _CategoryData(
      title: 'Devotional',
      icon: Icons.auto_awesome_rounded,
      colors: [
        Color(0xFFF59E0B),
        Color(0xFF92400E),
      ],
      searchValue: 'Devotional',
    ),
    _CategoryData(
      title: 'Jazz',
      icon: Icons.speaker_rounded,
      colors: [
        Color(0xFF14B8A6),
        Color(0xFF115E59),
      ],
      searchValue: 'Jazz',
    ),
    _CategoryData(
      title: 'Electronic',
      icon: Icons.bolt_rounded,
      colors: [
        Color(0xFF06B6D4),
        Color(0xFF155E75),
      ],
      searchValue: 'Electronic',
    ),
    _CategoryData(
      title: 'Acoustic',
      icon: Icons.music_note_rounded,
      colors: [
        Color(0xFF84CC16),
        Color(0xFF3F6212),
      ],
      searchValue: 'Acoustic',
    ),
    _CategoryData(
      title: '90s Hits',
      icon: Icons.album_rounded,
      colors: [
        Color(0xFF9333EA),
        Color(0xFF581C87),
      ],
      searchValue: '90s Hits',
    ),
    _CategoryData(
      title: 'K-Pop',
      icon: Icons.star_rounded,
      colors: [
        Color(0xFFF472B6),
        Color(0xFF9D174D),
      ],
      searchValue: 'K-Pop',
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

    setState(() {});
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
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
  // FILTER SONGS
  // ============================================================

  List<SongModel> get _filteredSongs {
    final String query =
        _query.toLowerCase().trim();

    if (query.isEmpty) {
      return [];
    }

    return allSongs.where((song) {
      final String title =
          song.title.toLowerCase();

      final String artist =
          song.artist.toLowerCase();

      final String album =
          song.album.toLowerCase();

      final String tags = song.tags
          .map(
            (tag) => tag.toLowerCase(),
          )
          .join(' ');

      return title.contains(query) ||
          artist.contains(query) ||
          album.contains(query) ||
          tags.contains(query);
    }).toList();
  }

  // ============================================================
  // KEYBOARD
  // ============================================================

  void _hideKeyboard() {
    _searchFocusNode.unfocus();

    FocusManager.instance.primaryFocus?.unfocus();

    SystemChannels.textInput.invokeMethod<void>(
      'TextInput.hide',
    );
  }

  void _showKeyboard() {
    if (!mounted) return;

    _searchFocusNode.requestFocus();
  }

  // ============================================================
  // SEARCH ACTIONS
  // ============================================================

  void _clearSearch() {
    _searchController.clear();

    _showKeyboard();
  }

  void _closeSearch() {
    _searchController.clear();

    _hideKeyboard();
  }

  void _addRecentSearch(String value) {
    final String search = value.trim();

    if (search.isEmpty) return;
    if (!mounted) return;

    setState(() {
      _recentSearches.removeWhere(
        (item) =>
            item.toLowerCase() ==
            search.toLowerCase(),
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

  void _setSearch(String value) {
    final String search = value.trim();

    if (search.isEmpty) return;

    _addRecentSearch(search);

    _searchController.value =
        TextEditingValue(
      text: search,
      selection:
          TextSelection.collapsed(
        offset: search.length,
      ),
    );

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
      final PlayerController player =
          PlayerScope.of(context);

      await player.playSongModel(song);
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

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlaybackScreen(
            selectedSong: song,
          ),
        ),
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

    await _playSong(
      context,
      songs.first,
      openPlayer: true,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final Color textColor =
        theme.colorScheme.onSurface;

    final Color secondaryText =
        textColor.withValues(alpha: 0.62);

    final bool showRecent =
        _isFocused &&
        !_hasQuery &&
        _recentSearches.isNotEmpty;

    final List<SongModel> results =
        _filteredSongs;

    // ==========================================================
    // KEYBOARD SAFE BOTTOM SPACE
    // ==========================================================

    final double keyboardHeight =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    final double bottomPadding =
        keyboardHeight > 0
            ? keyboardHeight + 24
            : 140;

    return PopScope(
      canPop:
          !_hasQuery && !_isFocused,

      onPopInvokedWithResult:
          (bool didPop, dynamic result) {
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

        backgroundColor:
            theme.scaffoldBackgroundColor,

        body: SafeArea(
          child: ListView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior
                    .onDrag,

            physics:
                const BouncingScrollPhysics(),

            padding:
                EdgeInsets.fromLTRB(
              16,
              18,
              16,
              bottomPadding,
            ),

            children: [
              // ==================================================
              // TITLE
              // ==================================================

              Text(
                'Search',
                textAlign:
                    TextAlign.left,
                style: TextStyle(
                  color: textColor,
                  fontSize: 27,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // SEARCH BOX
              // ==================================================

              _SearchBox(
                controller:
                    _searchController,
                focusNode:
                    _searchFocusNode,
                isFocused:
                    _isFocused,
                showRecent:
                    showRecent,
                recentSearches:
                    _recentSearches,
                onClear:
                    _clearSearch,
                onClose:
                    _closeSearch,
                onRecentTap:
                    _setSearch,
                onClearRecent:
                    _clearRecentSearches,
              ),

              // ==================================================
              // HOME SEARCH CONTENT
              // ==================================================

              if (!_hasQuery) ...[
                const SizedBox(
                  height: 16,
                ),

                const _SectionTitle(
                  title:
                      'Trending Searches',
                ),

                const SizedBox(
                  height: 7,
                ),

                // ==================================================
                // TRENDING SEARCHES
                // ==================================================

                SizedBox(
                  height: 36,

                  child: ListView.separated(
                    scrollDirection:
                        Axis.horizontal,

                    physics:
                        const BouncingScrollPhysics(),

                    padding:
                        const EdgeInsets.only(
                      right: 4,
                    ),

                    itemCount:
                        _trendingSearches
                            .length,

                    separatorBuilder:
                        (context, index) {
                      return const SizedBox(
                        width: 7,
                      );
                    },

                    itemBuilder:
                        (context, index) {
                      final String item =
                          _trendingSearches[
                              index];

                      return GestureDetector(
                        onTap: () {
                          _setSearch(item);
                        },

                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                          ),

                          decoration:
                              BoxDecoration(
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              19,
                            ),

                            border:
                                Border.all(
                              color:
                                  theme.dividerColor,
                            ),
                          ),

                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [
                              const Icon(
                                Icons
                                    .trending_up_rounded,
                                color:
                                    Color(
                                  0xFFA855F7,
                                ),
                                size: 15,
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              Text(
                                item,
                                style:
                                    TextStyle(
                                  color:
                                      secondaryText,
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 17,
                ),

                // ==================================================
                // POPULAR ARTISTS
                // ==================================================

                Row(
                  children: [
                    const Expanded(
                      child:
                          _SectionTitle(
                        title:
                            'Popular Artists',
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        _setSearch(
                          'Arijit Singh',
                        );
                      },

                      child: const Text(
                        'See all',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFFB77CFF,
                          ),
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                SizedBox(
                  height: 91,

                  child: ListView.separated(
                    scrollDirection:
                        Axis.horizontal,

                    physics:
                        const BouncingScrollPhysics(),

                    padding:
                        const EdgeInsets.only(
                      right: 4,
                    ),

                    itemCount:
                        _artists.length,

                    separatorBuilder:
                        (context, index) {
                      return const SizedBox(
                        width: 10,
                      );
                    },

                    itemBuilder:
                        (context, index) {
                      final _ArtistData artist =
                          _artists[index];

                      return GestureDetector(
                        onTap: () {
                          _setSearch(
                            artist.name,
                          );
                        },

                        child: SizedBox(
                          width: 78,

                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,

                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape
                                          .circle,

                                  gradient:
                                      LinearGradient(
                                    begin:
                                        Alignment
                                            .topLeft,
                                    end:
                                        Alignment
                                            .bottomRight,
                                    colors:
                                        artist
                                            .colors,
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: artist
                                          .colors
                                          .first
                                          .withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius:
                                          9,
                                      offset:
                                          const Offset(
                                        0,
                                        3,
                                      ),
                                    ),
                                  ],
                                ),

                                padding:
                                    const EdgeInsets
                                        .all(2),

                                child:
                                    ClipOval(
                                  child:
                                      Image.asset(
                                    artist
                                        .imagePath,

                                    width: 56,
                                    height: 56,

                                    fit: BoxFit
                                        .cover,

                                    errorBuilder:
                                        (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        decoration:
                                            BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,

                                          gradient:
                                              LinearGradient(
                                            colors:
                                                artist
                                                    .colors,
                                          ),
                                        ),

                                        child:
                                            const Icon(
                                          Icons
                                              .person_rounded,
                                          color:
                                              Colors
                                                  .white,
                                          size: 28,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                artist.name,

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                textAlign:
                                    TextAlign
                                        .center,

                                style:
                                    TextStyle(
                                  color:
                                      textColor
                                          .withValues(
                                    alpha:
                                        0.78,
                                  ),
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                // ==================================================
                // CATEGORIES
                // ==================================================

                const _SectionTitle(
                  title:
                      'Browse All Categories',
                ),

                const SizedBox(
                  height: 8,
                ),

                GridView.builder(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  itemCount:
                      _categories.length,

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 9,
                    mainAxisExtent: 84,
                  ),

                  itemBuilder:
                      (context, index) {
                    final _CategoryData
                        category =
                        _categories[index];

                    return _CategoryCard(
                      category:
                          category,

                      onTap: () {
                        _setSearch(
                          category
                              .searchValue,
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

                  onPlay: (song) {
                    _playSong(
                      context,
                      song,
                    );
                  },

                  onPlayAll: () {
                    _playAllResults(
                      context,
                      results,
                    );
                  },
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
    final ThemeData theme =
        Theme.of(context);

    final Color textColor =
        theme.colorScheme.onSurface;

    final Color secondaryText =
        textColor.withValues(
      alpha: 0.62,
    );

    final Color searchSurface =
        theme.colorScheme.surface;

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 220,
      ),

      curve:
          Curves.easeOutCubic,

      decoration:
          BoxDecoration(
        color: showRecent
            ? searchSurface
            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(18),

        border: showRecent
            ? Border.all(
                color:
                    theme.dividerColor,
              )
            : null,

        boxShadow: showRecent
            ? [
                BoxShadow(
                  color: theme
                      .colorScheme
                      .primary
                      .withValues(
                    alpha: 0.07,
                  ),
                  blurRadius: 18,
                  offset:
                      const Offset(0, 6),
                ),
              ]
            : null,
      ),

      child: Column(
        children: [
          Container(
            height: 48,

            decoration:
                BoxDecoration(
              color: searchSurface,

              borderRadius:
                  showRecent
                      ? const BorderRadius
                          .vertical(
                          top:
                              Radius.circular(
                            18,
                          ),
                        )
                      : BorderRadius
                          .circular(
                          18,
                        ),

              border: showRecent
                  ? null
                  : Border.all(
                      color:
                          theme.dividerColor,
                    ),

              boxShadow: showRecent
                  ? null
                  : [
                      BoxShadow(
                        color: theme
                            .colorScheme
                            .primary
                            .withValues(
                          alpha: 0.06,
                        ),
                        blurRadius: 14,
                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
            ),

            child: TextField(
              controller:
                  controller,

              focusNode:
                  focusNode,

              textInputAction:
                  TextInputAction.search,

              keyboardType:
                  TextInputType.text,

              autocorrect: false,

              enableSuggestions:
                  true,

              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight:
                    FontWeight.w500,
              ),

              cursorColor:
                  const Color(
                0xFFA855F7,
              ),

              onSubmitted: (_) {
                _hideKeyboardFromField(
                  focusNode,
                );
              },

              decoration:
                  InputDecoration(
                border:
                    InputBorder.none,

                prefixIcon:
                    const Icon(
                  Icons.search_rounded,
                  color:
                      Color(
                    0xFFA855F7,
                  ),
                  size: 22,
                ),

                suffixIcon:
                    ValueListenableBuilder<
                        TextEditingValue>(
                  valueListenable:
                      controller,

                  builder: (
                    context,
                    value,
                    child,
                  ) {
                    if (value.text
                        .isNotEmpty) {
                      return IconButton(
                        padding:
                            EdgeInsets.zero,

                        onPressed:
                            onClear,

                        tooltip:
                            'Clear search',

                        icon: Icon(
                          Icons
                              .close_rounded,
                          color:
                              secondaryText,
                          size: 19,
                        ),
                      );
                    }

                    if (isFocused) {
                      return IconButton(
                        padding:
                            EdgeInsets.zero,

                        onPressed:
                            onClose,

                        tooltip:
                            'Close search',

                        icon: Icon(
                          Icons
                              .close_rounded,
                          color:
                              secondaryText,
                          size: 19,
                        ),
                      );
                    }

                    return IconButton(
                      padding:
                          EdgeInsets.zero,

                      onPressed: () {
                        focusNode
                            .requestFocus();
                      },

                      tooltip:
                          'Search',

                      icon:
                          const Icon(
                        Icons
                            .mic_none_rounded,
                        color:
                            Color(
                          0xFFA855F7,
                        ),
                        size: 21,
                      ),
                    );
                  },
                ),

                hintText:
                    'Find your next favorite music',

                hintStyle:
                    TextStyle(
                  color: textColor
                      .withValues(
                    alpha: 0.48,
                  ),
                  fontSize: 12.5,
                  fontWeight:
                      FontWeight.w500,
                ),

                contentPadding:
                    const EdgeInsets
                        .symmetric(
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
              padding:
                  const EdgeInsets
                      .fromLTRB(
                9,
                3,
                9,
                8,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      4,
                      6,
                      4,
                      4,
                    ),

                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .history_rounded,
                          color:
                              Color(
                            0xFFA855F7,
                          ),
                          size: 16,
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Expanded(
                          child: Text(
                            'Recent Searches',

                            style:
                                TextStyle(
                              color:
                                  textColor,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap:
                              onClearRecent,

                          child:
                              const Text(
                            'Clear',

                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFFA855F7,
                              ),
                              fontSize: 10,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...recentSearches
                      .take(5)
                      .map(
                        (search) =>
                            _RecentSearchItem(
                          title:
                              search,

                          onTap: () {
                            onRecentTap(
                              search,
                            );
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

  void _hideKeyboardFromField(
    FocusNode node,
  ) {
    node.unfocus();

    FocusManager.instance.primaryFocus
        ?.unfocus();

    SystemChannels.textInput
        .invokeMethod<void>(
      'TextInput.hide',
    );
  }
}

// ============================================================================
// RECENT SEARCH ITEM
// ============================================================================

class _RecentSearchItem
    extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _RecentSearchItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final Color textColor =
        theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius:
            BorderRadius.circular(10),

        onTap: onTap,

        child: Container(
          width: double.infinity,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),

          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color:
                    textColor.withValues(
                  alpha: 0.40,
                ),
                size: 17,
              ),

              const SizedBox(
                width: 9,
              ),

              Expanded(
                child: Text(
                  title,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    color:
                        textColor.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 12.5,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                Icons.north_west_rounded,
                color:
                    textColor.withValues(
                  alpha: 0.40,
                ),
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

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Text(
      title,

      textAlign:
          TextAlign.left,

      style: TextStyle(
        color:
            theme.colorScheme.onSurface,
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

class _CategoryCard
    extends StatelessWidget {
  final _CategoryData category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius:
            BorderRadius.circular(15),

        onTap: onTap,

        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(15),

          child: Container(
            decoration:
                BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                15,
              ),

              gradient:
                  LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors:
                    category.colors,
              ),

              boxShadow: [
                BoxShadow(
                  color: category
                      .colors
                      .first
                      .withValues(
                    alpha: 0.15,
                  ),
                  blurRadius: 8,
                  offset:
                      const Offset(
                    0,
                    3,
                  ),
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

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      color: Colors.white
                          .withValues(
                        alpha: 0.09,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: -23,
                  bottom: -36,

                  child: Container(
                    width: 84,
                    height: 84,

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      color: Colors.black
                          .withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 9,
                  right: 9,

                  child: SizedBox(
                    width: 34,
                    height: 34,

                    child:
                        DecoratedBox(
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.13,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),

                      child: Center(
                        child: Icon(
                          category.icon,
                          color:
                              Colors.white,
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

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing:
                          -0.2,
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

class _SearchResults
    extends StatelessWidget {
  final String query;
  final List<SongModel> songs;
  final Function(SongModel) onPlay;
  final VoidCallback onPlayAll;

  const _SearchResults({
    required this.query,
    required this.songs,
    required this.onPlay,
    required this.onPlayAll,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final Color textColor =
        theme.colorScheme.onSurface;

    if (songs.isEmpty) {
      return _NoSearchResults(
        query: query,
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const SizedBox(
          height: 16,
        ),

        Row(
          children: [
            Expanded(
              child: Text(
                'Search Results',

                style: TextStyle(
                  color: textColor,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),

            Text(
              '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',

              style: TextStyle(
                color:
                    textColor.withValues(
                  alpha: 0.52,
                ),
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        // ==========================================================
        // PLAY FIRST RESULT
        // ==========================================================

        Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius:
                BorderRadius.circular(14),

            onTap: onPlayAll,

            child: Container(
              width: double.infinity,

              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 13,
                vertical: 11,
              ),

              decoration:
                  BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6D28D9),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),

                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF8B5CF6,
                    ).withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 12,
                    offset:
                        const Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,

                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.16,
                      ),

                      shape:
                          BoxShape.circle,
                    ),

                    child:
                        const Icon(
                      Icons
                          .play_arrow_rounded,
                      color:
                          Colors.white,
                      size: 21,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  const Expanded(
                    child: Text(
                      'Play first result',

                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 12.5,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons
                        .chevron_right_rounded,
                    color:
                        Colors.white70,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 9,
        ),

        ...songs.map(
          (song) =>
              _SearchSongTile(
            song: song,

            onTap: () {
              onPlay(song);
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SEARCH SONG TILE
// ============================================================================

class _SearchSongTile
    extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const _SearchSongTile({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final PlayerController player =
        PlayerScope.of(context);

    final Color textColor =
        theme.colorScheme.onSurface;

    final bool isCurrent =
        player.currentSongData.id ==
            song.id;

    final bool isLiked =
        player.isSongLiked(song);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),

      decoration:
          BoxDecoration(
        color: isCurrent
            ? theme
                .colorScheme
                .primary
                .withValues(
              alpha: 0.10,
            )
            : theme
                .colorScheme
                .surface,

        borderRadius:
            BorderRadius.circular(15),

        border: Border.all(
          color: isCurrent
              ? theme
                  .colorScheme
                  .primary
                  .withValues(
                alpha: 0.55,
              )
              : theme.dividerColor,
        ),
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius:
              BorderRadius.circular(
            15,
          ),

          onTap: onTap,

          child: Padding(
            padding:
                const EdgeInsets.all(
              8,
            ),

            child: Row(
              children: [
                // ==================================================
                // SONG IMAGE
                // ==================================================

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),

                  child: Image.asset(
                    song.imagePath,

                    width: 53,
                    height: 53,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        width: 53,
                        height: 53,

                        color: theme
                            .colorScheme
                            .surfaceContainerHighest,

                        child:
                            const Icon(
                          Icons
                              .music_note_rounded,
                          color:
                              Color(
                            0xFFA855F7,
                          ),
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(
                  width: 11,
                ),

                // ==================================================
                // SONG DETAILS
                // ==================================================

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
                          color: isCurrent
                              ? theme
                                  .colorScheme
                                  .primary
                              : textColor,
                          fontSize: 13,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        song.artist,

                        maxLines: 1,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            TextStyle(
                          color: textColor
                              .withValues(
                            alpha: 0.60,
                          ),
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        song.album,

                        maxLines: 1,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            TextStyle(
                          color: textColor
                              .withValues(
                            alpha: 0.40,
                          ),
                          fontSize: 9,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // LIKE
                // ==================================================

                IconButton(
                  visualDensity:
                      VisualDensity
                          .compact,

                  onPressed: () async {
                    await player
                        .toggleLikeSong(
                      song,
                    );
                  },

                  icon: Icon(
                    isLiked
                        ? Icons
                            .favorite_rounded
                        : Icons
                            .favorite_border_rounded,

                    color: isLiked
                        ? theme
                            .colorScheme
                            .primary
                        : textColor
                            .withValues(
                          alpha: 0.48,
                        ),

                    size: 19,
                  ),
                ),

                // ==================================================
                // PLAY BUTTON
                // ==================================================

                Container(
                  width: 36,
                  height: 36,

                  decoration:
                      BoxDecoration(
                    color: theme
                        .colorScheme
                        .primary
                        .withValues(
                      alpha: 0.14,
                    ),

                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      IconButton(
                    padding:
                        EdgeInsets.zero,

                    onPressed: onTap,

                    icon: Icon(
                      isCurrent &&
                              player
                                  .isPlaying
                          ? Icons
                              .graphic_eq_rounded
                          : Icons
                              .play_arrow_rounded,

                      color: theme
                          .colorScheme
                          .primary,

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
// NO SEARCH RESULTS
// ============================================================================

class _NoSearchResults
    extends StatelessWidget {
  final String query;

  const _NoSearchResults({
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final Color textColor =
        theme.colorScheme.onSurface;

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        top: 16,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),

      decoration:
          BoxDecoration(
        color:
            theme.colorScheme.surface,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color:
              theme.dividerColor,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,

            decoration:
                BoxDecoration(
              color: theme
                  .colorScheme
                  .primary
                  .withValues(
                alpha: 0.12,
              ),

              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              Icons
                  .search_off_rounded,

              color: theme
                  .colorScheme
                  .primary,

              size: 30,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            'No songs found',

            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            'We couldn’t find anything for "$query".',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: textColor
                  .withValues(
                alpha: 0.55,
              ),
              fontSize: 11.5,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Try another song, artist or category.',

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color: textColor
                  .withValues(
                alpha: 0.40,
              ),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}