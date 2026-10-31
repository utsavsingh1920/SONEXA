import '../core/widgets/sonexa_network_image.dart';

import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../player/player_controller.dart';

/// A user's saved albums only. Does not insert demo albums into the library.
class AlbumsScreen extends StatefulWidget {
  final PlayerController player;
  const AlbumsScreen({super.key, required this.player});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  static const _purple = Color(0xFF913CFF);
  static const _accent = Color(0xFFC575FF);
  String _search = '';
  bool _listView = false;
  bool _alphabetical = false;

  List<String> get _albums {
    final names = widget.player.savedAlbumNames
        .where((name) => name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    if (_alphabetical) {
      names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF151020) : Colors.white;
    final border = dark ? const Color(0xFF30243F) : const Color(0xFFE3DDE9);
    final muted = dark ? const Color(0xFFA9A1B8) : const Color(0xFF756D7D);
    final text = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_rounded, color: text),
        ),
        title: Text(
          'Saved Albums',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: text,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _listView = !_listView),
            tooltip: _listView ? 'Grid view' : 'List view',
            icon: Icon(
              _listView ? Icons.grid_view_rounded : Icons.view_list_rounded,
              color: _accent,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Sort albums',
            icon: const Icon(Icons.sort_rounded, color: _accent),
            onSelected: (value) =>
                setState(() => _alphabetical = value == 'az'),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'saved', child: Text('Saved order')),
              PopupMenuItem(value: 'az', child: Text('Alphabetical A–Z')),
            ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.player,
        builder: (context, _) {
          final albums = _albums;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
            children: [
              TextField(
                onChanged: (value) => setState(() => _search = value),
                cursorColor: _purple,
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  hintText: 'Search your saved albums',
                  hintStyle: TextStyle(color: muted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: _accent),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: _purple),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Your Collection',
                      style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${albums.length} saved',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (albums.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.album_outlined,
                        size: 43,
                        color: _accent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _search.isEmpty
                            ? 'No saved albums yet'
                            : 'No albums found',
                        style: TextStyle(
                          color: text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _search.isEmpty
                            ? 'Save an album while browsing music to find it here.'
                            : 'Try another album name.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else if (_listView)
                ...albums.map(
                  (album) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _albumTile(album, surface, border, text, muted),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: albums.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.91,
                  ),
                  itemBuilder: (context, i) =>
                      _albumGrid(albums[i], surface, border, text, muted),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _cover(String album, {double? size}) {
    final songs = widget.player.getSavedAlbumSongs(album);
    final imagePath = songs.isNotEmpty ? songs.first.imagePath : '';
    Widget fallback() => Container(
      color: const Color(0xFF351656),
      alignment: Alignment.center,
      child: const Icon(Icons.album_rounded, color: _accent, size: 38),
    );
    if (imagePath.isEmpty) return fallback();
    final image =
        imagePath.startsWith('https://') || imagePath.startsWith('http://')
        ? sonexaNetworkImage(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback(),
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback(),
          );
    return size == null
        ? image
        : SizedBox(width: size, height: size, child: image);
  }

  Widget _albumGrid(
    String album,
    Color surface,
    Color border,
    Color text,
    Color muted,
  ) {
    final songs = widget.player.getSavedAlbumSongs(album);
    return InkWell(
      onTap: () => _openAlbum(album),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _cover(album),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${songs.length} songs',
              style: TextStyle(color: muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _albumTile(
    String album,
    Color surface,
    Color border,
    Color text,
    Color muted,
  ) {
    final songs = widget.player.getSavedAlbumSongs(album);
    return InkWell(
      onTap: () => _openAlbum(album),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _cover(album, size: 58),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: text, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${songs.length} songs',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _accent),
          ],
        ),
      ),
    );
  }

  void _openAlbum(String album) {
    final songs = widget.player.getSavedAlbumSongs(album);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        album,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(sheetContext).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: songs.isEmpty
                    ? const Center(child: Text('No saved tracks in this album'))
                    : ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, i) {
                          final SongModel song = songs[i];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _cover(album, size: 45),
                            ),
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.play_arrow_rounded,
                              color: _accent,
                            ),
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              await widget.player.playSongModel(
                                song,
                                playbackSongs: songs,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
