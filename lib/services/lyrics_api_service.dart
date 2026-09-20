import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LyricsApiService {
  LyricsApiService._();

  static final LyricsApiService instance = LyricsApiService._();

  static const Duration _timeout = Duration(seconds: 12);
  static const String _host = 'lrclib.net';

  final http.Client _client = http.Client();
  final Map<String, LyricsResult> _cache = <String, LyricsResult>{};

  Future<LyricsResult> fetchLyrics({
    required String title,
    required String artist,
    String album = '',
    int durationSeconds = 0,
  }) async {
    final String cleanTitle = _cleanTitle(title);
    final String cleanArtist = _cleanArtist(artist);
    final String cacheKey =
        '${cleanTitle.toLowerCase()}|${cleanArtist.toLowerCase()}';

    final LyricsResult? cached = _cache[cacheKey];
    if (cached != null) return cached;

    if (cleanTitle.isEmpty || cleanArtist.isEmpty) {
      return const LyricsResult.unavailable();
    }

    try {
      final Uri uri = Uri.https(_host, '/api/search', <String, String>{
        'track_name': cleanTitle,
        'artist_name': cleanArtist,
      });

      final http.Response response = await _client
          .get(
            uri,
            headers: const <String, String>{
              'Accept': 'application/json',
              'User-Agent': 'SONEXA/1.0 (Flutter music player)',
            },
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw LyricsApiException(
          'Lyrics request failed',
          statusCode: response.statusCode,
        );
      }

      // Lyrics can contain Hindi and other Unicode scripts. Decode the raw
      // bytes explicitly as UTF-8 so they never appear as mojibake.
      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List || decoded.isEmpty) {
        const LyricsResult result = LyricsResult.unavailable();
        _cache[cacheKey] = result;
        return result;
      }

      final List<Map<String, dynamic>> candidates = decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (candidates.isEmpty) {
        const LyricsResult result = LyricsResult.unavailable();
        _cache[cacheKey] = result;
        return result;
      }

      candidates.sort((a, b) {
        return _scoreCandidate(
          b,
          cleanTitle,
          cleanArtist,
          durationSeconds,
        ).compareTo(
          _scoreCandidate(a, cleanTitle, cleanArtist, durationSeconds),
        );
      });

      for (final Map<String, dynamic> candidate in candidates) {
        final String synced = candidate['syncedLyrics']?.toString() ?? '';
        final String plain = candidate['plainLyrics']?.toString() ?? '';
        final List<String> lines = synced.trim().isNotEmpty
            ? _parseSyncedLyrics(synced)
            : _parsePlainLyrics(plain);

        if (lines.isNotEmpty) {
          final LyricsResult result = LyricsResult(
            lines: lines,
            isSynced: synced.trim().isNotEmpty,
            source: 'LRCLIB',
          );
          _cache[cacheKey] = result;
          return result;
        }
      }

      const LyricsResult result = LyricsResult.unavailable();
      _cache[cacheKey] = result;
      return result;
    } on TimeoutException {
      return const LyricsResult.error(
        'Lyrics load hone mein zyada time lag raha hai.',
      );
    } on FormatException {
      return const LyricsResult.error('Lyrics response invalid hai.');
    } catch (error) {
      debugPrint('SONEXA Lyrics API Error: $error');
      return const LyricsResult.error(
        'Lyrics load nahi ho sake. Internet connection check karein.',
      );
    }
  }

  int _scoreCandidate(
    Map<String, dynamic> item,
    String title,
    String artist,
    int durationSeconds,
  ) {
    int score = 0;
    final String itemTitle = _normalize(item['trackName']?.toString() ?? '');
    final String itemArtist = _normalize(item['artistName']?.toString() ?? '');
    final String wantedTitle = _normalize(title);
    final String wantedArtist = _normalize(artist);

    if (itemTitle == wantedTitle) score += 100;
    if (itemArtist == wantedArtist) score += 80;
    if (itemTitle.contains(wantedTitle) || wantedTitle.contains(itemTitle)) {
      score += 30;
    }
    if (itemArtist.contains(wantedArtist) ||
        wantedArtist.contains(itemArtist)) {
      score += 25;
    }
    if ((item['syncedLyrics']?.toString() ?? '').trim().isNotEmpty) score += 10;

    final int candidateDuration = (item['duration'] as num?)?.round() ?? 0;
    if (durationSeconds > 0 && candidateDuration > 0) {
      final int difference = (candidateDuration - durationSeconds).abs();
      if (difference <= 3) score += 20;
      if (difference > 15) score -= 20;
    }
    return score;
  }

  List<String> _parseSyncedLyrics(String value) {
    final RegExp timestamp = RegExp(
      r'^\s*\[\d{1,3}:\d{2}(?:[.:]\d{1,3})?\]\s*',
    );
    return value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.replaceFirst(timestamp, '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> _parsePlainLyrics(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String _cleanTitle(String value) {
    return value
        .replaceAll(
          RegExp(
            r'\s*[\(\[](?:feat\.?|ft\.?|remaster(?:ed)?|official|audio|video).*?[\)\]]',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'\s+-\s+(?:single|remaster(?:ed)?|official.*)$',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
  }

  String _cleanArtist(String value) {
    return value
        .split(RegExp(r'\s*(?:,|&| feat\.? | ft\.? )\s*', caseSensitive: false))
        .first
        .trim();
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0900-\u097f]+'), ' ')
        .trim();
  }

  void clearCache() => _cache.clear();

  void dispose() => _client.close();
}

class LyricsResult {
  final List<String> lines;
  final bool isSynced;
  final String source;
  final String? errorMessage;

  const LyricsResult({
    required this.lines,
    required this.isSynced,
    required this.source,
    this.errorMessage,
  });

  const LyricsResult.unavailable()
    : lines = const <String>[],
      isSynced = false,
      source = '',
      errorMessage = null;

  const LyricsResult.error(String message)
    : lines = const <String>[],
      isSynced = false,
      source = '',
      errorMessage = message;

  bool get hasLyrics => lines.isNotEmpty;
  bool get hasError => errorMessage != null;
}

class LyricsApiException implements Exception {
  final String message;
  final int? statusCode;

  const LyricsApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      statusCode == null ? message : '$message (HTTP $statusCode)';
}
