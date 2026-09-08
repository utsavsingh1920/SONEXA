import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() =>
      _FeedbackScreenState();
}

class _FeedbackScreenState
    extends State<FeedbackScreen> {
  static const Color _purple =
      Color(0xFF9B6BFF);

  static const Color _lightPurple =
      Color(0xFFB77CFF);

  final TextEditingController _feedbackController =
      TextEditingController();

  int _rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // ================================================================
  // SEND FEEDBACK
  // ================================================================

  void _sendFeedback() {
    final String feedback =
        _feedbackController.text.trim();

    if (feedback.isEmpty && _rating == 0) {
      _showMessage(
        'Please write some feedback or give a rating.',
      );
      return;
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Thanks for your feedback! ❤️',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  // ================================================================
  // MESSAGE
  // ================================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

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

    final Color borderColor =
        colorScheme.onSurface.withValues(
      alpha: isDark ? 0.08 : 0.10,
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
          'Send Feedback',
          style: TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
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
              // HEADER CARD
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  23,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(24),
                  border: Border.all(
                    color: borderColor,
                  ),
                  boxShadow: [
                    if (isDark)
                      BoxShadow(
                        color: Colors.black
                            .withValues(
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

                    // ICON
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: _purple.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          23,
                        ),
                        border: Border.all(
                          color: _purple
                              .withValues(
                            alpha: 0.22,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _purple
                                .withValues(
                              alpha: isDark
                                  ? 0.16
                                  : 0.08,
                            ),
                            blurRadius: 25,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons
                            .feedback_outlined,
                        color: _lightPurple,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'We value your feedback',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Help us make SONEXA better for you.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // RATING
              // ======================================================

              Text(
                'RATE YOUR EXPERIENCE',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Column(
                  children: [

                    Text(
                      _rating == 0
                          ? 'How are you enjoying SONEXA?'
                          : _rating == 1
                              ? 'We are sorry to hear that.'
                              : _rating == 2
                                  ? 'We can do better.'
                                  : _rating == 3
                                      ? 'Thanks for your rating!'
                                      : _rating == 4
                                          ? 'Glad you like SONEXA!'
                                          : 'Awesome! Thank you! ❤️',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 13),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) {
                          final int star =
                              index + 1;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = star;
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 5,
                              ),
                              child: Icon(
                                star <= _rating
                                    ? Icons
                                        .star_rounded
                                    : Icons
                                        .star_border_rounded,
                                color:
                                    star <= _rating
                                        ? _lightPurple
                                        : secondaryText
                                            .withValues(
                                            alpha:
                                                0.45,
                                          ),
                                size: 34,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // FEEDBACK
              // ======================================================

              Text(
                'YOUR FEEDBACK',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: TextField(
                  controller:
                      _feedbackController,
                  maxLines: 7,
                  minLines: 5,
                  textCapitalization:
                      TextCapitalization.sentences,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                  decoration:
                      InputDecoration(
                    hintText:
                        'Tell us what you think about SONEXA...',
                    hintStyle: TextStyle(
                      color: secondaryText
                          .withValues(
                        alpha: 0.65,
                      ),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.all(
                      17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your feedback helps us improve the app.',
                style: TextStyle(
                  color: secondaryText
                      .withValues(
                    alpha: 0.65,
                  ),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 28),

              // ======================================================
              // SEND BUTTON
              // ======================================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _sendFeedback,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        17,
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .send_rounded,
                        size: 19,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Send Feedback',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ======================================================
              // PRIVACY NOTE
              // ======================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _purple.withValues(
                    alpha: isDark
                        ? 0.055
                        : 0.045,
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: _purple.withValues(
                      alpha: 0.10,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons
                          .lightbulb_outline_rounded,
                      color: _lightPurple,
                      size: 20,
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Text(
                        'Have a suggestion, found a bug, '
                        'or simply want to tell us what '
                        'you love? We would love to hear '
                        'from you.',
                        style: TextStyle(
                          color:
                              secondaryText,
                          fontSize: 11.5,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ======================================================
              // BRANDING
              // ======================================================

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF9B5CFF),
                            Color(0xFF5B21B6),
                          ],
                          begin:
                              Alignment.topLeft,
                          end: Alignment
                              .bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                        child: Image.asset(
                          'assets/images/sonexa_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons
                                  .graphic_eq_rounded,
                              color:
                                  Colors.white,
                              size: 23,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      'SONEXA',
                      style: TextStyle(
                        color: primaryText
                            .withValues(
                          alpha: isDark
                              ? 0.22
                              : 0.25,
                        ),
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Your music. Your mood. Your sound.',
                      style: TextStyle(
                        color:
                            secondaryText
                                .withValues(
                          alpha: 0.65,
                        ),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

