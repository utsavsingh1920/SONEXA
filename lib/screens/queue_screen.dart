import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../player/player_scope.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

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

  static Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? Colors.white
        : const Color(0xFF18151D);
  }

  static Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF91899F)
        : const Color(0xFF6F6878);
  }

  static Color _mutedText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF777080)
        : const Color(0xFF777080);
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
        // ACTUAL QUEUE ONLY
        //
        // IMPORTANT:
        // player.songs ko fallback nahi kiya gaya.
        // Sirf wahi songs show honge jo actual queue me add hue hain.
        // ========================================================

        final List<SongModel> queue = player.hasQueue
            ? List<SongModel>.from(player.queue)
            : <SongModel>[];

        return Scaffold(
          backgroundColor: _backgroundColor(context),
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
                      // ==================================================
                      // BACK BUTTON
                      // ==================================================

                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
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
                            Icons.arrow_back_rounded,
                            color: _iconColor(context),
                            size: 21,
                          ),
                        ),
                      ),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Expanded(
                        child: Center(
                          child: Text(
                            'QUEUE',
                            style: TextStyle(
                              color: _primaryText(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      // ==================================================
                      // CLEAR BUTTON
                      // ==================================================

                      SizedBox(
                        width: 42,
                        height: 42,
                        child: queue.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear Queue',
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _showClearQueueDialog(
                                    context,
                                    player,
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_sweep_rounded,
                                  color: Color(0xFFB77CFF),
                                  size: 21,
                                ),
                              ),
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
                        style: TextStyle(
                          color: _secondaryText(context),
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
                      ? _emptyQueue(context)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            30,
                          ),
                          itemCount: queue.length,
                          itemBuilder: (context, index) {
                            final SongModel song = queue[index];

                            final bool isCurrent =
                                player.currentSongData.id == song.id;

                            final bool isPlaying =
                                isCurrent && player.isPlaying;

                            return _QueueSongItem(
                              song: song,
                              index: index,
                              isCurrent: isCurrent,
                              isPlaying: isPlaying,

                              // ========================================
                              // PLAY SONG
                              // ========================================

                              onTap: () {
                                player.playQueueSong(song);
                              },

                              // ========================================
                              // REMOVE SONG
                              // ========================================

                              onRemove: () {
                                _removeSongFromQueue(
                                  context,
                                  player,
                                  index,
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

  // ============================================================
  // REMOVE SONG FROM QUEUE
  // ============================================================

  void _removeSongFromQueue(
    BuildContext context,
    dynamic player,
    int index,
  ) {
    // Safety check.
    if (index < 0 || index >= player.queue.length) {
      return;
    }

    final SongModel removedSong = player.queue[index];

    // IMPORTANT:
    // Do NOT modify player.queue directly.
    // queue getter is unmodifiable.
    //
    // Use PlayerController's proper method.
    player.removeFromQueue(index);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isDark(context)
            ? const Color(0xFF211A2B)
            : const Color(0xFFFFFFFF),
        content: Text(
          '${removedSong.title} removed from queue',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CLEAR QUEUE DIALOG
  // ============================================================

  void _showClearQueueDialog(
    BuildContext context,
    dynamic player,
  ) {
    final bool isDark = _isDark(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF15111F)
              : const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Clear Queue?',
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'All songs will be removed from the queue.',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 13,
            ),
          ),
          actions: [
            // ==========================================================
            // CANCEL
            // ==========================================================

            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _secondaryText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ==========================================================
            // CLEAR
            // ==========================================================

            TextButton(
              onPressed: () {
                // IMPORTANT:
                // Use controller method instead of modifying
                // player.queue directly.
                player.clearQueue();

                Navigator.of(dialogContext).pop();

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isDark
                        ? const Color(0xFF211A2B)
                        : const Color(0xFFFFFFFF),
                    content: Text(
                      'Queue cleared',
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Color(0xFFB77CFF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EMPTY QUEUE
  // ============================================================

  Widget _emptyQueue(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue_music_rounded,
            color: _isDark(context)
                ? const Color(0xFF514A5C)
                : const Color(0xFFAAA1B5),
            size: 55,
          ),

          const SizedBox(height: 14),

          Text(
            'Queue is empty',
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Add songs to start playing',
            style: TextStyle(
              color: _mutedText(context),
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
  final VoidCallback onRemove;

  const _QueueSongItem({
    required this.song,
    required this.index,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
    required this.onRemove,
  });

  // ============================================================
  // THEME
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _titleColor(BuildContext context) {
    return isCurrent
        ? (_isDark(context)
            ? const Color(0xFFD8B7FF)
            : const Color(0xFF7138C8))
        : (_isDark(context)
            ? const Color(0xFFE7E3EB)
            : const Color(0xFF28232F));
  }

  Color _artistColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF817A8D)
        : const Color(0xFF777080);
  }

  Color _moreIconColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF686171)
        : const Color(0xFF8A8292);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark = _isDark(context);

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
              ? (isDark
                  ? const Color(0xFF1C122A)
                  : const Color(0xFFF0E8FA))
              : (isDark
                  ? const Color(0xFF12101A)
                  : const Color(0xFFFFFFFF)),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isCurrent
                ? (isDark
                    ? const Color(0xFF63349A)
                    : const Color(0xFFC39BEF))
                : (isDark
                    ? const Color(0xFF292231)
                    : const Color(0xFFE3DDEB)),
          ),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // ============================================================
            // NUMBER / PLAYING
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
                            : (isDark
                                ? const Color(0xFF716A7B)
                                : const Color(0xFF817A8D)),
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
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                song.imagePath,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _titleColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _artistColor(context),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // CURRENT PLAYING
            // ============================================================

            if (isPlaying)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFFB77CFF),
                  size: 19,
                ),
              ),

            // ============================================================
            // MORE / REMOVE
            // ============================================================

            SizedBox(
              width: 34,
              height: 45,
              child: PopupMenuButton<String>(
                tooltip: 'Queue options',
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: _moreIconColor(context),
                  size: 21,
                ),
                color: isDark
                    ? const Color(0xFF18131F)
                    : const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (value) {
                  if (value == 'remove') {
                    onRemove();
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'remove',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: Color(0xFFB77CFF),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Remove from Queue',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF18151D),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}