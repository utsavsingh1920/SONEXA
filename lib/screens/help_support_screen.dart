import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color _purple = Color(0xFF9B4DFF);
  static const Color _lightPurple = Color(0xFFB77CFF);

  final TextEditingController messageController =
      TextEditingController();

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF07070D)
        : const Color(0xFFF7F5FA);
  }

  Color _card(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF0F0E16)
        : Colors.white;
  }

  Color _iconBackground(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF1C122C)
        : const Color(0xFFF0E8FF);
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFF5F3F7)
        : const Color(0xFF18151D);
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF8F8999)
        : const Color(0xFF6F6878);
  }

  Color _divider(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF24212B)
        : const Color(0xFFE3DDEB);
  }

  Color _accent(BuildContext context) {
    return _isDark(context) ? _lightPurple : _purple;
  }

  Color _snackBarColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF21182C)
        : const Color(0xFF6D3DB8);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: _snackBarColor(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _submitSupportRequest() {
    FocusScope.of(context).unfocus();

    if (messageController.text.trim().isEmpty) {
      _showMessage(
        'Please describe your problem first',
      );
      return;
    }

    messageController.clear();

    _showMessage(
      'Your support request has been submitted',
    );
  }

  void _showFaqAnswer(
    String question,
    String answer,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon: Icon(
                        Icons.close,
                        color: _secondaryText(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  answer,
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBox(
    BuildContext context,
    IconData icon,
  ) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _iconBackground(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: _accent(context),
        size: 21,
      ),
    );
  }

  Widget _supportRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            _iconBox(
              context,
              icon,
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
                      color: _primaryText(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _secondaryText(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: _secondaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return InkWell(
      onTap: () {
        _showFaqAnswer(
          question,
          answer,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: _secondaryText(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
      appBar: AppBar(
        backgroundColor: _background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: _primaryText(context),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _card(context),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: _divider(context),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color:
                            _iconBackground(context),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.support_agent,
                        color: _accent(context),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'How can we help?',
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Find answers or contact SONEXA support.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Support',
                style: TextStyle(
                  color: _accent(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _card(context),
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: _divider(context),
                  ),
                ),
                child: Column(
                  children: [
                    _supportRow(
                      context,
                      icon: Icons.email_outlined,
                      title: 'Contact Support',
                      subtitle:
                          'Send us your question or problem',
                      onTap: () {
                        _showMessage(
                          'Support email will be connected later',
                        );
                      },
                    ),

                    Divider(
                      height: 1,
                      color: _divider(context),
                    ),

                    _supportRow(
                      context,
                      icon:
                          Icons.bug_report_outlined,
                      title: 'Report a Problem',
                      subtitle:
                          'Tell us about an issue in SONEXA',
                      onTap: () {
                        _showMessage(
                          'Problem reporting is ready for integration',
                        );
                      },
                    ),

                    Divider(
                      height: 1,
                      color: _divider(context),
                    ),

                    _supportRow(
                      context,
                      icon: Icons.lightbulb_outline,
                      title: 'Send Feedback',
                      subtitle:
                          'Share your ideas with us',
                      onTap: () {
                        _showMessage(
                          'Feedback form will be connected later',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: _accent(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _card(context),
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: _divider(context),
                  ),
                ),
                child: Column(
                  children: [
                    _faqItem(
                      context,
                      question:
                          'How do I play a song?',
                      answer:
                          'Open your music library and tap any song to start playback. The mini player will appear at the bottom of the screen.',
                    ),

                    Divider(
                      height: 1,
                      color: _divider(context),
                    ),

                    _faqItem(
                      context,
                      question:
                          'How do I create a playlist?',
                      answer:
                          'Open the Playlists section and choose the option to create a new playlist. You can then add songs to it.',
                    ),

                    Divider(
                      height: 1,
                      color: _divider(context),
                    ),

                    _faqItem(
                      context,
                      question:
                          'How do I change audio quality?',
                      answer:
                          'Go to Settings, open Playback & Audio, and select Audio Quality. You can choose Auto, Normal, High, or Lossless.',
                    ),

                    Divider(
                      height: 1,
                      color: _divider(context),
                    ),

                    _faqItem(
                      context,
                      question:
                          'How do I use the equalizer?',
                      answer:
                          'Go to Settings > Playback & Audio > Equalizer. From there you can select presets and adjust the frequency sliders.',
                    ),

                    Divider(
                      height: 1,
                      color: _divider(context),
                    ),

                    _faqItem(
                      context,
                      question:
                          'How do I manage my subscription?',
                      answer:
                          'Open Settings and select Manage Subscription to view your available SONEXA plans.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Send a Message',
                style: TextStyle(
                  color: _accent(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _card(context),
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: _divider(context),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: messageController,
                      maxLines: 5,
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Describe your problem...',
                        hintStyle: TextStyle(
                          color:
                              _secondaryText(context),
                        ),
                        filled: true,
                        fillColor:
                            _background(context),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                _divider(context),
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color:
                                _divider(context),
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(
                            color: _purple,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _submitSupportRequest,
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Send Message',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'SONEXA Support',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}