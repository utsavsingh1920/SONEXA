import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioQualityScreen extends StatefulWidget {
  const AudioQualityScreen({super.key});

  @override
  State<AudioQualityScreen> createState() => _AudioQualityScreenState();
}

class _AudioQualityScreenState extends State<AudioQualityScreen> {
  static const String _qualityKey = 'audio_quality';

  String _selectedQuality = 'High';

  final List<_QualityOption> _qualities = const [
    _QualityOption(
      title: 'Low',
      subtitle: 'Uses less data and storage',
      icon: Icons.signal_cellular_alt_1_bar_rounded,
    ),
    _QualityOption(
      title: 'Normal',
      subtitle: 'Balanced quality and data usage',
      icon: Icons.signal_cellular_alt_2_bar_rounded,
    ),
    _QualityOption(
      title: 'High',
      subtitle: 'Better sound quality',
      icon: Icons.signal_cellular_alt_rounded,
    ),
    _QualityOption(
      title: 'Very High',
      subtitle: 'Best available sound quality',
      icon: Icons.high_quality_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadQuality();
  }

  Future<void> _loadQuality() async {
    final prefs = await SharedPreferences.getInstance();

    final savedQuality = prefs.getString(_qualityKey);

    if (!mounted) return;

    if (savedQuality != null &&
        _qualities.any(
          (quality) => quality.title == savedQuality,
        )) {
      setState(() {
        _selectedQuality = savedQuality;
      });
    }
  }

  Future<void> _changeQuality(String quality) async {
    setState(() {
      _selectedQuality = quality;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _qualityKey,
      quality,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$quality quality selected',
        ),
        duration: const Duration(
          milliseconds: 900,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color cardColor = isDark
        ? const Color(0xFF11111D)
        : colors.surfaceContainerHighest;

    final Color mutedColor =
        colors.onSurface.withValues(alpha: 0.58);

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colors.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          'Audio Quality',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),

        children: [
          _sectionTitle(
            context,
            'Streaming Quality',
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: colors.onSurface.withValues(
                  alpha: 0.06,
                ),
              ),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Container(
                  width: 46,
                  height: 46,

                  decoration: BoxDecoration(
                    color: colors.primary.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: colors.primary,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Choose your preferred audio quality',

                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Higher quality uses more mobile data and storage.',

                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          ..._qualities.map(
            (quality) => _qualityTile(
              context,
              quality,
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle(
            context,
            'Recommended',
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: colors.primary.withValues(
                alpha: 0.08,
              ),

              borderRadius:
                  BorderRadius.circular(16),

              border: Border.all(
                color: colors.primary.withValues(
                  alpha: 0.18,
                ),
              ),
            ),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: colors.primary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'High quality is recommended for the best balance between sound quality and data usage.',

                    style: TextStyle(
                      color: colors.onSurface.withValues(
                        alpha: 0.72,
                      ),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qualityTile(
    BuildContext context,
    _QualityOption quality,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final bool isSelected =
        _selectedQuality == quality.title;

    final Color cardColor = isDark
        ? const Color(0xFF11111D)
        : colors.surfaceContainerHighest;

    final Color mutedColor =
        colors.onSurface.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius:
              BorderRadius.circular(18),

          onTap: () {
            _changeQuality(
              quality.title,
            );
          },

          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),

            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withValues(
                      alpha: 0.10,
                    )
                  : cardColor,

              borderRadius:
                  BorderRadius.circular(18),

              border: Border.all(
                color: isSelected
                    ? colors.primary.withValues(
                        alpha: 0.45,
                      )
                    : colors.onSurface.withValues(
                        alpha: 0.05,
                      ),
              ),
            ),

            child: Row(
              children: [
                Icon(
                  quality.icon,

                  color: isSelected
                      ? colors.primary
                      : mutedColor,

                  size: 24,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        quality.title,

                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        quality.subtitle,

                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 180,
                  ),

                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,

                    key: ValueKey<bool>(
                      isSelected,
                    ),

                    color: isSelected
                        ? colors.primary
                        : colors.onSurface.withValues(
                            alpha: 0.35,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
      ),

      child: Text(
        title.toUpperCase(),

        style: TextStyle(
          color: colors.onSurface.withValues(
            alpha: 0.55,
          ),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _QualityOption {
  final String title;
  final String subtitle;
  final IconData icon;

  const _QualityOption({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}