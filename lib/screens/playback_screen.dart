import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';
import 'equalizer_screen.dart';
import 'lyrics_screen.dart';
import 'queue_screen.dart';

class PlaybackScreen extends StatefulWidget {
  final SongModel? selectedSong;

  const PlaybackScreen({
    super.key,
    this.selectedSong,
  });

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  bool _isShuffleOn = false;
  bool _isRepeatOn = false;

  // ============================================================
  // THEME COLORS
  // ============================================================

  static const Color _darkBackground = Color(0xFF0C0814);
  static const Color _lightBackground = Color(0xFFF7F5FA);

  static const Color _purple = Color(0xFF8B5CF6);

  static const Color _darkPrimaryText = Color(0xFFFFFFFF);
  static const Color _lightPrimaryText = Color(0xFF18151D);

  static const Color _darkSecondaryText = Color(0xFFA9A3B0);
  static const Color _lightSecondaryText = Color(0xFF6F6878);

  static const Color _darkCard = Color(0xFF0F0B18);
  static const Color _lightCard = Color(0xFFFFFFFF);

  static const Color _darkBorder = Color(0x1FFFFFFF);
  static const Color _lightBorder = Color(0xFFE3DDEB);

  // ============================================================
  // INIT
  // ============================================================

  @override
void initState() {
  super.initState();

  // Remove keyboard/focus coming from SearchScreen.
  // If PlaybackScreen was opened from a Search result,
  // start that selected song after the screen opens.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!mounted) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final SongModel? selectedSong = widget.selectedSong;

    if (selectedSong == null) {
      return;
    }

    final PlayerController player =
        PlayerScope.of(context);

    await player.playSongModel(selectedSong);
  });
}

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? _darkBackground
        : _lightBackground;
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? _darkPrimaryText
        : _lightPrimaryText;
  }

  Color _secondaryTextColor(BuildContext context) {
    return _isDark(context)
        ? _darkSecondaryText
        : _lightSecondaryText;
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? _darkCard
        : _lightCard;
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? _darkBorder
        : _lightBorder;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final PlayerController player = PlayerScope.of(context);

    return Scaffold(
      // ==========================================================
      // IMPORTANT OVERFLOW FIX
      // ==========================================================

      resizeToAvoidBottomInset: false,

      backgroundColor: _background(context),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedBuilder(
            animation: player,
            builder: (context, _) {
              final SongModel currentSong =
                  player.currentSongData;

              final String title = currentSong.title;
              final String artist = currentSong.artist;
              final String artworkPath = currentSong.imagePath;

              final bool isPlaying = player.isPlaying;
              final bool isLiked = player.isLiked;

              final Duration position = player.position;
              final Duration duration = player.duration;

              final double maxValue =
                  duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1.0;

              double sliderValue =
                  position.inMilliseconds.toDouble();

              if (sliderValue < 0) {
                sliderValue = 0;
              }

              if (sliderValue > maxValue) {
                sliderValue = maxValue;
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final double height = constraints.maxHeight;

                  // =================================================
                  // RESPONSIVE SIZES
                  // =================================================

                  final double topBarHeight =
                      height < 700 ? 62 : 70;

                  final double actionButtonHeight =
                      height < 700 ? 58 : 66;

                  final double controlsHeight =
                      height < 700 ? 78 : 90;

                  final double artworkTopGap =
                      height < 700 ? 6 : 12;

                  const double artworkBottomGap = 36;
                  const double trackInfoHeight = 78;
                  const double progressHeight = 66;
                  const double bottomPadding = 16;

                  // =================================================
                  // FIXED SPACE
                  // =================================================

                  final double fixedSpace =
                      topBarHeight +
                      artworkTopGap +
                      artworkBottomGap +
                      trackInfoHeight +
                      progressHeight +
                      controlsHeight +
                      actionButtonHeight +
                      bottomPadding;

                  // =================================================
                  // ARTWORK SIZE
                  // =================================================

                  final double maxArtworkByWidth = width;

                  final double maxArtworkByHeight = math.max(
                    0,
                    height - fixedSpace,
                  );

                  double artworkSize = math.min(
                    maxArtworkByWidth,
                    maxArtworkByHeight,
                  );

                  final double preferredArtwork =
                      width.clamp(220.0, 500.0);

                  if (artworkSize > preferredArtwork) {
                    artworkSize = preferredArtwork;
                  }

                  // IMPORTANT:
                  // Do not force a minimum artwork size.
                  // This prevents bottom overflow.

                  if (artworkSize < 0) {
                    artworkSize = 0;
                  }

                  if (artworkSize > 500) {
                    artworkSize = 500;
                  }

                  return Column(
                    children: [
                      // =================================================
                      // 1. TOP BAR
                      // =================================================

                      SizedBox(
                        height: topBarHeight,
                        child: Row(
                          children: [
                            // DOWN ARROW
                            SizedBox(
                              width: 48,
                              child: Align(
                                alignment:
                                    Alignment.centerLeft,
                                child: IconButton(
                                  onPressed: () {
                                    FocusManager
                                        .instance
                                        .primaryFocus
                                        ?.unfocus();

                                    Navigator.of(context).pop();
                                  },
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons
                                        .keyboard_arrow_down_rounded,
                                    color:
                                        _primaryText(context),
                                    size: 34,
                                  ),
                                ),
                              ),
                            ),

                            // CENTER
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'NOW PLAYING',
                                    style: TextStyle(
                                      color:
                                          _primaryText(context)
                                              .withValues(
                                        alpha: 0.88,
                                      ),
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w800,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    'SONEXA',
                                    style: TextStyle(
                                      color:
                                          _primaryText(context),
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // MORE
                            SizedBox(
                              width: 48,
                              child: Align(
                                alignment:
                                    Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () {
                                    _showSongMenu(
                                      context,
                                      player,
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    color:
                                        _primaryText(context),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // 2. ALBUM ARTWORK
                      // =================================================

                      Padding(
                        padding: EdgeInsets.only(
                          top: artworkTopGap,
                        ),
                        child: SizedBox(
                          width: artworkSize,
                          height: artworkSize,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(
                                    alpha: _isDark(context)
                                        ? 0.55
                                        : 0.18,
                                  ),
                                  blurRadius: 28,
                                  spreadRadius: 1,
                                  offset:
                                      const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(32),
                              child: _Artwork(
                                key: ValueKey(artworkPath),
                                imagePath: artworkPath,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // =================================================
                      // 3. GAP AFTER ARTWORK
                      // =================================================

                      const SizedBox(height: 36),

                      // =================================================
                      // 4-6. CONTENT
                      // =================================================

                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: Column(
                          children: [
                            // ===========================================
                            // 4. TRACK INFO
                            // ===========================================

                            SizedBox(
                              height: trackInfoHeight,
                              child: Row(
                                children: [
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
                                          title,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          textAlign:
                                              TextAlign.left,
                                          style: TextStyle(
                                            color:
                                                _primaryText(
                                              context,
                                            ),
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight.w800,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          artist,
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          textAlign:
                                              TextAlign.left,
                                          style: TextStyle(
                                            color:
                                                _secondaryTextColor(
                                              context,
                                            ),
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w500,
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // LIKE
                                  SizedBox(
                                    width: 52,
                                    child: IconButton(
                                      onPressed: () {
                                        player.toggleLike();
                                      },
                                      padding:
                                          EdgeInsets.zero,
                                      icon: Icon(
                                        isLiked
                                            ? Icons
                                                .favorite_rounded
                                            : Icons
                                                .favorite_border_rounded,
                                        color: isLiked
                                            ? _purple
                                            : _primaryText(
                                                context,
                                              ),
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ===========================================
                            // 5. PROGRESS BAR
                            // ===========================================

                            SizedBox(
                              height: progressHeight,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  SliderTheme(
                                    data:
                                        SliderTheme.of(context)
                                            .copyWith(
                                      trackHeight: 3,
                                      thumbShape:
                                          const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                        overlayRadius: 14,
                                      ),
                                      activeTrackColor:
                                          _purple,
                                      inactiveTrackColor:
                                          _purple.withValues(
                                        alpha:
                                            _isDark(context)
                                                ? 0.18
                                                : 0.22,
                                      ),
                                      thumbColor: _purple,
                                      overlayColor:
                                          _purple.withValues(
                                        alpha: 0.12,
                                      ),
                                    ),
                                    child: Slider(
                                      min: 0,
                                      max: maxValue,
                                      value: sliderValue,
                                      onChanged: duration
                                                  .inMilliseconds <=
                                              0
                                          ? null
                                          : (value) {
                                              player.seekTo(
                                                Duration(
                                                  milliseconds:
                                                      value
                                                          .round(),
                                                ),
                                              );
                                            },
                                    ),
                                  ),

                                  // TIME
                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 5,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(
                                            position,
                                          ),
                                          style: TextStyle(
                                            color:
                                                _secondaryTextColor(
                                              context,
                                            ),
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(
                                            duration,
                                          ),
                                          style: TextStyle(
                                            color:
                                                _secondaryTextColor(
                                              context,
                                            ),
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ===========================================
                            // 6. PLAYBACK CONTROLS
                            // ===========================================

                            SizedBox(
                              height: controlsHeight,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  // SHUFFLE
                                  _controlIconButton(
                                    icon:
                                        Icons.shuffle_rounded,
                                    color: _isShuffleOn
                                        ? _purple
                                        : _primaryText(
                                            context,
                                          ),
                                    size: 25,
                                    onTap: () {
                                      setState(() {
                                        _isShuffleOn =
                                            !_isShuffleOn;
                                      });
                                    },
                                  ),

                                  // PREVIOUS
                                  _controlIconButton(
                                    icon: Icons
                                        .skip_previous_rounded,
                                    color:
                                        _primaryText(context),
                                    size: 37,
                                    onTap: () {
                                      player.previousSong();
                                    },
                                  ),

                                  // PLAY / PAUSE
                                  GestureDetector(
                                    onTap: () {
                                      player
                                          .togglePlayPause();
                                    },
                                    child: Container(
                                      width: height < 700
                                          ? 66
                                          : 74,
                                      height: height < 700
                                          ? 66
                                          : 74,
                                      decoration:
                                          BoxDecoration(
                                        shape:
                                            BoxShape.circle,
                                        color: _purple,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _purple
                                                .withValues(
                                              alpha: 0.38,
                                            ),
                                            blurRadius: 25,
                                            spreadRadius: 2,
                                            offset:
                                                const Offset(
                                              0,
                                              8,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isPlaying
                                            ? Icons
                                                .pause_rounded
                                            : Icons
                                                .play_arrow_rounded,
                                        color: Colors.white,
                                        size: height < 700
                                            ? 36
                                            : 40,
                                      ),
                                    ),
                                  ),

                                  // NEXT
                                  _controlIconButton(
                                    icon:
                                        Icons.skip_next_rounded,
                                    color:
                                        _primaryText(context),
                                    size: 37,
                                    onTap: () {
                                      player.nextSong();
                                    },
                                  ),

                                  // REPEAT
                                  _controlIconButton(
                                    icon:
                                        Icons.repeat_rounded,
                                    color: _isRepeatOn
                                        ? _purple
                                        : _primaryText(
                                            context,
                                          ),
                                    size: 25,
                                    onTap: () {
                                      setState(() {
                                        _isRepeatOn =
                                            !_isRepeatOn;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // 7. BOTTOM ACTION PILLS
                      // =================================================

                      SizedBox(
                        height: actionButtonHeight,
                        child: Row(
                          children: [
                            // QUEUE
                            Expanded(
                              child: _extraButton(
                                context,
                                icon: Icons
                                    .queue_music_rounded,
                                title: 'Queue',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const QueueScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            // LYRICS
                            Expanded(
                              child: _extraButton(
                                context,
                                icon: Icons.lyrics_rounded,
                                title: 'Lyrics',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LyricsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            // EQUALIZER
                            Expanded(
                              child: _extraButton(
                                context,
                                icon: Icons
                                    .equalizer_rounded,
                                title: 'Equalizer',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const EqualizerScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // =================================================
                      // 8. BOTTOM SAFE SPACE
                      // =================================================

                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // CONTROL BUTTON
  // =========================================================================

  Widget _controlIconButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }

  // =========================================================================
  // BOTTOM ACTION BUTTON
  // =========================================================================

  Widget _extraButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor(context),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: _purple,
                size: 23,
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SONG MENU
  // =========================================================================

  void _showSongMenu(
    BuildContext context,
    PlayerController player,
  ) {
    final bool dark = _isDark(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: dark
          ? const Color(0xFF15101D)
          : const Color(0xFFFFFFFF),
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              4,
              16,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =========================================================
                // ADD TO QUEUE
                // =========================================================

                ListTile(
                  leading: const Icon(
                    Icons.queue_music_rounded,
                    color: _purple,
                  ),
                  title: Text(
                    'Add to Queue',
                    style: TextStyle(
                      color: _primaryText(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    final SongModel song =
                        player.currentSongData;

                    player.addToQueue(song);

                    Navigator.of(sheetContext).pop();

                    ScaffoldMessenger.of(context)
                        .hideCurrentSnackBar();

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          '${song.title} added to queue',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: dark
                            ? const Color(0xFF21182C)
                            : const Color(0xFF6D3DB8),
                        behavior:
                            SnackBarBehavior.floating,
                        duration:
                            const Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                // =========================================================
                // LIKE
                // =========================================================

                ListTile(
                  leading: const Icon(
                    Icons.favorite_rounded,
                    color: _purple,
                  ),
                  title: Text(
                    player.isLiked
                        ? 'Remove from Liked Songs'
                        : 'Add to Liked Songs',
                    style: TextStyle(
                      color: _primaryText(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    player.toggleLike();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // DURATION FORMAT
  // =========================================================================

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds <= 0) {
      return '0:00';
    }

    final int minutes = duration.inMinutes;

    final int seconds =
        duration.inSeconds.remainder(60);

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// ARTWORK
// ============================================================================

class _Artwork extends StatelessWidget {
  const _Artwork({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath.trim().isEmpty) {
      return _fallback();
    }

    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _fallback();
        },
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return _fallback();
      },
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF3B176D),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white,
          size: 90,
        ),
      ),
    );
  }
}