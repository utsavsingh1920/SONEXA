class SongModel {
  final String id;
  final String title;
  final String artist;
  final String imagePath;
  final String audioPath;
  final String album;
  final List<String> tags;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.imagePath,
    required this.audioPath,
    this.album = '',
    this.tags = const [],
  });
}