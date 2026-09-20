import 'package:flutter/material.dart';

import '../data/lyrics_data.dart';
import '../player/player_scope.dart';
import '../services/lyrics_api_service.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final Map<String, Future<LyricsResult>> _requests =
      <String, Future<LyricsResult>>{};

  Future<LyricsResult> _lyricsRequest({
    required String title,
    required String artist,
    required String album,
    required int duration,
  }) {
    final List<String> localLyrics = getLyricsForSong(title);
    if (localLyrics.isNotEmpty) {
      return Future<LyricsResult>.value(
        LyricsResult(
          lines: localLyrics,
          isSynced: false,
          source: 'SONEXA local catalogue',
        ),
      );
    }

    final String key =
        '${title.trim().toLowerCase()}|${artist.trim().toLowerCase()}';
    return _requests.putIfAbsent(
      key,
      () => LyricsApiService.instance.fetchLyrics(
        title: title,
        artist: artist,
        album: album,
        durationSeconds: duration,
      ),
    );
  }

  // ============================================================
  // THEME HELPERS
  // ============================================================

  static bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color _backgroundColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF080812) : const Color(0xFFF7F5FA);
  }

  static Color _cardColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF100D17) : const Color(0xFFFFFFFF);
  }

  static Color _primaryText(BuildContext context) {
    return _isDark(context) ? Colors.white : const Color(0xFF18151D);
  }

  static Color _secondaryText(BuildContext context) {
    return _isDark(context) ? const Color(0xFF9D96A8) : const Color(0xFF6F6878);
  }

  static Color _mutedText(BuildContext context) {
    return _isDark(context) ? const Color(0xFF777080) : const Color(0xFF777080);
  }

  static Color _topButtonColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF17131F) : const Color(0xFFFFFFFF);
  }

  static Color _borderColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFF292231) : const Color(0xFFE3DDEB);
  }

  static Color _iconColor(BuildContext context) {
    return _isDark(context) ? const Color(0xFFB9B2C3) : const Color(0xFF625B6B);
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

        final currentSong = player.currentSongData;
        final String songTitle = currentSong.title;
        final String songArtist = currentSong.artist;
        final String songImage = currentSong.imagePath;

        // ========================================================
        // CURRENT SONG LYRICS
        // ========================================================

        final Future<LyricsResult> lyricsFuture = _lyricsRequest(
          title: songTitle,
          artist: songArtist,
          album: currentSong.album,
          duration: currentSong.duration,
        );

        return Scaffold(
          backgroundColor: _backgroundColor(context),

          body: SafeArea(
            child: Column(
              children: [
                // ==================================================
                // TOP BAR
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                        icon: Icons.info_outline_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  'Local lyrics pehle check hote hain; baaki tracks ke lyrics online load hote hain.',
                                ),
                              ),
                            );
                        },
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // SONG HEADER
                // ==================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _songArtwork(context, songImage),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                        duration: const Duration(milliseconds: 200),
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
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                    decoration: BoxDecoration(
                      color: _cardColor(context),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _borderColor(context)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isDark(context) ? 0.20 : 0.08,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FutureBuilder<LyricsResult>(
                      future: lyricsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return _loadingLyrics(context);
                        }

                        final LyricsResult result =
                            snapshot.data ?? const LyricsResult.unavailable();

                        if (!result.hasLyrics) {
                          return _emptyLyrics(
                            context,
                            message: result.errorMessage,
                          );
                        }

                        final List<String> lyrics = result.lines;
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  isActive: false,
                                ),

                                SizedBox(height: 16),
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
                                    color: _borderColor(context),
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
                        );
                      },
                    ),
                  ),
                ),

                // ==================================================
                // PLAYBACK CONTROLS
                // ==================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFB77CFF), Color(0xFF7138C8)],
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
          colors: [Color(0xFFB77CFF), Color(0xFF7138C8), Color(0xFF241039)],
        ),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 27,
      ),
    );
  }

  static Widget _songArtwork(BuildContext context, String imagePath) {
    final String cleanPath = imagePath.trim();

    if (cleanPath.isEmpty) return _imageFallback(context);

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      final String safeUrl = cleanPath.startsWith('http://')
          ? cleanPath.replaceFirst('http://', 'https://')
          : cleanPath;

      return Image.network(
        safeUrl,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, child, progress) {
          return progress == null ? child : _imageFallback(context);
        },
        errorBuilder: (_, _, _) => _imageFallback(context),
      );
    }

    return Image.asset(
      cleanPath,
      width: 58,
      height: 58,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _imageFallback(context),
    );
  }

  // ============================================================
  // EMPTY LYRICS
  // ============================================================

  static Widget _loadingLyrics(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF9B6BFF),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 16),
          Text(
            'Finding lyrics…',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _emptyLyrics(BuildContext context, {String? message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
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
              message ?? 'Lyrics are not available for this song.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedText(context), fontSize: 12),
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
        color: isActive ? const Color(0xFFD2B5FF) : _mutedText(context),
        fontSize: isActive ? 23 : 19,
        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
        height: 1.55,
      ),
      child: Text(text, textAlign: TextAlign.center),
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
          border: Border.all(color: _borderColor(context)),
        ),
        child: Icon(icon, color: _iconColor(context), size: 20),
      ),
    );
  }
}
