import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _purple = Color(0xFF9B6BFF);
  static const Color _lightPurple = Color(0xFFB77CFF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor =
        theme.scaffoldBackgroundColor;

    final Color cardColor =
        colorScheme.surface;

    final Color primaryText =
        colorScheme.onSurface;

    final Color secondaryText =
        colorScheme.onSurface.withValues(
      alpha: isDark ? 0.55 : 0.60,
    );

    final Color dividerColor =
        colorScheme.onSurface.withValues(
      alpha: isDark ? 0.08 : 0.10,
    );

    final Color iconBackground =
        _purple.withValues(
      alpha: isDark ? 0.10 : 0.08,
    );

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryText,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'About SONEXA',
          style: TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            35,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ======================================================
              // SONEXA HERO CARD
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  22,
                  28,
                  22,
                  25,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(24),
                  border: Border.all(
                    color: dividerColor,
                  ),
                  boxShadow: [
                    if (isDark)
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 22,
                        offset:
                            const Offset(0, 8),
                      ),
                  ],
                ),
                child: Column(
                  children: [

                    // LOGO
                    Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(27),
                        color: iconBackground,
                        border: Border.all(
                          color: _purple.withValues(
                            alpha: 0.30,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _purple
                                .withValues(
                              alpha: isDark
                                  ? 0.22
                                  : 0.12,
                            ),
                            blurRadius: 30,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(27),
                        child: Image.asset(
                          'assets/images/sonexa_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              decoration:
                                  const BoxDecoration(
                                gradient:
                                    LinearGradient(
                                  colors: [
                                    Color(
                                      0xFFB65CFF,
                                    ),
                                    Color(
                                      0xFF6418D9,
                                    ),
                                  ],
                                  begin:
                                      Alignment.topLeft,
                                  end:
                                      Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons
                                    .graphic_eq_rounded,
                                color: Colors.white,
                                size: 46,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // APP NAME
                    Text(
                      'SONEXA',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 28,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // TAGLINE
                    const Text(
                      'Your Music. Your Vibe.',
                      style: TextStyle(
                        color: _lightPurple,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'A modern music player designed '
                      'to make your listening experience '
                      'simple, smooth, and enjoyable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // APP INFORMATION
              // ======================================================

              _SectionTitle(
                title: 'APP INFORMATION',
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                clipBehavior:
                    Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: dividerColor,
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon:
                          Icons.info_outline_rounded,
                      title: 'Version',
                      value: '1.0.0',
                    ),

                    _Divider(
                      color: dividerColor,
                    ),

                    _InfoRow(
                      icon:
                          Icons.phone_android_rounded,
                      title: 'Platform',
                      value: 'Flutter',
                    ),

                    _Divider(
                      color: dividerColor,
                    ),

                    _InfoRow(
                      icon:
                          Icons.music_note_rounded,
                      title: 'Application',
                      value:
                          'SONEXA Music Player',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // ABOUT THE APP
              // ======================================================

              _SectionTitle(
                title: 'ABOUT THE APP',
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration:
                              BoxDecoration(
                            color:
                                iconBackground,
                            borderRadius:
                                BorderRadius
                                    .circular(13),
                          ),
                          child: const Icon(
                            Icons
                                .auto_awesome_rounded,
                            color: _lightPurple,
                            size: 21,
                          ),
                        ),

                        const SizedBox(
                            width: 12),

                        Text(
                          'Built for your music',
                          style: TextStyle(
                            color:
                                primaryText,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'SONEXA is a music player focused on '
                      'delivering a clean and immersive '
                      'listening experience. It brings your '
                      'music, playlists, playback controls, '
                      'equalizer, and personalized features '
                      'together in one place.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // FEATURES
              // ======================================================

              _SectionTitle(
                title: 'FEATURES',
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  8,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: dividerColor,
                  ),
                ),
                child: Column(
                  children: [
                    _FeatureItem(
                      icon:
                          Icons.play_circle_outline_rounded,
                      title:
                          'Music Playback',
                    ),

                    _FeatureItem(
                      icon:
                          Icons.queue_music_rounded,
                      title:
                          'Queue Management',
                    ),

                    _FeatureItem(
                      icon:
                          Icons.library_music_outlined,
                      title:
                          'Music Library',
                    ),

                    _FeatureItem(
                      icon:
                          Icons.equalizer_rounded,
                      title:
                          'Equalizer',
                    ),

                    _FeatureItem(
                      icon:
                          Icons.playlist_play_rounded,
                      title:
                          'Playlists',
                    ),

                    _FeatureItem(
                      icon:
                          Icons.favorite_border_rounded,
                      title:
                          'Favorites',
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // MADE WITH LOVE
              // ======================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: _purple.withValues(
                    alpha: isDark
                        ? 0.07
                        : 0.05,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: _purple.withValues(
                      alpha: isDark
                          ? 0.15
                          : 0.13,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration:
                          BoxDecoration(
                        color:
                            _purple.withValues(
                          alpha: 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: _lightPurple,
                        size: 23,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Made with ❤️ for music lovers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Thank you for using SONEXA.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ======================================================
              // CHECK FOR UPDATES
              // ======================================================

              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _showMessage(
                      context,
                      'SONEXA is already up to date',
                    );
                  },
                  icon: const Icon(
                    Icons.system_update_rounded,
                    color: _lightPurple,
                    size: 17,
                  ),
                  label: const Text(
                    'Check for Updates',
                    style: TextStyle(
                      color: _lightPurple,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ======================================================
              // COPYRIGHT
              // ======================================================

              Center(
                child: Text(
                  '© 2026 SONEXA',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  'Your music. Your mood. Your sound.',
                  style: TextStyle(
                    color: secondaryText
                        .withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // MESSAGE
  // ================================================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
          duration:
              const Duration(seconds: 2),
        ),
      );
  }
}

// ====================================================================
// SECTION TITLE
// ====================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: TextStyle(
        color: theme
            .colorScheme
            .onSurface
            .withValues(alpha: 0.55),
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
      ),
    );
  }
}

// ====================================================================
// INFO ROW
// ====================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color purple =
      Color(0xFF9B6BFF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: purple.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFB77CFF),
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .onSurface,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.52,
                    ),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// DIVIDER
// ====================================================================

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 16,
      color: color,
    );
  }
}

// ====================================================================
// FEATURE ITEM
// ====================================================================

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showDivider;

  const _FeatureItem({
    required this.icon,
    required this.title,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF9B6BFF,
                  ).withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFFB77CFF),
                  size: 20,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .onSurface,
                    fontSize: 13.5,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              Icon(
                Icons.check_rounded,
                color: theme
                    .colorScheme
                    .onSurface
                    .withValues(
                  alpha: 0.35,
                ),
                size: 18,
              ),
            ],
          ),
        ),

        if (showDivider)
          Divider(
            height: 1,
            color: theme
                .colorScheme
                .onSurface
                .withValues(
              alpha: 0.065,
            ),
          ),
      ],
    );
  }
}
