const Map<String, List<String>> lyricsData = <String, List<String>>{
  // यहां केवल वही lyrics रखें जिन्हें उपयोग करने की अनुमति आपके पास हो।
  // Empty map होने पर LyricsScreen automatically online API fallback करेगा।
};


String lyricsKeyFromSongTitle(String title) {
  return title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r"['’]"), '')
      .replaceAll(RegExp(r'[^a-z0-9\u0900-\u097f]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

List<String> getLyricsForSong(String title) {
  final String key = lyricsKeyFromSongTitle(title);
  final List<String> lyrics = lyricsData[key] ?? const <String>[];

  // पुराने template placeholders को real lyrics न मानें। इससे API fallback
  // block नहीं होगा, भले placeholder entry गलती से map में रह जाए।
  final bool isPlaceholder = lyrics.any((String line) {
    final String value = line.trim().toLowerCase();
    return value.contains('licensed lyrics will appear here') ||
        value.contains('add your authorized lyrics here') ||
        value.contains('lyrics automatically follow the current song');
  });

  if (isPlaceholder) return const <String>[];

  return lyrics
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .toList(growable: false);
}
