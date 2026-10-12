import 'package:flutter/material.dart';

import '../player/player_scope.dart';
import '../screens/playback_screen.dart';

/// SONEXA's compact player, styled to match the shared purple app theme.
/// It is hidden until the player has an active song.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerScope.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background = isDark
        ? const Color(0xFF151020)
        : const Color(0xFFFFFFFF);
    final border = isDark
        ? const Color(0xFF30243F)
        : const Color(0xFFE8DDF1);
    final primaryText = isDark
        ? const Color(0xFFF7F4FC)
        : const Color(0xFF17131D);
    final secondaryText = isDark
        ? const Color(0xFFA9A1B8)
        : const Color(0xFF817989);
    final progressTrack = isDark
        ? const Color(0xFF30243F)
        : const Color(0xFFE8DDF1);
    const purple = Color(0xFF913CFF);
    const lavender = Color(0xFFC575FF);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        if (!player.hasActiveSong) {
          return const SizedBox.shrink();
        }

        final durationMs = player.duration.inMilliseconds;
        final progress = durationMs > 0
            ? (player.position.inMilliseconds / durationMs)
                .clamp(0.0, 1.0)
            : 0.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PlaybackScreen(),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 54,
              margin: const EdgeInsets.fromLTRB(4, 0, 4, 2),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                    child: Row(
                      children: [
                        _MiniArtwork(
                          imagePath: player.currentImage,
                          isNetwork: player.currentSongData.isNetwork,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                player.currentSong,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      player.currentArtist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: secondaryText,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                  if (player.currentSongData.isPreview) ...[
                                    const SizedBox(width: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: purple.withValues(alpha: 0.13),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'PREVIEW',
                                        style: TextStyle(
                                          color: lavender,
                                          fontSize: 7,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        _control(
                          tooltip: 'Previous song',
                          icon: Icons.skip_previous_rounded,
                          color: secondaryText,
                          onPressed: player.previousSong,
                        ),
                        const SizedBox(width: 2),
                        Semantics(
                          button: true,
                          label: player.isPlaying ? 'Pause' : 'Play',
                          child: InkWell(
                            onTap: player.togglePlayPause,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: purple,
                              ),
                              child: Icon(
                                player.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 21,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        _control(
                          tooltip: 'Next song',
                          icon: Icons.skip_next_rounded,
                          color: secondaryText,
                          onPressed: player.nextSong,
                        ),
                      ],
                    ),
                  ),
                  // Always visible bottom seek/progress line.
                  // LinearProgressIndicator has explicit size, unlike an
                  // unconstrained ColoredBox inside a Stack.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 1.5,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 1.5,
                      backgroundColor: progressTrack,
                      valueColor: const AlwaysStoppedAnimation<Color>(purple),
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

  Widget _control({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
      icon: Icon(icon, size: 22, color: color),
    );
  }
}

class _MiniArtwork extends StatelessWidget {
  const _MiniArtwork({required this.imagePath, required this.isNetwork});

  final String imagePath;
  final bool isNetwork;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF913CFF), Color(0xFF4A1A82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.music_note_rounded,
        color: Colors.white,
        size: 20,
      ),
    );

    Widget image = fallback;
    if (imagePath.trim().isNotEmpty) {
      if (isNetwork ||
          imagePath.startsWith('http://') ||
          imagePath.startsWith('https://')) {
        image = Image.network(
          imagePath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallback,
        );
      } else {
        image = Image.asset(
          imagePath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: 40, height: 40, child: image),
    );
  }
}
