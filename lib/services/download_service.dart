import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/song_model.dart';

/// Silent automatic local audio cache.
/// Only provider-approved Jamendo tracks are cached.
/// This service does not create or display Download UI.
class DownloadService extends ChangeNotifier {
  DownloadService._();

  static final DownloadService instance = DownloadService._();

  static const String _storageKey = 'sonexa_downloaded_songs_v1';
  static const Duration _requestTimeout = Duration(seconds: 45);

  final http.Client _client = http.Client();

  final Map<String, SongModel> _downloads = <String, SongModel>{};
  final Map<String, double> _progress = <String, double>{};
  final Set<String> _activeDownloads = <String>{};

  SharedPreferences? _preferences;
  Future<void>? _initialization;

  List<SongModel> get downloadedSongs =>
      List<SongModel>.unmodifiable(_downloads.values);

  String keyFor(SongModel song) => '${song.source}:${song.id}';

  bool isDownloaded(SongModel song) {
    return _downloads.containsKey(keyFor(song));
  }

  bool isDownloading(SongModel song) {
    return _activeDownloads.contains(keyFor(song));
  }

  double progressFor(SongModel song) {
    return _progress[keyFor(song)] ?? 0.0;
  }

  SongModel? downloadedVersion(SongModel song) {
    return _downloads[keyFor(song)];
  }

  Future<void> initialize() {
    return _initialization ??= _restore();
  }

  Future<void> _restore() async {
    try {
      _preferences = await SharedPreferences.getInstance();

      final List<String> stored =
          _preferences!.getStringList(_storageKey) ?? <String>[];

      final Map<String, SongModel> valid = <String, SongModel>{};

      for (final String entry in stored) {
        try {
          final dynamic decoded = jsonDecode(entry);

          if (decoded is! Map) continue;

          final SongModel song = SongModel.fromJson(
            Map<String, dynamic>.from(decoded),
          );

          final String path = song.downloadedAudioPath.trim();

          if (path.isEmpty || !await File(path).exists()) {
            continue;
          }

          valid[keyFor(song)] = song;
        } catch (error) {
          debugPrint('SONEXA cache record skipped: $error');
        }
      }

      _downloads
        ..clear()
        ..addAll(valid);

      await _persist();
    } catch (error) {
      debugPrint('SONEXA automatic cache restore error: $error');
    }

    notifyListeners();
  }

  /// Automatically cache only Jamendo tracks with explicit permission.
  Future<SongModel> downloadSong(SongModel song) async {
    await initialize();

    if (!song.isJamendoSong || !song.canDownload) {
      throw StateError(
        'This track is not approved for automatic audio caching.',
      );
    }

    final String key = keyFor(song);

    final SongModel? existing = _downloads[key];

    if (existing != null) {
      final String existingPath = existing.downloadedAudioPath.trim();

      if (existingPath.isNotEmpty && await File(existingPath).exists()) {
        return existing;
      }

      _downloads.remove(key);
    }

    if (!_activeDownloads.add(key)) {
      throw StateError('Automatic audio caching is already in progress.');
    }

    File? temporaryFile;
    IOSink? sink;

    try {
      final Directory documents = await getApplicationDocumentsDirectory();

      final Directory directory = Directory(
        '${documents.path}/SonexaAudioCache',
      );

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String extension = _extensionFor(song.downloadUrl);

      final String safeSource = song.source.replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '_',
      );

      final String safeId = song.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      final String filename = '${safeSource}_$safeId.$extension';

      final File finalFile = File('${directory.path}/$filename');

      temporaryFile = File('${directory.path}/$filename.part');

      final http.Request request =
          http.Request('GET', Uri.parse(song.downloadUrl))
            ..headers.addAll(const <String, String>{
              'Accept': 'audio/*, application/octet-stream;q=0.9, */*;q=0.8',
              'User-Agent': 'SONEXA/1.0',
            });

      final http.StreamedResponse response = await _client
          .send(request)
          .timeout(_requestTimeout);

      if (response.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Audio cache request failed (${response.statusCode}).',
        );
      }

      final String contentType =
          response.headers['content-type']?.toLowerCase() ?? '';

      if (contentType.contains('text/html') ||
          contentType.contains('application/json')) {
        throw const FormatException(
          'Provider returned data that is not audio.',
        );
      }

      sink = temporaryFile.openWrite();

      int received = 0;
      final int total = response.contentLength ?? 0;

      await for (final List<int> chunk in response.stream.timeout(
        _requestTimeout,
      )) {
        sink.add(chunk);
        received += chunk.length;

        if (total > 0) {
          _progress[key] = (received / total).clamp(0.0, 1.0).toDouble();
          notifyListeners();
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      if (received <= 0 || (total > 0 && received != total)) {
        throw HttpException('Audio cache file is empty or incomplete.');
      }

      if (await finalFile.exists()) {
        await finalFile.delete();
      }

      final File savedFile = await temporaryFile.rename(finalFile.path);

      final SongModel savedSong = song.copyWith(
        downloadedAudioPath: savedFile.path,
      );

      _downloads[key] = savedSong;
      _progress[key] = 1.0;

      await _persist();

      notifyListeners();

      debugPrint('SONEXA automatic audio cache saved: ${song.title}');

      return savedSong;
    } catch (error) {
      debugPrint('SONEXA automatic audio cache error: $error');

      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {}
      }

      if (temporaryFile != null && await temporaryFile.exists()) {
        try {
          await temporaryFile.delete();
        } catch (_) {}
      }

      rethrow;
    } finally {
      _activeDownloads.remove(key);
      _progress.remove(key);
      notifyListeners();
    }
  }

  /// Removes a cached local audio file.
  /// Kept for compatibility with existing widgets.
  Future<void> removeSong(SongModel song) async {
    await initialize();

    final SongModel? saved = _downloads.remove(keyFor(song));

    if (saved == null) return;

    final String path = saved.downloadedAudioPath.trim();

    if (path.isNotEmpty) {
      try {
        final File file = File(path);

        if (await file.exists()) {
          await file.delete();
        }
      } catch (error) {
        debugPrint('SONEXA cache remove error: $error');
      }
    }

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs =
        _preferences ?? await SharedPreferences.getInstance();

    _preferences = prefs;

    await prefs.setStringList(
      _storageKey,
      _downloads.values
          .map((SongModel song) => jsonEncode(song.toJson()))
          .toList(),
    );
  }

  String _extensionFor(String url) {
    final String path = Uri.tryParse(url)?.path.toLowerCase() ?? '';

    final String extension = path.contains('.') ? path.split('.').last : '';

    const Set<String> supported = <String>{'mp3', 'm4a', 'aac', 'wav', 'ogg'};

    return supported.contains(extension) ? extension : 'mp3';
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
