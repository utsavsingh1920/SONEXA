import 'package:flutter/material.dart';

import '../data/lyrics_data.dart';
import '../player/player_scope.dart';

class LyricsScreen extends StatelessWidget {
  const LyricsScreen({super.key});

  // ============================================================
  // THEME HELPERS
  // ============================================================

  static bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color _backgroundColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF080812)
        : const Color(0xFFF7F5FA);
  }

  static Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF100D17)
        : const Color(0xFFFFFFFF);
  }

  static Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? Colors.white
        : const Color(0xFF18151D);
  }

  static Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF9D96A8)
        : const Color(0xFF6F6878);
  }

  static Color _mutedText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF777080)
        : const Color(0xFF777080);
  }

  static Color _topButtonColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF17131F)
        : const Color(0xFFFFFFFF);
  }

  static Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF292231)
        : const Color(0xFFE3DDEB);
  }

  static Color _iconColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFB9B2C3)
        : const Color(0xFF625B6B);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        // ========================================================
        // CURRENT SONG INFORMATION
        // ========================================================

        final String songTitle = player.currentSong;
        final String songArtist = player.currentArtist;
        final String songImage = player.currentImage;

        // ========================================================
        // CURRENT SONG LYRICS
        // ========================================================

        final List<String> lyrics =
            getLyricsForSong(songTitle);

        return Scaffold(
          backgroundColor: _backgroundColor(context),

          body: SafeArea(
            child: Column(
              children: [
                // ==================================================
                // TOP BAR
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    8,
                  ),
                  child: Row(
                    children: [
                      _topButton(
                        context,
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),

                      Expanded(
                        child: Center(
                          child: Text(
                            'LYRICS',
                            style: TextStyle(
                              color: _secondaryText(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ),
                      ),

                      _topButton(
                        context,
                        icon: Icons.more_vert_rounded,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // SONG HEADER
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    14,
                    22,
                    0,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          songImage,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return _imageFallback(context);
                          },
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              songTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _primaryText(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              songArtist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _secondaryText(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      AnimatedOpacity(
                        opacity: player.isPlaying ? 1 : 0.35,
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Color(0xFFB77CFF),
                          size: 23,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // LYRICS CARD
                // ==================================================

                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      12,
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      24,
                      22,
                      20,
                    ),
                    decoration: BoxDecoration(
                      color: _cardColor(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _borderColor(context),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isDark(context)
                                ? 0.20
                                : 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: lyrics.isEmpty
                        ? _emptyLyrics(context)
                        : SingleChildScrollView(
                            physics:
                                const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 12),

                                for (
                                  int index = 0;
                                  index < lyrics.length;
                                  index++
                                ) ...[
                                  _lyricText(
                                    context,
                                    lyrics[index],
                                    isActive: index == 2,
                                  ),

                                  SizedBox(
                                    height: index == 2
                                        ? 28
                                        : 16,
                                  ),
                                ],

                                const SizedBox(height: 25),

                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isDark(context)
                                        ? const Color(0xFF17131F)
                                        : const Color(0xFFF2EEF7),
                                    border: Border.all(
                                      color:
                                          _borderColor(context),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    color: _isDark(context)
                                        ? const Color(0xFF6C6378)
                                        : const Color(0xFF8A8294),
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(height: 25),
                              ],
                            ),
                          ),
                  ),
                ),

                // ==================================================
                // PLAYBACK CONTROLS
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    28,
                    0,
                    28,
                    10,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      // PREVIOUS
                      IconButton(
                        onPressed: player.previousSong,
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: _iconColor(context),
                          size: 27,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // PLAY / PAUSE
                      GestureDetector(
                        onTap: player.togglePlayPause,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration:
                              const BoxDecoration(
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
                                color: Color(0x443F1675),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            player.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // NEXT
                      IconButton(
                        onPressed: player.nextSong,
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: _iconColor(context),
                          size: 27,
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
  // IMAGE FALLBACK
  // ============================================================

  static Widget _imageFallback(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
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
        size: 27,
      ),
    );
  }

  // ============================================================
  // EMPTY LYRICS
  // ============================================================

  static Widget _emptyLyrics(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lyrics_outlined,
              color: _isDark(context)
                  ? const Color(0xFF514A5C)
                  : const Color(0xFF8A8294),
              size: 55,
            ),

            const SizedBox(height: 16),

            Text(
              'Lyrics unavailable',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Lyrics are not available for this song.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _mutedText(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LYRIC TEXT
  // ============================================================

  static Widget _lyricText(
    BuildContext context,
    String text, {
    required bool isActive,
  }) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        color: isActive
            ? const Color(0xFFD2B5FF)
            : _mutedText(context),
        fontSize: isActive ? 23 : 19,
        fontWeight: isActive
            ? FontWeight.w800
            : FontWeight.w600,
        height: 1.55,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  // ============================================================
  // TOP BUTTON
  // ============================================================

  static Widget _topButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _topButtonColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _borderColor(context),
          ),
        ),
        child: Icon(
          icon,
          color: _iconColor(context),
          size: 20,
        ),
      ),
    );
  }
}