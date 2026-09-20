import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/song_model.dart';

class JamendoApiService {
  JamendoApiService._();

  static final JamendoApiService instance = JamendoApiService._();

  static const String _host = 'api.jamendo.com';
  static const String _clientId = 'a5b46e22';
  static const Duration _timeout = Duration(seconds: 15);
  static const Duration _cacheLifetime = Duration(minutes: 10);

  // Tracks/artists that should never appear anywhere in SONEXA.
  static const Set<String> _blockedArtists = <String>{'rk deewana'};
  static const List<String> _blockedTitleParts = <String>[
    'band bhail 500',
    '500 so 1000',
    '500 se 1000',
  ];

  final http.Client _client = http.Client();
  final Map<String, _CachedJamendoSongs> _cache =
      <String, _CachedJamendoSongs>{};

  Future<List<SongModel>> searchTracks(String query, {int limit = 30}) async {
    final String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const <SongModel>[];

    final int safeLimit = limit.clamp(1, 50);
    final String cacheKey = '${cleanQuery.toLowerCase()}:$safeLimit';
    final _CachedJamendoSongs? cached = _cache[cacheKey];

    if (cached != null &&
        DateTime.now().difference(cached.createdAt) < _cacheLifetime) {
      return List<SongModel>.unmodifiable(cached.songs);
    }

    final Uri url = Uri.https(_host, '/v3.0/tracks/', <String, String>{
      'client_id': _clientId,
      'format': 'json',
      'limit': safeLimit.toString(),
      'search': cleanQuery,
      'audioformat': 'mp31',
      'imagesize': '600',
      'include': 'musicinfo',
      'type': 'single albumtrack',
    });

    return _fetchTracks(url, cacheKey: cacheKey);
  }

  Future<List<SongModel>> getPopularTracks({int limit = 30}) async {
    final int safeLimit = limit.clamp(1, 50);
    final String cacheKey = 'popular:$safeLimit';
    final _CachedJamendoSongs? cached = _cache[cacheKey];

    if (cached != null &&
        DateTime.now().difference(cached.createdAt) < _cacheLifetime) {
      return List<SongModel>.unmodifiable(cached.songs);
    }

    final Uri url = Uri.https(_host, '/v3.0/tracks/', <String, String>{
      'client_id': _clientId,
      'format': 'json',
      'limit': safeLimit.toString(),
      'order': 'popularity_total',
      'audioformat': 'mp31',
      'imagesize': '600',
      'include': 'musicinfo',
      'type': 'single albumtrack',
    });

    return _fetchTracks(url, cacheKey: cacheKey);
  }

  Future<List<SongModel>> _fetchTracks(
    Uri url, {
    required String cacheKey,
  }) async {
    try {
      final http.Response response = await _client
          .get(
            url,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw JamendoApiException(
          'Jamendo request failed',
          statusCode: response.statusCode,
        );
      }

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const JamendoApiException('Invalid Jamendo response.');
      }

      final dynamic headers = decoded['headers'];
      if (headers is Map && headers['status']?.toString() != 'success') {
        throw JamendoApiException(
          headers['error_message']?.toString() ?? 'Jamendo request failed.',
        );
      }

      final dynamic rawResults = decoded['results'];
      if (rawResults is! List) return const <SongModel>[];

      final List<SongModel> songs = <SongModel>[];

      for (final dynamic item in rawResults) {
        if (item is! Map) continue;
        final Map<String, dynamic> json = Map<String, dynamic>.from(item);
        final String id = json['id']?.toString() ?? '';
        final String audio = json['audio']?.toString() ?? '';
        if (id.isEmpty || audio.isEmpty) continue;

        final String title = json['name']?.toString() ?? 'Unknown Song';
        final String artist =
            json['artist_name']?.toString() ?? 'Unknown Artist';

        if (_isBlockedTrack(title: title, artist: artist)) continue;

        final dynamic musicInfoValue = json['musicinfo'];
        final Map<String, dynamic> musicInfo = musicInfoValue is Map
            ? Map<String, dynamic>.from(musicInfoValue)
            : <String, dynamic>{};
        final dynamic tagsValue = musicInfo['tags'];
        final Map<String, dynamic> tagsMap = tagsValue is Map
            ? Map<String, dynamic>.from(tagsValue)
            : <String, dynamic>{};

        final List<String> tags = <String>[];
        for (final dynamic value in tagsMap.values) {
          if (value is List) {
            tags.addAll(value.map((tag) => tag.toString()));
          }
        }

        songs.add(
          SongModel(
            id: id,
            title: title,
            artist: artist,
            imagePath:
                json['image']?.toString() ??
                json['album_image']?.toString() ??
                '',
            audioPath: audio,
            album: json['album_name']?.toString() ?? '',
            tags: tags,
            duration: _parseInt(json['duration']),
            isNetwork: true,
            source: 'jamendo',
          ),
        );
      }

      _cache[cacheKey] = _CachedJamendoSongs(
        songs: songs,
        createdAt: DateTime.now(),
      );

      return List<SongModel>.unmodifiable(songs);
    } on TimeoutException {
      throw const JamendoApiException(
        'Jamendo request timed out. Check your internet connection.',
      );
    } on FormatException {
      throw const JamendoApiException('Jamendo returned invalid data.');
    } on JamendoApiException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('SONEXA Jamendo API error: $error');
      debugPrint('SONEXA Jamendo stack trace: $stackTrace');
      throw JamendoApiException('Unable to load Jamendo songs: $error');
    }
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _isBlockedTrack({required String title, required String artist}) {
    final String normalizedTitle = title.toLowerCase().trim();
    final String normalizedArtist = artist.toLowerCase().trim();

    if (_blockedArtists.contains(normalizedArtist)) return true;

    return _blockedTitleParts.any(normalizedTitle.contains);
  }

  void clearCache() => _cache.clear();

  void dispose() => _client.close();
}

class _CachedJamendoSongs {
  final List<SongModel> songs;
  final DateTime createdAt;

  const _CachedJamendoSongs({required this.songs, required this.createdAt});
}

class JamendoApiException implements Exception {
  final String message;
  final int? statusCode;

  const JamendoApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) return message;
    return '$message (HTTP $statusCode)';
  }
}
