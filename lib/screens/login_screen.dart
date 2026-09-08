import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ============================================================
  // SONEXA COLORS
  // ============================================================

  static const Color purple = Color(0xFF9B4DFF);
  static const Color lightPurple = Color(0xFFB77CFF);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final RegExp emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // ============================================================
  // PASSWORD VALIDATION
  // ============================================================

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'isLoggedIn',
      true,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // ==========================================================
    // GO TO HOME
    // REMOVE LOGIN SCREEN COMPLETELY
    // ==========================================================

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainShell(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // FORGOT PASSWORD - V1
  // ============================================================

  Future<void> _forgotPassword() async {
    final TextEditingController controller =
        TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final ThemeData theme =
            Theme.of(dialogContext);

        final ColorScheme colorScheme =
            theme.colorScheme;

        final bool isDark =
            theme.brightness == Brightness.dark;

        final Color dialogBackground = isDark
            ? const Color(0xFF15111E)
            : Colors.white;

        final Color primaryText =
            colorScheme.onSurface;

        final Color secondaryText =
            colorScheme.onSurfaceVariant;

        final Color fieldColor = isDark
            ? const Color(0xFF14111D)
            : const Color(0xFFF1ECF7);

        final Color borderColor =
            theme.dividerColor;

        return AlertDialog(
          backgroundColor: dialogBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: Text(
            'Forgot Password?',
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email and we will send you a password reset link.',
                style: TextStyle(
                  color: secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.done,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: lightPurple,
                  ),
                  filled: true,
                  fillColor: fieldColor,
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(
                      color: purple,
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: borderColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // ====================================================
            // CANCEL
            // ====================================================

            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: secondaryText,
                ),
              ),
            ),

            // ====================================================
            // SEND
            // ====================================================

            ElevatedButton(
              onPressed: () {
                final String email =
                    controller.text.trim();

                if (email.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please enter your email',
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF201A2C)
                          : const Color(0xFFEDE5F5),
                      behavior:
                          SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final RegExp emailRegex =
                    RegExp(
                  r'^[\w\.-]+@[\w\.-]+\.\w+$',
                );

                if (!emailRegex.hasMatch(email)) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please enter a valid email',
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF201A2C)
                          : const Color(0xFFEDE5F5),
                      behavior:
                          SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // ==================================================
                // V1:
                // Actual password reset backend will be connected
                // later.
                // ==================================================

                Navigator.of(
                  dialogContext,
                ).pop();

                // Show message AFTER closing the dialog.
                Future<void>.delayed(
                  const Duration(milliseconds: 150),
                  () {
                    if (!mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password reset will be connected later.',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF17131F),
                          ),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF201A2C)
                            : const Color(0xFFEDE5F5),
                        behavior:
                            SnackBarBehavior.floating,
                        margin:
                            const EdgeInsets.all(16),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    // ==========================================================
    // IMPORTANT
    // ==========================================================
    // Do NOT manually dispose this controller here.
    //
    // The dialog/TextField owns the widget lifecycle.
    // Leaving this local controller without manual dispose
    // avoids the Flutter '_dependents.isEmpty' assertion that
    // was appearing on the physical device.
    // ==========================================================
  }

  // ============================================================
  // SOCIAL LOGIN
  // ============================================================

  void _socialLogin(String provider) {
    final ThemeData theme =
        Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$provider login will be connected later.',
          style: TextStyle(
            color: isDark
                ? Colors.white
                : const Color(0xFF17131F),
          ),
        ),
        backgroundColor: isDark
            ? const Color(0xFF201A2C)
            : const Color(0xFFEDE5F5),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  void _signUp() {
    final ThemeData theme =
        Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Sign Up screen will be connected here.',
          style: TextStyle(
            color: isDark
                ? Colors.white
                : const Color(0xFF17131F),
          ),
        ),
        backgroundColor: isDark
            ? const Color(0xFF201A2C)
            : const Color(0xFFEDE5F5),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final ThemeData theme =
        Theme.of(context);

    final ColorScheme colorScheme =
        theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color fieldColor = isDark
        ? const Color(0xFF14111D)
        : Colors.white;

    final Color iconColor = isDark
        ? const Color(0xFFAAA3B2)
        : const Color(0xFF716A7D);

    final Color hintColor = isDark
        ? const Color(0xFFA49DAD)
        : const Color(0xFF777080);

    final Color borderColor = isDark
        ? const Color(0xFF332D3D)
        : const Color(0xFFE0D9E8);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: hintColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldColor,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 0,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(28),
        borderSide: BorderSide(
          color: borderColor,
          width: 1.3,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(28),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(28),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(28),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.7,
        ),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 9,
        height: 0.7,
      ),
    );
  }

  // ============================================================
  // SOCIAL BUTTON
  // ============================================================

  Widget _socialButton({
    required BuildContext context,
    required String imagePath,
    required String title,
    required VoidCallback onTap,
    double iconSize = 22,
  }) {
    final ThemeData theme =
        Theme.of(context);

    final ColorScheme colorScheme =
        theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color borderColor = isDark
        ? const Color(0xFF332D3D)
        : const Color(0xFFE0D9E8);

    final Color textColor =
        colorScheme.onSurface;

    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor,
            width: 1.3,
          ),
          backgroundColor: isDark
              ? const Color(0xFF14111D)
              : Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(27),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Icon(
                  Icons
                      .image_not_supported_outlined,
                  color: textColor,
                  size: iconSize,
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
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
    final ThemeData theme =
        Theme.of(context);

    final ColorScheme colorScheme =
        theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final MediaQueryData media =
        MediaQuery.of(context);

    final double screenWidth =
        media.size.width;

    final double scale =
        (screenWidth / 412.0)
            .clamp(0.88, 1.03);

    // ==========================================================
    // THEME COLORS
    // ==========================================================

    final Color backgroundColor =
        colorScheme.surface;

    final Color primaryText =
        colorScheme.onSurface;

    final Color secondaryText =
        colorScheme.onSurfaceVariant;

    final Color dividerColor =
        theme.dividerColor;

    // ==========================================================
    // SIZES
    // ==========================================================

    final double horizontalPadding =
        34.0 * scale;

    final double topSpace =
        76.0 * scale;

    final double logoSize =
        76.0 * scale;

    final double titleSize =
        27.0 * scale;

    final double subtitleSize =
        15.5 * scale;

    final double labelSize =
        17.0 * scale;

    final double fieldHeight =
        52.0 * scale;

    final double loginHeight =
        54.0 * scale;

    // ==========================================================
    // SPACING
    // ==========================================================

    const double logoToTitle = 19.0;
    const double titleToSubtitle = 5.0;
    const double subtitleToEmail = 31.0;

    const double labelToField = 8.0;
    const double fieldToField = 23.0;

    const double passwordToForgot = 9.0;
    const double forgotToLogin = 19.0;

    const double loginToDivider = 18.0;
    const double dividerToSocial = 14.0;

    const double socialToSignup = 13.0;

    // ==========================================================
    // SCREEN
    // ==========================================================

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal:
                  horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // LOGO
                // ==================================================

                SizedBox(
                  height: topSpace,
                ),

                Center(
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        logoSize * 0.27,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              purple.withValues(
                            alpha: isDark
                                ? 0.30
                                : 0.18,
                          ),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        logoSize * 0.27,
                      ),
                      child: Image.asset(
                        'assets/images/sonexa_logo.png',
                        width: logoSize,
                        height: logoSize,
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
                              ),
                            ),
                            child: Icon(
                              Icons.graphic_eq,
                              color:
                                  Colors.white,
                              size:
                                  logoSize * 0.5,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // LOGO → TITLE
                // ==================================================

                const SizedBox(
                  height: logoToTitle,
                ),

                // ==================================================
                // TITLE
                // ==================================================

                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Welcome to SONEXA',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: titleSize,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // TITLE → SUBTITLE
                // ==================================================

                const SizedBox(
                  height: titleToSubtitle,
                ),

                // ==================================================
                // SUBTITLE
                // ==================================================

                Center(
                  child: Text(
                    'Your music. Your way.',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize:
                          subtitleSize,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),

                // ==================================================
                // SUBTITLE → EMAIL
                // ==================================================

                const SizedBox(
                  height: subtitleToEmail,
                ),

                // ==================================================
                // EMAIL LABEL
                // ==================================================

                Text(
                  'Email',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: labelSize,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: labelToField,
                ),

                // ==================================================
                // EMAIL FIELD
                // ==================================================

                SizedBox(
                  height: fieldHeight,
                  child: TextFormField(
                    controller:
                        _emailController,
                    keyboardType:
                        TextInputType
                            .emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    style: TextStyle(
                      color: primaryText,
                      fontSize:
                          15 * scale,
                      fontWeight:
                          FontWeight.w500,
                    ),
                    validator:
                        _validateEmail,
                    decoration:
                        _inputDecoration(
                      context: context,
                      hint:
                          'Enter your email',
                      icon:
                          Icons.email_outlined,
                    ),
                  ),
                ),

                // ==================================================
                // EMAIL → PASSWORD
                // ==================================================

                const SizedBox(
                  height: fieldToField,
                ),

                // ==================================================
                // PASSWORD LABEL
                // ==================================================

                Text(
                  'Password',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: labelSize,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: labelToField,
                ),

                // ==================================================
                // PASSWORD FIELD
                // ==================================================

                SizedBox(
                  height: fieldHeight,
                  child: TextFormField(
                    controller:
                        _passwordController,
                    obscureText:
                        _obscurePassword,
                    textInputAction:
                        TextInputAction.done,
                    style: TextStyle(
                      color: primaryText,
                      fontSize:
                          15 * scale,
                      fontWeight:
                          FontWeight.w500,
                    ),
                    validator:
                        _validatePassword,
                    onFieldSubmitted:
                        (_) {
                      _login();
                    },
                    decoration:
                        _inputDecoration(
                      context: context,
                      hint:
                          'Enter your password',
                      icon:
                          Icons.lock_outline,
                      suffixIcon:
                          IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                          color:
                              lightPurple,
                          size:
                              21 * scale,
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // FORGOT PASSWORD
                // ==================================================

                Align(
                  alignment:
                      Alignment.centerRight,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(
                      top:
                          passwordToForgot,
                    ),
                    child:
                        GestureDetector(
                      behavior:
                          HitTestBehavior.opaque,
                      onTap:
                          _forgotPassword,
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 3,
                          horizontal: 2,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color:
                                lightPurple,
                            fontSize:
                                13.5 * scale,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // LOGIN BUTTON
                // ==================================================

                const SizedBox(
                  height: forgotToLogin,
                ),

                SizedBox(
                  width: double.infinity,
                  height: loginHeight,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _login,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          colorScheme
                              .primary,
                      disabledBackgroundColor:
                          colorScheme
                              .primary
                              .withValues(
                        alpha: 0.55,
                      ),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          EdgeInsets.zero,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          27,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2.1,
                              color:
                                  Colors.white,
                            ),
                          )
                        : Text(
                            'LOGIN',
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  17 * scale,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                  ),
                ),

                // ==================================================
                // LOGIN → DIVIDER
                // ==================================================

                const SizedBox(
                  height: loginToDivider,
                ),

                // ==================================================
                // DIVIDER
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color:
                            dividerColor,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal:
                            7 * scale,
                      ),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          color:
                              secondaryText,
                          fontSize:
                              9 * scale,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color:
                            dividerColor,
                      ),
                    ),
                  ],
                ),

                // ==================================================
                // DIVIDER → SOCIAL
                // ==================================================

                const SizedBox(
                  height: dividerToSocial,
                ),

                // ==================================================
                // GOOGLE + APPLE
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child:
                          _socialButton(
                        context: context,
                        imagePath:
                            'assets/images/google_logo.png',
                        title: 'Google',
                        onTap: () {
                          _socialLogin(
                            'Google',
                          );
                        },
                        iconSize:
                            21 * scale,
                      ),
                    ),
                    SizedBox(
                      width: 12 * scale,
                    ),
                    Expanded(
                      child:
                          _socialButton(
                        context: context,
                        imagePath:
                            'assets/images/apple_logo.png',
                        title: 'Apple',
                        onTap: () {
                          _socialLogin(
                            'Apple',
                          );
                        },
                        iconSize:
                            22 * scale,
                      ),
                    ),
                  ],
                ),

                // ==================================================
                // SOCIAL → SIGN UP
                // ==================================================

                const SizedBox(
                  height: socialToSignup,
                ),

                // ==================================================
                // SIGN UP
                // ==================================================

                Center(
                  child:
                      GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onTap: _signUp,
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 3,
                        horizontal: 5,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Don't have an account? ",
                              style:
                                  TextStyle(
                                color:
                                    secondaryText,
                                fontSize:
                                    12.5 * scale,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Sign Up',
                              style:
                                  TextStyle(
                                color:
                                    lightPurple,
                                fontSize:
                                    12.5 * scale,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}