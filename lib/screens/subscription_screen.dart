import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState
    extends State<SubscriptionScreen> {
  String selectedPlan = 'Premium';

  // ============================================================
  // THEME COLORS
  // ============================================================

  Color _backgroundColor(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF07070D)
        : const Color(0xFFF7F5FA);
  }

  Color _cardColor(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF0F0E16)
        : const Color(0xFFFFFFFF);
  }

  Color _iconBackground(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF1C122C)
        : const Color(0xFFF0E7FF);
  }

  Color _primaryText(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFFF5F3F7)
        : const Color(0xFF18151D);
  }

  Color _secondaryText(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF8F8999)
        : const Color(0xFF6F6878);
  }

  Color _dividerColor(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const Color(0xFF24212B)
        : const Color(0xFFE3DDEB);
  }

  static const Color purple = Color(0xFF9B4DFF);
  static const Color lightPurple = Color(0xFFB77CFF);

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // SELECT PLAN
  // ============================================================

  void _selectPlan(String plan) {
    setState(() {
      selectedPlan = plan;
    });
  }

  // ============================================================
  // UPGRADE
  // ============================================================

  void _upgrade() {
    _showMessage(
      '$selectedPlan plan selected. '
      'Payment integration can be added later.',
    );
  }

  // ============================================================
  // RESTORE PURCHASE
  // ============================================================

  void _restorePurchase() {
    _showMessage(
      'Checking for previous purchases...',
    );
  }

  // ============================================================
  // FEATURE ROW
  // ============================================================

  Widget _featureRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final Color iconBg =
        _iconBackground(context);

    final Color titleColor =
        _primaryText(context);

    final Color subtitleColor =
        _secondaryText(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: lightPurple,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.check_circle,
            color: lightPurple,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLAN CARD
  // ============================================================

  Widget _planCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
    required bool popular,
  }) {
    final bool selected =
        selectedPlan == title;

    final Color cardColorValue =
        _cardColor(context);

    final Color dividerColorValue =
        _dividerColor(context);

    final Color titleColor =
        _primaryText(context);

    final Color descriptionColor =
        _secondaryText(context);

    return GestureDetector(
      onTap: () {
        _selectPlan(title);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColorValue,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? purple
                : dividerColorValue,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

                if (popular)
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: purple.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: lightPurple,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              price,
              style: const TextStyle(
                color: lightPurple,
                fontSize: 24,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              description,
              style: TextStyle(
                color: descriptionColor,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? purple
                      : descriptionColor,
                  size: 21,
                ),

                const SizedBox(width: 8),

                Text(
                  selected
                      ? 'Selected'
                      : 'Select this plan',
                  style: TextStyle(
                    color: selected
                        ? lightPurple
                        : descriptionColor,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        _backgroundColor(context);

    final Color cardColor =
        _cardColor(context);

    final Color iconBackground =
        _iconBackground(context);

    final Color primaryText =
        _primaryText(context);

    final Color secondaryText =
        _secondaryText(context);

    final Color dividerColor =
        _dividerColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            backgroundColor,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: primaryText,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Subscription',
          style: TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // PREMIUM HEADER CARD
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color: dividerColor,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration:
                          BoxDecoration(
                        color:
                            iconBackground,
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: lightPurple,
                        size: 34,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Text(
                      'SONEXA Premium',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      'Enjoy your music without limits.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // CHOOSE PLAN
              // ==================================================

              Text(
                'Choose Your Plan',
                style: TextStyle(
                  color: lightPurple,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _planCard(
                context,
                title: 'Free',
                price: '₹0',
                description:
                    'Basic music experience',
                popular: false,
              ),

              const SizedBox(
                height: 12,
              ),

              _planCard(
                context,
                title: 'Premium',
                price: '₹99 / month',
                description:
                    'Full SONEXA experience',
                popular: true,
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // PREMIUM FEATURES
              // ==================================================

              Text(
                'Premium Features',
                style: TextStyle(
                  color: lightPurple,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  border: Border.all(
                    color: dividerColor,
                  ),
                ),
                child: Column(
                  children: [
                    _featureRow(
                      context,
                      Icons.music_note,
                      'Unlimited Music',
                      'Listen to your favorite songs anytime.',
                    ),

                    _featureRow(
                      context,
                      Icons.volume_up,
                      'High Audio Quality',
                      'Enjoy better quality audio playback.',
                    ),

                    _featureRow(
                      context,
                      Icons.download_outlined,
                      'Offline Downloads',
                      'Save music for offline listening.',
                    ),

                    _featureRow(
                      context,
                      Icons.block,
                      'Ad-Free Listening',
                      'Enjoy music without interruptions.',
                    ),

                    _featureRow(
                      context,
                      Icons.skip_next,
                      'Unlimited Skips',
                      'Skip songs whenever you want.',
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // UPGRADE BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _upgrade,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 15,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),
                  child: Text(
                    selectedPlan == 'Premium'
                        ? 'Upgrade to Premium'
                        : 'Continue with Free',
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // RESTORE PURCHASE
              // ==================================================

              Center(
                child: TextButton(
                  onPressed:
                      _restorePurchase,
                  child: const Text(
                    'Restore Purchase',
                    style: TextStyle(
                      color: lightPurple,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              // ==================================================
              // FOOTER
              // ==================================================

              Center(
                child: Text(
                  'Subscription payment integration '
                  'will be connected later.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10,
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}