import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feedback_screen.dart';

class HelpSupportScreen extends StatefulWidget {

  const HelpSupportScreen({super.key});

  @override

  State<HelpSupportScreen> createState() => _HelpSupportScreenState();

}

class _HelpSupportScreenState extends State<HelpSupportScreen> {

  static const Color _purple = Color(0xFF913CFF);

  static const Color _lightPurple = Color(0xFFC575FF);

  final TextEditingController messageController =

      TextEditingController();
  final FocusNode _messageFocus = FocusNode();
  final GlobalKey _messageFormKey = GlobalKey();
  bool _isSubmitting = false;

  bool _isDark(BuildContext context) {

    return Theme.of(context).brightness == Brightness.dark;

  }

  Color _background(BuildContext context) {

    return _isDark(context)

        ? const Color(0xFF080710)

        : const Color(0xFFF7F5FA);

  }

  Color _card(BuildContext context) {

    return _isDark(context)

        ? const Color(0xFF151020)

        : Colors.white;

  }

  Color _iconBackground(BuildContext context) {

    return _isDark(context)

        ? const Color(0xFF21152F)

        : const Color(0xFFF0E8FF);

  }

  Color _primaryText(BuildContext context) {

    return _isDark(context)

        ? const Color(0xFFF7F4FC)

        : const Color(0xFF18151D);

  }

  Color _secondaryText(BuildContext context) {

    return _isDark(context)

        ? const Color(0xFFA9A1B8)

        : const Color(0xFF6F6878);

  }

  Color _divider(BuildContext context) {

    return _isDark(context)

        ? const Color(0xFF30243F)

        : const Color(0xFFE3DDEB);

  }

  Color _accent(BuildContext context) {

    return _isDark(context) ? _lightPurple : _purple;

  }

  Color _snackBarColor(BuildContext context) {

    return _isDark(context)

        ? const Color(0xFF21152F)

        : const Color(0xFF913CFF);

  }

  @override

  void dispose() {

    messageController.dispose();
    _messageFocus.dispose();
    _messageFocus.dispose();

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

  Future<void> _submitSupportRequest() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    final message = messageController.text.trim();
    if (message.isEmpty) {
      _showMessage('Please describe your problem first');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final messages = prefs.getStringList('sonexa_support_messages_v1') ?? <String>[];
      // Keep the submitted text locally until a real support API is connected.
      messages.add('${DateTime.now().toIso8601String()} | $message');
      final saved = await prefs.setStringList('sonexa_support_messages_v1', messages);
      if (!mounted) return;
      if (!saved) {
        _showMessage('Could not save your message. Please try again.');
        return;
      }
      messageController.clear();
      _showMessage('Message saved on this device. Online support is not connected yet.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not save your message. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _focusMessageForm({String? prefix}) {
    if (prefix != null && messageController.text.trim().isEmpty) {
      messageController.text = prefix;
      messageController.selection = TextSelection.collapsed(offset: prefix.length);
    }
    final target = _messageFormKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
    _messageFocus.requestFocus();
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

            8,

            8,

            8,

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

                        _focusMessageForm();

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

                        _focusMessageForm(prefix: 'Problem: ');

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

                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedbackScreen()));

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

                          'Go to Settings, open Playback & Audio, and select Audio Quality. You can choose Low, Normal, High, or Very High.',

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

                          'Subscription management is not available in this version of SONEXA.',

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
                key: _messageFormKey,

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
                        focusNode: _messageFocus,

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

                        onPressed: _isSubmitting ? null : _submitSupportRequest,

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

                        child: Text(
                            _isSubmitting ? 'Saving...' : 'Send Message',

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