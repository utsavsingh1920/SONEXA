import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/song_model.dart';

/// Persists API song metadata so the catalogue can still be displayed offline.
/// This stores metadata only; it does not download or unlock audio.
class OfflineSongCatalogueService {
  OfflineSongCatalogueService._();

  static final OfflineSongCatalogueService instance =
      OfflineSongCatalogueService._();

  static const String _storageKey = 'sonexa_api_song_catalogue_v1';

  Future<List<SongModel>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> entries =
        prefs.getStringList(_storageKey) ?? const <String>[];
    final List<SongModel> songs = <SongModel>[];

    for (final String entry in entries) {
      try {
        final dynamic decoded = jsonDecode(entry);
        if (decoded is Map) {
          final SongModel song = SongModel.fromJson(
            Map<String, dynamic>.from(decoded),
          );
          if (song.id.isNotEmpty && song.hasValidAudio) songs.add(song);
        }
      } catch (_) {
        // Ignore one corrupt record without losing the remaining catalogue.
      }
    }

    return _unique(songs);
  }

  Future<void> save(Iterable<SongModel> songs) async {
    final List<SongModel> valid = _unique(
      songs.where((SongModel song) => song.id.isNotEmpty && song.hasValidAudio),
    );
    if (valid.isEmpty) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      valid.map((SongModel song) => jsonEncode(song.toJson())).toList(),
    );
  }

  List<SongModel> _unique(Iterable<SongModel> songs) {
    final Set<String> keys = <String>{};
    return songs.where((SongModel song) {
      return keys.add('${song.source}:${song.id}');
    }).toList();
  }
}
