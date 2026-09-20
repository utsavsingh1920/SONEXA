class SongModel {
  final String id;
  final String title;
  final String artist;
  final String imagePath;
  final String audioPath;
  final String album;
  final List<String> tags;
  final int duration;
  final bool isNetwork;
  final String source;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.imagePath,
    required this.audioPath,
    this.album = '',
    this.tags = const [],
    this.duration = 0,
    this.isNetwork = false,
    this.source = 'local',
  });

  factory SongModel.fromAudiusJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    final Map<String, dynamic> artwork = json['artwork'] is Map
        ? Map<String, dynamic>.from(json['artwork'] as Map)
        : <String, dynamic>{};
    final dynamic rawTags = json['tags'];
    List<String> parsedTags = <String>[];

    if (rawTags is String && rawTags.trim().isNotEmpty) {
      parsedTags = rawTags
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    } else if (rawTags is List) {
      parsedTags = rawTags
          .map((tag) => tag.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    return SongModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Song',
      artist: user['name']?.toString() ?? 'Unknown Artist',
      imagePath:
          artwork['1000x1000']?.toString() ??
          artwork['480x480']?.toString() ??
          artwork['150x150']?.toString() ??
          '',
      audioPath: json['streamUrl']?.toString() ?? '',
      album: json['album_name']?.toString() ?? '',
      tags: parsedTags,
      duration: _parseInt(json['duration']),
      isNetwork: true,
      source: 'audius',
    );
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? imagePath,
    String? audioPath,
    String? album,
    List<String>? tags,
    int? duration,
    bool? isNetwork,
    String? source,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      album: album ?? this.album,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      isNetwork: isNetwork ?? this.isNetwork,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'artist': artist,
    'imagePath': imagePath,
    'audioPath': audioPath,
    'album': album,
    'tags': tags,
    'duration': duration,
    'isNetwork': isNetwork,
    'source': source,
  };

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Song',
      artist: json['artist']?.toString() ?? 'Unknown Artist',
      imagePath: json['imagePath']?.toString() ?? '',
      audioPath: json['audioPath']?.toString() ?? '',
      album: json['album']?.toString() ?? '',
      tags: json['tags'] is List
          ? (json['tags'] as List).map((tag) => tag.toString()).toList()
          : const <String>[],
      duration: _parseInt(json['duration']),
      isNetwork: json['isNetwork'] == true,
      source: json['source']?.toString() ?? 'local',
    );
  }

  bool get hasValidAudio => audioPath.trim().isNotEmpty;
  bool get hasArtwork => imagePath.trim().isNotEmpty;
  bool get isAudiusSong => source == 'audius';
  bool get isJamendoSong => source == 'jamendo';
  bool get isITunesSong => source == 'itunes';
  bool get isPreview => isITunesSong;
  bool get isFullTrack => !isPreview;
  String get playbackLabel => isPreview ? '30-sec Preview' : 'Full Track';
  Duration get songDuration => Duration(seconds: duration);

  String get formattedDuration {
    final int minutes = duration ~/ 60;
    final int seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModel && other.id == id && other.source == source;

  @override
  int get hashCode => Object.hash(id, source);
}
