import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/song_model.dart';

class AudiusApiService {
  AudiusApiService._();

  static final AudiusApiService instance = AudiusApiService._();

  static const String _host = 'discoveryprovider.audius.co';
  static const String _appName = 'SONEXA';

  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client = http.Client();

  // ============================================================
  // SEARCH TRACKS
  // ============================================================

  Future<List<SongModel>> searchTracks(String query, {int limit = 30}) async {
    final String cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return const <SongModel>[];
    }

    final Uri url = Uri.https(_host, '/v1/tracks/search', <String, String>{
      'query': cleanQuery,
      'limit': limit.clamp(1, 100).toString(),
      'app_name': _appName,
    });

    return _fetchSongs(url);
  }

  // ============================================================
  // TRENDING TRACKS
  // ============================================================

  Future<List<SongModel>> getTrendingTracks({
    int limit = 30,
    String time = 'week',
  }) async {
    final Uri url = Uri.https(_host, '/v1/tracks/trending', <String, String>{
      'limit': limit.clamp(1, 100).toString(),
      'time': time,
      'app_name': _appName,
    });

    return _fetchSongs(url);
  }

  // ============================================================
  // FETCH SONGS
  // ============================================================

  Future<List<SongModel>> _fetchSongs(Uri url) async {
    try {
      final http.Response response = await _client
          .get(
            url,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw AudiusApiException(
          'Audius request failed',
          statusCode: response.statusCode,
        );
      }

      final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is! Map<String, dynamic>) {
        throw const AudiusApiException('Audius response format is invalid.');
      }

      final dynamic rawData = decoded['data'];

      if (rawData is! List) {
        return const <SongModel>[];
      }

      final List<SongModel> songs = <SongModel>[];

      for (final dynamic item in rawData) {
        if (item is! Map) {
          continue;
        }

        final Map<String, dynamic> trackJson = Map<String, dynamic>.from(item);

        final String trackId = trackJson['id']?.toString() ?? '';

        if (trackId.isEmpty) {
          continue;
        }

        trackJson['streamUrl'] = getStreamUrl(trackId);

        final SongModel song = SongModel.fromAudiusJson(trackJson);

        if (song.id.isNotEmpty && song.audioPath.isNotEmpty) {
          songs.add(song);
        }
      }

      return songs;
    } on TimeoutException {
      throw const AudiusApiException(
        'Request timed out. Check your internet connection.',
      );
    } on FormatException {
      throw const AudiusApiException('Audius returned invalid JSON data.');
    } on AudiusApiException {
      rethrow;
    } catch (error, stackTrace) {
      debugPrint('SONEXA Audius API error: $error');
      debugPrint('SONEXA Audius API stack trace: $stackTrace');

      throw AudiusApiException('Unable to load songs: $error');
    }
  }

  // ============================================================
  // STREAM URL
  // ============================================================

  String getStreamUrl(String trackId) {
    return Uri.https(
      _host,
      '/v1/tracks/$trackId/stream',
      const <String, String>{'app_name': _appName},
    ).toString();
  }

  // ============================================================
  // CLOSE CLIENT
  // ============================================================

  void dispose() {
    _client.close();
  }
}

class AudiusApiException implements Exception {
  final String message;
  final int? statusCode;

  const AudiusApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return '$message (HTTP $statusCode)';
  }
}
