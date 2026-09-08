import 'package:flutter/material.dart';

import '../player/player_scope.dart';
import '../screens/playback_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color surfaceColor =
        colorScheme.surface;

    final Color primaryText =
        colorScheme.onSurface;

    final Color secondaryText =
        colorScheme.onSurfaceVariant;

    // ================================================================
    // THEME-AWARE BORDER
    // Dark Mode  → White 0.07
    // Light Mode → Black 0.14
    // ================================================================

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.14);

    // ================================================================
    // PROGRESS BACKGROUND
    // ================================================================

    final Color progressBackground = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        double progress = 0.0;

        if (player.duration.inMilliseconds > 0) {
          progress =
              player.position.inMilliseconds /
              player.duration.inMilliseconds;

          progress = progress.clamp(
            0.0,
            1.0,
          );
        }

        // ============================================================
        // MINI PLAYER VISIBILITY
        // ============================================================
        //
        // Initial Login/Home:
        // hasActiveSong = false → hidden
        //
        // User taps a song:
        // hasActiveSong = true → visible
        //
        // Logout:
        // stop() → hasActiveSong = false → hidden
        // ============================================================

        if (!player.hasActiveSong) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const PlaybackScreen(),
              ),
            );
          },
          child: Container(
            height: 54,
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius:
                  BorderRadius.circular(15),

              // ========================================================
              // THEME-AWARE BORDER
              // ========================================================

              border: Border.all(
                color: borderColor,
                width: 1,
              ),

              // ========================================================
              // SOFT SHADOW
              // ========================================================

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(
                    alpha:
                        isDark ? 0.30 : 0.14,
                  ),
                  blurRadius: 18,
                  spreadRadius: 0,
                  offset:
                      const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(15),
              child: Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      8,
                      5,
                      6,
                      5,
                    ),
                    child: Row(
                      children: [
                        // ==================================================
                        // ARTWORK
                        // ==================================================

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            9,
                          ),
                          child: Image.asset(
                            player.currentImage,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration:
                                    const BoxDecoration(
                                  gradient:
                                      LinearGradient(
                                    begin:
                                        Alignment
                                            .topLeft,
                                    end:
                                        Alignment
                                            .bottomRight,
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
                                child:
                                    const Icon(
                                  Icons
                                      .music_note_rounded,
                                  color:
                                      Colors.white,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(
                          width: 9,
                        ),

                        // ==================================================
                        // SONG DETAILS
                        // ==================================================

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
                                player.currentSong,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: TextStyle(
                                  color:
                                      primaryText,
                                  fontSize: 12.5,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(
                                height: 2,
                              ),

                              Text(
                                player.currentArtist,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: TextStyle(
                                  color:
                                      secondaryText,
                                  fontSize: 9.5,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ==================================================
                        // PREVIOUS
                        // ==================================================

                        IconButton(
                          onPressed:
                              player.previousSong,
                          padding:
                              EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          splashRadius: 16,
                          icon: Icon(
                            Icons
                                .skip_previous_rounded,
                            color:
                                secondaryText,
                            size: 21,
                          ),
                        ),

                        // ==================================================
                        // PLAY / PAUSE
                        // ==================================================

                        GestureDetector(
                          onTap:
                              player.togglePlayPause,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration:
                                const BoxDecoration(
                              shape:
                                  BoxShape.circle,
                              gradient:
                                  LinearGradient(
                                begin:
                                    Alignment
                                        .topLeft,
                                end:
                                    Alignment
                                        .bottomRight,
                                colors: [
                                  Color(
                                    0xFFB77CFF,
                                  ),
                                  Color(
                                    0xFF7138C8,
                                  ),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Color(
                                    0x443F1675,
                                  ),
                                  blurRadius: 8,
                                  offset:
                                      Offset(
                                    0,
                                    3,
                                  ),
                                ),
                              ],
                            ),
                            child: Icon(
                              player.isPlaying
                                  ? Icons
                                      .pause_rounded
                                  : Icons
                                      .play_arrow_rounded,
                              color:
                                  Colors.white,
                              size: 19,
                            ),
                          ),
                        ),

                        // ==================================================
                        // NEXT
                        // ==================================================

                        IconButton(
                          onPressed:
                              player.nextSong,
                          padding:
                              EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          splashRadius: 16,
                          icon: Icon(
                            Icons
                                .skip_next_rounded,
                            color:
                                secondaryText,
                            size: 21,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ========================================================
                  // ACTIVE PLAYBACK PROGRESS — 2PX
                  // ========================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      height: 2,
                      child: Stack(
                        children: [
                          // ==================================================
                          // PROGRESS BACKGROUND
                          // ==================================================

                          Container(
                            width:
                                double.infinity,
                            height: 2,
                            color:
                                progressBackground,
                          ),

                          // ==================================================
                          // ACTIVE PROGRESS
                          // ==================================================

                          FractionallySizedBox(
                            alignment:
                                Alignment
                                    .centerLeft,
                            widthFactor:
                                progress,
                            child: Container(
                              height: 2,
                              decoration:
                                  const BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  begin:
                                      Alignment
                                          .centerLeft,
                                  end:
                                      Alignment
                                          .centerRight,
                                  colors: [
                                    Color(
                                      0xFF8B5CF6,
                                    ),
                                    Color(
                                      0xFFB77CFF,
                                    ),
                                    Color(
                                      0xFFD2B5FF,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}