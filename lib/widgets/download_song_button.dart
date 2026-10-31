import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../services/download_service.dart';

/// Download/remove action shown only when the provider explicitly permits it.
class DownloadSongButton extends StatelessWidget {
  const DownloadSongButton({super.key, required this.song, this.iconSize = 19});

  final SongModel song;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final DownloadService downloads = DownloadService.instance;

    return AnimatedBuilder(
      animation: downloads,
      builder: (context, _) {
        final bool downloaded = downloads.isDownloaded(song);
        final bool downloading = downloads.isDownloading(song);
        if (!song.canDownload && !downloaded) {
          return const SizedBox.shrink();
        }

        if (downloading) {
          final double progress = downloads.progressFor(song);
          return SizedBox(
            width: 36,
            height: 36,
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: CircularProgressIndicator(
                value: progress > 0 ? progress : null,
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        return IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: downloaded ? 'Remove download' : 'Download for offline',
          onPressed: () async {
            try {
              if (downloaded) {
                await downloads.removeSong(song);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download removed')),
                );
              } else {
                await downloads.downloadSong(song);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Song saved for offline playback'),
                  ),
                );
              }
            } catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Download unavailable: $error')),
              );
            }
          },
          icon: Icon(
            downloaded ? Icons.download_done_rounded : Icons.download_rounded,
            color: downloaded
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: iconSize,
          ),
        );
      },
    );
  }
}
