import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // ============================================================
  // DARK THEME COLORS
  // ============================================================

  static const Color _darkBackground = Color(0xFF07070D);
  static const Color _darkCard = Color(0xFF0F0E16);
  static const Color _darkIconBackground = Color(0xFF1C122C);
  static const Color _darkLightPurple = Color(0xFFB77CFF);
  static const Color _darkPrimaryText = Color(0xFFF5F3F7);
  static const Color _darkSecondaryText = Color(0xFF8F8999);
  static const Color _darkDivider = Color(0xFF24212B);

  // ============================================================
  // LIGHT THEME COLORS
  // ============================================================

  static const Color _lightBackground = Color(0xFFF7F5FA);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightIconBackground = Color(0xFFF0E7FF);
  static const Color _lightPurple = Color(0xFF7B3FE4);
  static const Color _lightPrimaryText = Color(0xFF18151D);
  static const Color _lightSecondaryText = Color(0xFF6F6878);
  static const Color _lightDivider = Color(0xFFE3DDEB);

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? _darkBackground
        : _lightBackground;
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? _darkCard
        : _lightCard;
  }

  Color _iconBackground(BuildContext context) {
    return _isDark(context)
        ? _darkIconBackground
        : _lightIconBackground;
  }

  Color _purple(BuildContext context) {
    return _isDark(context)
        ? _darkLightPurple
        : _lightPurple;
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? _darkPrimaryText
        : _lightPrimaryText;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? _darkSecondaryText
        : _lightSecondaryText;
  }

  Color _dividerColor(BuildContext context) {
    return _isDark(context)
        ? _darkDivider
        : _lightDivider;
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _section(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _dividerColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _purple(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            content,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BULLET POINT
  // ============================================================

  Widget _bulletPoint(
    BuildContext context,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(
              top: 7,
              right: 10,
            ),
            decoration: BoxDecoration(
              color: _purple(context),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: _background(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

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
          'Privacy Policy & Terms',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

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
              // ======================================================
              // HEADER CARD
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  color: _cardColor(context),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: _dividerColor(context),
                  ),
                ),
                child: Column(
                  children: [
                    // PRIVACY ICON
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
                        Icons.privacy_tip_outlined,
                        color: _purple(context),
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // TITLE
                    Text(
                      'Privacy & Terms',
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // SUBTITLE
                    Text(
                      'Your privacy and trust are important to us.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            _secondaryText(context),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // LAST UPDATED
                    Text(
                      'Last updated: September 2026',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            _secondaryText(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // PRIVACY POLICY TITLE
              // ======================================================

              Text(
                'Privacy Policy',
                style: TextStyle(
                  color: _purple(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // ======================================================
              // PRIVACY SECTIONS
              // ======================================================

              _section(
                context,
                title:
                    '1. Information We Collect',
                content:
                    'SONEXA may collect information that you provide when using the application, such as your account information, preferences, playlists, and settings. We only use information that is necessary to provide and improve the SONEXA experience.',
              ),

              _section(
                context,
                title:
                    '2. How We Use Information',
                content:
                    'Information may be used to provide music playback, personalize your experience, maintain application settings, improve app performance, and provide customer support.',
              ),

              _section(
                context,
                title:
                    '3. Music & Playback Data',
                content:
                    'SONEXA may store information about your playback preferences, recently played songs, playlists, and other app activity to provide features such as recommendations and playback history.',
              ),

              _section(
                context,
                title:
                    '4. Device Information',
                content:
                    'The application may use basic device and technical information required for reliable playback and application functionality. This may include operating system information, application version, and technical diagnostic information.',
              ),

              _section(
                context,
                title:
                    '5. Data Security',
                content:
                    'We take reasonable measures to protect information used by the application. However, no electronic storage or transmission method can be guaranteed to be completely secure.',
              ),

              _section(
                context,
                title:
                    '6. Third-Party Services',
                content:
                    'Some SONEXA features may use third-party services. These services may have their own privacy policies and terms. You should review the policies of third-party services when applicable.',
              ),

              _section(
                context,
                title:
                    '7. Your Choices',
                content:
                    'You may manage available application preferences through Settings. Depending on the features provided, you may also be able to update account information or request deletion of your account.',
              ),

              const SizedBox(height: 10),

              // ======================================================
              // TERMS OF USE TITLE
              // ======================================================

              Text(
                'Terms of Use',
                style: TextStyle(
                  color: _purple(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // ======================================================
              // TERMS SECTIONS
              // ======================================================

              _section(
                context,
                title:
                    '8. Using SONEXA',
                content:
                    'By using SONEXA, you agree to use the application responsibly and in accordance with applicable laws and regulations.',
              ),

              _section(
                context,
                title:
                    '9. Account Responsibility',
                content:
                    'You are responsible for maintaining the security of your account and for activity performed through your account. Do not share your account credentials with unauthorized users.',
              ),

              _section(
                context,
                title:
                    '10. Content & Copyright',
                content:
                    'Music and other content available through SONEXA may be protected by copyright and other intellectual property laws. You should only use content in accordance with the rights and licenses applicable to that content.',
              ),

              _section(
                context,
                title:
                    '11. Service Availability',
                content:
                    'SONEXA may occasionally experience interruptions due to maintenance, updates, technical issues, or circumstances outside our control. Features may also change or be discontinued over time.',
              ),

              _section(
                context,
                title:
                    '12. Changes to These Terms',
                content:
                    'We may update this Privacy Policy and Terms of Use when necessary. Changes will be reflected within the application or through other appropriate communication.',
              ),

              const SizedBox(height: 10),

              // ======================================================
              // IMPORTANT CARD
              // ======================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _cardColor(context),
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: _dividerColor(context),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Important',
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _bulletPoint(
                      context,
                      'Use SONEXA only for lawful purposes.',
                    ),

                    _bulletPoint(
                      context,
                      'Respect music copyrights and content licenses.',
                    ),

                    _bulletPoint(
                      context,
                      'Keep your account information secure.',
                    ),

                    _bulletPoint(
                      context,
                      'Review this page periodically for policy updates.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // FOOTER
              // ======================================================

              Center(
                child: Text(
                  '© 2026 SONEXA',
                  style: TextStyle(
                    color:
                        _secondaryText(context),
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  'Privacy Policy & Terms of Use',
                  style: TextStyle(
                    color:
                        _secondaryText(context),
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
}