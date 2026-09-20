import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/song_model.dart';

class ITunesApiService {
  ITunesApiService._();

  static final ITunesApiService instance = ITunesApiService._();

  static const Duration _timeout = Duration(seconds: 15);
  static const Duration _cacheLifetime = Duration(minutes: 10);

  final http.Client _client = http.Client();
  final Map<String, _CachedSongs> _cache = <String, _CachedSongs>{};

  Future<List<SongModel>> searchSongs(String query, {int limit = 30}) async {
    final String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const <SongModel>[];

    final String cacheKey = '${cleanQuery.toLowerCase()}:$limit';
    final _CachedSongs? cached = _cache[cacheKey];

    if (cached != null &&
        DateTime.now().difference(cached.createdAt) < _cacheLifetime) {
      return List<SongModel>.unmodifiable(cached.songs);
    }

    final Uri url = Uri.https('itunes.apple.com', '/search', <String, String>{
      'term': cleanQuery,
      'country': 'IN',
      'media': 'music',
      'entity': 'song',
      'limit': limit.clamp(1, 50).toString(),
      'explicit': 'No',
    });

    try {
      final http.Response response = await _client
          .get(
            url,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw ITunesApiException(
          'iTunes request failed',
          statusCode: response.statusCode,
        );
      }

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is! Map<String, dynamic>) {
        throw const ITunesApiException('Invalid iTunes response.');
      }

      final dynamic rawResults = decoded['results'];
      if (rawResults is! List) return const <SongModel>[];

      final List<SongModel> songs = <SongModel>[];

      for (final dynamic item in rawResults) {
        if (item is! Map) continue;

        final Map<String, dynamic> json = Map<String, dynamic>.from(item);
        final String previewUrl = json['previewUrl']?.toString() ?? '';

        if (previewUrl.isEmpty) continue;

        final String artwork = (json['artworkUrl100']?.toString() ?? '')
            .replaceAll('100x100bb', '600x600bb');
        final int durationMilliseconds = _parseInt(json['trackTimeMillis']);

        songs.add(
          SongModel(
            id: json['trackId']?.toString() ?? previewUrl,
            title: json['trackName']?.toString() ?? 'Unknown Song',
            artist: json['artistName']?.toString() ?? 'Unknown Artist',
            imagePath: artwork,
            audioPath: previewUrl,
            album: json['collectionName']?.toString() ?? '',
            tags: <String>[
              if (json['primaryGenreName'] != null)
                json['primaryGenreName'].toString(),
              'India',
            ],
            duration: durationMilliseconds ~/ 1000,
            isNetwork: true,
            source: 'itunes',
          ),
        );
      }

      _cache[cacheKey] = _CachedSongs(songs: songs, createdAt: DateTime.now());

      return List<SongModel>.unmodifiable(songs);
    } on TimeoutException {
      throw const ITunesApiException(
        'Request timed out. Check your internet connection.',
      );
    } on FormatException {
      throw const ITunesApiException('iTunes returned invalid data.');
    } on ITunesApiException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('SONEXA iTunes API error: $error');
      debugPrint('SONEXA iTunes stack trace: $stackTrace');
      throw ITunesApiException('Unable to load Indian songs: $error');
    }
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void clearCache() => _cache.clear();

  void dispose() {
    _client.close();
  }
}

class _CachedSongs {
  final List<SongModel> songs;
  final DateTime createdAt;

  const _CachedSongs({required this.songs, required this.createdAt});
}

class ITunesApiException implements Exception {
  final String message;
  final int? statusCode;

  const ITunesApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) return message;
    return '$message (HTTP $statusCode)';
  }
}
