import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../player/player_controller.dart';

class AlbumsScreen extends StatefulWidget {
  final PlayerController player;

  const AlbumsScreen({
    super.key,
    required this.player,
  });

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  // ================================================================
  // ALBUM DATA
  // ================================================================

  static const List<AlbumData> albums = <AlbumData>[
    AlbumData(
      title: 'Romantic Hits',
      subtitle: 'Arijit Singh',
      songs: '25 Songs',
      icon: Icons.favorite_rounded,
      tag: 'romantic',
    ),
    AlbumData(
      title: 'Bollywood Hits',
      subtitle: 'Top Songs',
      songs: '40 Songs',
      icon: Icons.movie_rounded,
      tag: 'bollywood',
    ),
    AlbumData(
      title: 'Chill Vibes',
      subtitle: 'Relax Music',
      songs: '18 Songs',
      icon: Icons.headphones_rounded,
      tag: 'chill',
    ),
    AlbumData(
      title: 'Workout',
      subtitle: 'Energy Mix',
      songs: '30 Songs',
      icon: Icons.fitness_center_rounded,
      tag: 'workout',
    ),
    AlbumData(
      title: 'Lo-Fi Nights',
      subtitle: 'Late Night Music',
      songs: '22 Songs',
      icon: Icons.nightlight_round,
      tag: 'lofi',
    ),
    AlbumData(
      title: 'Party Hits',
      subtitle: 'Dance & Fun',
      songs: '35 Songs',
      icon: Icons.local_fire_department_rounded,
      tag: 'party',
    ),
  ];

  List<AlbumData> displayedAlbums = List<AlbumData>.from(albums);

  bool isListView = false;

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0712),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================================
            // HEADER
            // ============================================================

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore your',
                                style: TextStyle(
                                  color: Color(0xFFA8A0B3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Albums',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // SORT BUTTON
                        _HeaderButton(
                          icon: Icons.sort_rounded,
                          onTap: () {
                            _showSortOptions(context);
                          },
                        ),

                        const SizedBox(width: 10),

                        // MORE BUTTON
                        _HeaderButton(
                          icon: Icons.more_horiz_rounded,
                          iconColor: Colors.white,
                          onTap: () {
                            _showMoreOptions(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ======================================================
                    // SEARCH BAR
                    // ======================================================

                    GestureDetector(
                      onTap: () {
                        _showSearchDialog(context);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF15101F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2A2235),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 16),
                            Icon(
                              Icons.search_rounded,
                              color: Color(0xFF70677C),
                              size: 21,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Search albums...',
                              style: TextStyle(
                                color: Color(0xFF70677C),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======================================================
                    // COLLECTION TITLE
                    // ======================================================

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Collection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${displayedAlbums.length} albums',
                          style: const TextStyle(
                            color: Color(0xFF70677C),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ============================================================
            // ALBUMS
            // ============================================================

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              sliver: isListView
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AlbumListCard(
                              album: displayedAlbums[index],
                              player: widget.player,
                            ),
                          );
                        },
                        childCount: displayedAlbums.length,
                      ),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _AlbumCard(
                            album: displayedAlbums[index],
                            player: widget.player,
                          );
                        },
                        childCount: displayedAlbums.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SORT OPTIONS
  // ================================================================

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15101F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3045),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort Albums',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _SortOption(
                  title: 'Recently Added',
                  icon: Icons.access_time_rounded,
                  onTap: () {
                    setState(() {
                      displayedAlbums =
                          List<AlbumData>.from(albums);
                    });

                    Navigator.pop(sheetContext);
                  },
                ),

                _SortOption(
                  title: 'Alphabetical',
                  icon: Icons.sort_by_alpha_rounded,
                  onTap: () {
                    setState(() {
                      displayedAlbums =
                          List<AlbumData>.from(albums)
                            ..sort(
                              (a, b) => a.title.compareTo(
                                b.title,
                              ),
                            );
                    });

                    Navigator.pop(sheetContext);
                  },
                ),

                _SortOption(
                  title: 'Most Played',
                  icon: Icons.trending_up_rounded,
                  onTap: () {
                    setState(() {
                      displayedAlbums =
                          List<AlbumData>.from(albums);
                    });

                    Navigator.pop(sheetContext);
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // MORE OPTIONS
  // ================================================================

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15101F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              _MoreOption(
                icon: Icons.refresh_rounded,
                title: 'Refresh Albums',
                onTap: () {
                  setState(() {
                    displayedAlbums =
                        List<AlbumData>.from(albums);
                  });

                  Navigator.pop(sheetContext);
                },
              ),

              _MoreOption(
                icon: Icons.grid_view_rounded,
                title: 'Grid View',
                onTap: () {
                  setState(() {
                    isListView = false;
                  });

                  Navigator.pop(sheetContext);
                },
              ),

              _MoreOption(
                icon: Icons.list_rounded,
                title: 'List View',
                onTap: () {
                  setState(() {
                    isListView = true;
                  });

                  Navigator.pop(sheetContext);
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ================================================================
  // SEARCH
  // ================================================================

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15101F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Search Albums',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: searchController,
            autofocus: true,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Enter album name...',
              hintStyle: const TextStyle(
                color: Color(0xFF70677C),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFFB77CFF),
              ),
              filled: true,
              fillColor: const Color(0xFF0B0712),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              final query = value.trim().toLowerCase();

              setState(() {
                if (query.isEmpty) {
                  displayedAlbums =
                      List<AlbumData>.from(albums);
                } else {
                  displayedAlbums = albums.where((album) {
                    return album.title
                            .toLowerCase()
                            .contains(query) ||
                        album.subtitle
                            .toLowerCase()
                            .contains(query) ||
                        album.tag
                            .toLowerCase()
                            .contains(query);
                  }).toList();
                }
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  displayedAlbums =
                      List<AlbumData>.from(albums);
                });
              },
              child: const Text(
                'Close',
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
}

// ======================================================================
// ALBUM DATA
// ======================================================================

class AlbumData {
  final String title;
  final String subtitle;
  final String songs;
  final IconData icon;
  final String tag;

  const AlbumData({
    required this.title,
    required this.subtitle,
    required this.songs,
    required this.icon,
    required this.tag,
  });
}

// ======================================================================
// HEADER BUTTON
// ======================================================================

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFFB77CFF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF20182D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF30243D),
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }
}

// ======================================================================
// SORT OPTION
// ======================================================================

class _SortOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SortOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF21172D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFB77CFF),
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ======================================================================
// MORE OPTION
// ======================================================================

class _MoreOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MoreOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: const Color(0xFFB77CFF),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ======================================================================
// ALBUM GRID CARD
// ======================================================================

class _AlbumCard extends StatelessWidget {
  final AlbumData album;
  final PlayerController player;

  const _AlbumCard({
    required this.album,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final songs = player.songs;

        if (songs.isEmpty) {
          _showNoSongsMessage(context);
          return;
        }

        final song = _findSong();

        if (song != null) {
         await player.playSongModel(song);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF15101F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2A2235),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ARTWORK
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB77CFF),
                      Color(0xFF7138C8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        album.icon,
                        color: Colors.white,
                        size: 54,
                      ),
                    ),

                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius:
                              BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TITLE
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 3),

            // ARTIST
            Text(
              album.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFA8A0B3),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            // SONG COUNT
            Text(
              album.songs,
              style: const TextStyle(
                color: Color(0xFF70677C),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FIND SONG
  // ================================================================

  SongModel? _findSong() {
    // Match album name
    for (final song in player.songs) {
      if (song.album.toLowerCase() ==
          album.title.toLowerCase()) {
        return song;
      }
    }

    // Match tag
    for (final song in player.songs) {
      final hasTag = song.tags.any(
        (tag) =>
            tag.toLowerCase() == album.tag.toLowerCase(),
      );

      if (hasTag) {
        return song;
      }
    }

    // Fallback
    if (player.songs.isNotEmpty) {
      return player.songs.first;
    }

    return null;
  }

  void _showNoSongsMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'No songs available yet.',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF251832),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ======================================================================
// ALBUM LIST CARD
// ======================================================================

class _AlbumListCard extends StatelessWidget {
  final AlbumData album;
  final PlayerController player;

  const _AlbumListCard({
    required this.album,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (player.songs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No songs available yet.'),
            ),
          );
          return;
        }

        SongModel? song;

        // Match album
        for (final item in player.songs) {
          if (item.album.toLowerCase() ==
              album.title.toLowerCase()) {
            song = item;
            break;
          }
        }

        // Match tag
        song ??= _findByTag();

        // Fallback
        song ??= player.songs.first;

        await player.playSongModel(song);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF15101F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF2A2235),
          ),
        ),
        child: Row(
          children: [
            // ARTWORK
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFB77CFF),
                    Color(0xFF7138C8),
                  ],
                ),
              ),
              child: Icon(
                album.icon,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    album.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFA8A0B3),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    album.songs,
                    style: const TextStyle(
                      color: Color(0xFF70677C),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // PLAY
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF21172D),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFFB77CFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FIND BY TAG
  // ================================================================

  SongModel? _findByTag() {
    for (final song in player.songs) {
      final hasTag = song.tags.any(
        (tag) =>
            tag.toLowerCase() == album.tag.toLowerCase(),
      );

      if (hasTag) {
        return song;
      }
    }

    return null;
  }
}