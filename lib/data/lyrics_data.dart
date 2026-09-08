const Map<String, List<String>> lyricsData = {
  // ============================================================
  // 1. KESARIYA
  // ============================================================

  'kesariya': [
    'Kesariya — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 2. HAWAYEIN
  // ============================================================

  'hawayein': [
    'Hawayein — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 3. PEE LOON
  // ============================================================

  'pee-loon': [
    'Pee Loon — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 4. MAST MAGAN
  // ============================================================

  'mast-magan': [
    'Mast Magan — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 5. DAGABAAZ RE
  // ============================================================

  'dagabaaz-re': [
    'Dagabaaz Re — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 6. TUM JO AAYE
  // ============================================================

  'tum-jo-aaye': [
    'Tum Jo Aaye — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 7. JANAM JANAM
  // ============================================================

  'janam-janam': [
    'Janam Janam — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 8. TU JAANE NA
  // ============================================================

  'tu-jaane-na': [
    'Tu Jaane Na — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 9. YE TUNE KYA KIYA
  // ============================================================

  'ye-tune-kya-kiya': [
    'Ye Tune Kya Kiya — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],

  // ============================================================
  // 10. TERA DEEDAR HUA
  // ============================================================

  'tera-deedar-hua': [
    'Tera Deedar Hua — Lyrics',
    '',
    'Licensed lyrics will appear here.',
    'Add your authorized lyrics here.',
    '',
    'Lyrics automatically follow the current song.',
  ],
};


// ============================================================
// SONG TITLE → LYRICS KEY
// ============================================================
//
// This makes the mapping independent from spaces, hyphens,
// capitalization, etc.
//
// Example:
// "Pee Loon" → "pee-loon"
// "Mast Magan" → "mast-magan"

String lyricsKeyFromSongTitle(String title) {
  final String normalized = title
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r"['’]"), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  return normalized;
}


// ============================================================
// GET LYRICS FOR SONG
// ============================================================

List<String> getLyricsForSong(String title) {
  final String key = lyricsKeyFromSongTitle(title);

  return lyricsData[key] ?? const <String>[];
}