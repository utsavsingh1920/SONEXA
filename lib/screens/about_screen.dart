import 'package:flutter/material.dart';

/// SONEXA About page, styled consistently with the Home/Search/Library screens.
/// Uses the active Material theme, including the app's Light Mode.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _purple = Color(0xFF913CFF);
  static const Color _accent = Color(0xFFC575FF);
  static const Color _darkSurface = Color(0xFF151020);
  static const Color _darkBorder = Color(0xFF30243F);
  static const Color _darkMuted = Color(0xFFA9A1B8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final background = theme.scaffoldBackgroundColor;
    final surface = dark ? _darkSurface : theme.colorScheme.surface;
    final border = dark ? _darkBorder : theme.dividerColor;
    final text = theme.colorScheme.onSurface;
    final muted = dark ? _darkMuted : theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: text),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'About SONEXA',
          style: TextStyle(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 23, 18, 22),
              decoration: _cardDecoration(surface, border, radius: 22),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Image.asset(
                      'assets/images/sonexa_logo.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stackTrace) => Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_accent, _purple],
                          ),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'SONEXA',
                    style: TextStyle(
                      color: text,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Feel Every Beat',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your music, your mood, your space. Discover tracks, '
                    'enjoy seamless playback and keep your favorites together.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12.5, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),
            _sectionTitle('APP INFORMATION', muted),
            const SizedBox(height: 10),
            Container(
              decoration: _cardDecoration(surface, border),
              child: Column(
                children: [
                  _infoRow(
                    Icons.info_outline_rounded,
                    'Version',
                    '1.0.0',
                    text,
                    muted,
                  ),
                  _thinDivider(border),
                  _infoRow(
                    Icons.phone_android_rounded,
                    'Platform',
                    'Flutter',
                    text,
                    muted,
                  ),
                  _thinDivider(border),
                  _infoRow(
                    Icons.music_note_rounded,
                    'Application',
                    'SONEXA Music Player',
                    text,
                    muted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),
            _sectionTitle('ABOUT THE APP', muted),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(surface, border),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _iconBox(Icons.auto_awesome_rounded),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Built for your music',
                          style: TextStyle(
                            color: text,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SONEXA brings music discovery, playlists, liked songs, '
                    'playback controls and your personal Library into one '
                    'simple listening experience.',
                    style: TextStyle(color: muted, fontSize: 12.5, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 23),
            _sectionTitle('FEATURES', muted),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: _cardDecoration(surface, border),
              child: Column(
                children: [
                  _feature(
                    Icons.play_circle_outline_rounded,
                    'Music Playback',
                    text,
                  ),
                  _thinDivider(border),
                  _feature(Icons.queue_music_rounded, 'Queue Management', text),
                  _thinDivider(border),
                  _feature(Icons.library_music_outlined, 'Music Library', text),
                  _thinDivider(border),
                  _feature(Icons.equalizer_rounded, 'Equalizer', text),
                  _thinDivider(border),
                  _feature(Icons.playlist_play_rounded, 'Playlists', text),
                  _thinDivider(border),
                  _feature(Icons.favorite_border_rounded, 'Liked Songs', text),
                ],
              ),
            ),
            const SizedBox(height: 23),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: dark ? 0.09 : 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _purple.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite_rounded, size: 27, color: _accent),
                  const SizedBox(height: 8),
                  Text(
                    'Made for music lovers',
                    style: TextStyle(
                      color: text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Thank you for listening with SONEXA.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 17),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Online update checking is not configured yet.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                icon: const Icon(
                  Icons.system_update_rounded,
                  color: _accent,
                  size: 18,
                ),
                label: const Text(
                  'Check for Updates',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 11),
            Center(
              child: Text(
                '© 2026 SONEXA',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Your music. Your mood. Your sound.',
                style: TextStyle(color: muted, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _cardDecoration(
    Color surface,
    Color border, {
    double radius = 18,
  }) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
  );

  static Widget _sectionTitle(String text, Color color) => Padding(
    padding: const EdgeInsets.only(left: 3),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    ),
  );

  static Widget _thinDivider(Color color) => Divider(
    height: 1,
    thickness: 1,
    indent: 56,
    color: color.withValues(alpha: 0.6),
  );

  static Widget _iconBox(IconData icon) => Container(
    width: 39,
    height: 39,
    decoration: BoxDecoration(
      color: _purple.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: _accent, size: 20),
  );

  static Widget _infoRow(
    IconData icon,
    String title,
    String value,
    Color text,
    Color muted,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        _iconBox(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(value, style: TextStyle(color: muted, fontSize: 11)),
            ],
          ),
        ),
      ],
    ),
  );

  static Widget _feature(IconData icon, String label, Color text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        _iconBox(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(Icons.check_rounded, color: _accent, size: 18),
      ],
    ),
  );
}
