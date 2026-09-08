import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../player/player_scope.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        // ==========================================================
        // QUEUE
        // ==========================================================
        //
        // PlayerController mein queue available hai to actual queue
        // use hoga. Agar queue empty hai to songs list fallback rahegi.
        //
        final List<SongModel> queue = player.hasQueue
            ? player.queue
            : player.songs;

        return Scaffold(
          backgroundColor: const Color(0xFF080812),

          body: SafeArea(
            child: Column(
              children: [
                // ========================================================
                // TOP BAR
                // ========================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    10,
                  ),
                  child: Row(
                    children: [
                      // BACK BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF17131F),
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF292231),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFFB9B2C3),
                            size: 21,
                          ),
                        ),
                      ),

                      // TITLE
                      const Expanded(
                        child: Center(
                          child: Text(
                            'QUEUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      // RIGHT SIDE SPACE
                      const SizedBox(
                        width: 42,
                      ),
                    ],
                  ),
                ),

                // ========================================================
                // QUEUE INFO
                // ========================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    12,
                    22,
                    18,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.queue_music_rounded,
                        color: Color(0xFFB77CFF),
                        size: 21,
                      ),

                      const SizedBox(width: 9),

                      Text(
                        '${queue.length} songs',
                        style: const TextStyle(
                          color: Color(0xFF91899F),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ========================================================
                // QUEUE LIST
                // ========================================================

                Expanded(
                  child: queue.isEmpty
                      ? _emptyQueue()
                      : ListView.builder(
                          physics:
                              const BouncingScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            30,
                          ),
                          itemCount: queue.length,
                          itemBuilder:
                              (context, index) {
                            final SongModel song =
                                queue[index];

                            // ==================================================
                            // CURRENT SONG
                            // ==================================================

                            final bool isCurrent =
                                player.currentSongData.id ==
                                    song.id;

                            return _QueueSongItem(
                              song: song,
                              index: index,
                              isCurrent: isCurrent,
                              isPlaying:
                                  isCurrent &&
                                  player.isPlaying,

                              // ==================================================
                              // PLAY SONG
                              // ==================================================

                              onTap: () {
                                player.playQueueSong(song);
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

  // ============================================================
  // EMPTY QUEUE
  // ============================================================

  Widget _emptyQueue() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue_music_rounded,
            color: Color(0xFF514A5C),
            size: 55,
          ),

          SizedBox(height: 14),

          Text(
            'Queue is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 6),

          Text(
            'Add songs to start playing',
            style: TextStyle(
              color: Color(0xFF777080),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// QUEUE SONG ITEM
// ============================================================================

class _QueueSongItem extends StatelessWidget {
  final SongModel song;
  final int index;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;

  const _QueueSongItem({
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 76,
        margin: const EdgeInsets.only(
          bottom: 9,
        ),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFF1C122A)
              : const Color(0xFF12101A),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: isCurrent
                ? const Color(0xFF63349A)
                : const Color(0xFF292231),
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6)
                        .withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),

        child: Row(
          children: [
            // ============================================================
            // NUMBER / PLAYING ICON
            // ============================================================

            SizedBox(
              width: 27,
              child: isPlaying
                  ? const Icon(
                      Icons.graphic_eq_rounded,
                      color: Color(0xFFB77CFF),
                      size: 20,
                    )
                  : Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCurrent
                            ? const Color(0xFFB77CFF)
                            : const Color(0xFF716A7B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),

            const SizedBox(width: 9),

            // ============================================================
            // ARTWORK
            // ============================================================

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(13),
              child: Image.asset(
                song.imagePath,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
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
                          Color(0xFFB77CFF),
                          Color(0xFF7138C8),
                          Color(0xFF29113F),
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

            const SizedBox(width: 12),

            // ============================================================
            // SONG INFORMATION
            // ============================================================

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
                      color: isCurrent
                          ? const Color(0xFFD8B7FF)
                          : const Color(0xFFE7E3EB),
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF817A8D),
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // CURRENT PLAYING INDICATOR
            // ============================================================

            if (isPlaying)
              const Padding(
                padding:
                    EdgeInsets.only(right: 7),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFFB77CFF),
                  size: 19,
                ),
              ),

            // ============================================================
            // MORE ICON
            // ============================================================

            const SizedBox(
              width: 34,
              height: 45,
              child: Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF686171),
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }
}