import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() =>
      _LanguageScreenState();
}

class _LanguageScreenState
    extends State<LanguageScreen> {
  static const Color _background = Color(0xFF080812);
  static const Color _card = Color(0xFF12101A);
  static const Color _border = Color(0xFF292231);
  static const Color _purple = Color(0xFF9B6BFF);

  static const String _key =
      'settings_language';

  String _selected = 'English';

  final List<String> _languages = [
    'English',
    'Hindi',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _selected =
          prefs.getString(_key) ?? 'English';
    });
  }

  Future<void> _select(String language) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_key, language);

    if (!mounted) return;

    setState(() {
      _selected = language;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$language selected',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF211A2B),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Language',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: [
          const Text(
            'Choose the language used by SONEXA.',
            style: TextStyle(
              color: Color(0xFFAAA6B5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 25),
          ..._languages.map(
            (language) {
              final bool selected =
                  _selected == language;

              return GestureDetector(
                onTap: () => _select(language),
                child: Container(
                  margin:
                      const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius:
                        BorderRadius.circular(17),
                    border: Border.all(
                      color: selected
                          ? _purple
                          : _border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? _purple.withValues(
                                  alpha: 0.16,
                                )
                              : const Color(0xFF1D1728),
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          color: selected
                              ? _purple
                              : const Color(0xFFA982E5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          language,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: selected
                            ? _purple
                            : const Color(0xFF70677C),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}