import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_controller.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  static const _purple = Color(0xFF913CFF);
  static const _accent = Color(0xFFC575FF);
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    if (!mounted) return;
    setState(() {
      _selectedTheme = switch (saved) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
    });
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    if (_selectedTheme == mode) return;
    setState(() => _selectedTheme = mode);
    try {
      // The existing controller owns global theme state and persistence.
      await ThemeController.instance.setThemeMode(mode);
    } catch (_) {
      if (!mounted) return;
      await _loadSavedTheme();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not change appearance. Try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final background = theme.scaffoldBackgroundColor;
    final surface = dark ? const Color(0xFF151020) : Colors.white;
    final border = dark ? const Color(0xFF30243F) : const Color(0xFFE4DDED);
    final text = theme.colorScheme.onSurface;
    final muted = dark ? const Color(0xFFA9A1B8) : const Color(0xFF756D7D);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Appearance',
          style: TextStyle(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 30),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'CHOOSE YOUR THEME',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _option(
            title: 'Dark',
            subtitle: 'A comfortable listening experience',
            icon: Icons.dark_mode_rounded,
            mode: ThemeMode.dark,
            text: text,
            muted: muted,
            surface: surface,
            border: border,
          ),
          _option(
            title: 'Light',
            subtitle: 'Clean and bright appearance',
            icon: Icons.light_mode_rounded,
            mode: ThemeMode.light,
            text: text,
            muted: muted,
            surface: surface,
            border: border,
          ),
          _option(
            title: 'System Default',
            subtitle: 'Match your device appearance',
            icon: Icons.settings_suggest_rounded,
            mode: ThemeMode.system,
            text: text,
            muted: muted,
            surface: surface,
            border: border,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                const Icon(Icons.palette_outlined, color: _accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your selection applies across SONEXA and is saved for next time.',
                    style: TextStyle(color: muted, fontSize: 12.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _option({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required Color text,
    required Color muted,
    required Color surface,
    required Color border,
  }) {
    final selected = _selectedTheme == mode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changeTheme(mode),
          borderRadius: BorderRadius.circular(17),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: selected ? _purple.withValues(alpha: 0.11) : surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected ? _purple : border,
                width: selected ? 1.25 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? _accent : muted,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: muted, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? _accent : muted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
