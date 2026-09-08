import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  static const Color _purple = Color(0xFF9B4DFF);
  static const Color _lightPurple = Color(0xFFB77CFF);

  static const String _nameKey = 'account_name';
  static const String _emailKey = 'account_email';
  static const String _photoKey = 'account_photo';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String? _profileImagePath;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // LOAD ACCOUNT
  // ------------------------------------------------------------

  Future<void> _loadAccount() async {
    final prefs = await SharedPreferences.getInstance();

    final String name = prefs.getString(_nameKey) ?? 'SONEXA User';
    final String email =
        prefs.getString(_emailKey) ?? 'user@example.com';
    final String? photo = prefs.getString(_photoKey);

    if (!mounted) return;

    setState(() {
      nameController.text = name;
      emailController.text = email;
      _profileImagePath = photo;
      _isLoading = false;
    });
  }

  // ------------------------------------------------------------
  // SAVE ACCOUNT
  // ------------------------------------------------------------

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final String name = nameController.text.trim();
    final String email = emailController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_nameKey, name);
      await prefs.setString(_emailKey, email);

      if (_profileImagePath != null &&
          _profileImagePath!.isNotEmpty) {
        await prefs.setString(
          _photoKey,
          _profileImagePath!,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Account details updated successfully',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Unable to save account details',
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // ------------------------------------------------------------
  // PROFILE PHOTO
  // ------------------------------------------------------------

  Future<void> _pickProfilePhoto() async {
    if (_isCropping) return;

    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (pickedImage == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _isCropping = true;
      });

      final CroppedFile? croppedImage =
          await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        maxWidth: 800,
        maxHeight: 800,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: _purple,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            activeControlsWidgetColor: _lightPurple,
            dimmedLayerColor: Colors.black.withValues(
              alpha: 0.75,
            ),
            cropFrameColor: _lightPurple,
            cropGridColor: Colors.white.withValues(
              alpha: 0.35,
            ),
            cropFrameStrokeWidth: 2,
            cropGridStrokeWidth: 1,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
            minimumAspectRatio: 1.0,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      if (!mounted) return;

      setState(() {
        _isCropping = false;
      });

      // User cancelled crop.
      if (croppedImage == null) {
        return;
      }

      final String croppedPath = croppedImage.path;

      if (!File(croppedPath).existsSync()) {
        _showMessage(
          'Unable to process the selected photo',
        );
        return;
      }

      setState(() {
        _profileImagePath = croppedPath;
      });

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _photoKey,
        croppedPath,
      );

      if (!mounted) return;

      _showMessage(
        'Profile photo updated',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCropping = false;
      });

      _showMessage(
        'Unable to crop profile photo',
      );
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_photoKey);

      if (!mounted) return;

      setState(() {
        _profileImagePath = null;
      });

      _showMessage(
        'Profile photo removed',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to remove profile photo',
      );
    }
  }

  // ------------------------------------------------------------
  // PHOTO OPTIONS
  // ------------------------------------------------------------

  void _showPhotoOptions() {
    if (_isCropping) return;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(
                      alpha: 0.18,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile Photo',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose how you want to manage your photo',
                    style: TextStyle(
                      color: colors.onSurface.withValues(
                        alpha: 0.55,
                      ),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _photoOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle:
                      'Select and crop a photo from your device',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickProfilePhoto();
                  },
                ),
                if (_profileImagePath != null) ...[
                  const SizedBox(height: 10),
                  _photoOption(
                    icon: Icons.delete_outline_rounded,
                    title: 'Remove Photo',
                    subtitle:
                        'Use the default profile icon',
                    danger: true,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _removeProfilePhoto();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final Color accent =
        danger ? Colors.redAccent : _purple;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(
              alpha: 0.04,
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: colors.onSurface.withValues(
                alpha: 0.06,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.onSurface.withValues(
                          alpha: 0.48,
                        ),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurface.withValues(
                  alpha: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            milliseconds: 1800,
          ),
        ),
      );
  }

  // ------------------------------------------------------------
  // CHANGE PASSWORD
  // ------------------------------------------------------------

  void _changePassword() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final TextEditingController passwordController =
        TextEditingController();

    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Change Password',
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _passwordField(
                controller: passwordController,
                hint: 'New password',
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: confirmPasswordController,
                hint: 'Confirm password',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colors.onSurface.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: () {
                final String password =
                    passwordController.text;

                final String confirm =
                    confirmPasswordController.text;

                if (password.isEmpty || confirm.isEmpty) {
                  _showMessage(
                    'Please enter both password fields',
                  );
                  return;
                }

                if (password.length < 6) {
                  _showMessage(
                    'Password must be at least 6 characters',
                  );
                  return;
                }

                if (password != confirm) {
                  _showMessage(
                    'Passwords do not match',
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                passwordController.dispose();
                confirmPasswordController.dispose();

                _showMessage(
                  'Password updated successfully',
                );
              },
              child: const Text(
                'Update',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(
        color: colors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: colors.onSurface.withValues(
            alpha: 0.4,
          ),
        ),
        filled: true,
        fillColor: colors.onSurface.withValues(
          alpha: 0.04,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: colors.onSurface.withValues(
              alpha: 0.08,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(
            color: colors.onSurface.withValues(
              alpha: 0.08,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: _purple,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DELETE ACCOUNT
  // ------------------------------------------------------------

  void _deleteAccount() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete Account?',
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This action cannot be undone. Your account data will be removed.',
            style: TextStyle(
              color: colors.onSurface.withValues(
                alpha: 0.58,
              ),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colors.onSurface.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                final prefs =
                    await SharedPreferences.getInstance();

                await prefs.remove(_nameKey);
                await prefs.remove(_emailKey);
                await prefs.remove(_photoKey);

                if (!mounted) return;

                nameController.text = 'SONEXA User';
                emailController.text = 'user@example.com';

                setState(() {
                  _profileImagePath = null;
                });

                _showMessage(
                  'Account data removed',
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ICON BOX
  // ------------------------------------------------------------

  Widget _iconBox(IconData icon) {
    final theme = Theme.of(context);

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _purple.withValues(
          alpha:
              theme.brightness == Brightness.dark
                  ? 0.12
                  : 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: _lightPurple,
        size: 21,
      ),
    );
  }

  // ------------------------------------------------------------
  // SETTING ROW
  // ------------------------------------------------------------

  Widget _settingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              _iconBox(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed: use null-aware collection element.
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION CARD
  // ------------------------------------------------------------

  Widget _sectionCard({
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.onSurface.withValues(
            alpha: 0.07,
          ),
        ),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: child,
    );
  }

  // ------------------------------------------------------------
  // PROFILE AVATAR
  // ------------------------------------------------------------

  Widget _profileAvatar() {
    final theme = Theme.of(context);

    final String? imagePath = _profileImagePath;

    final bool hasImage =
        imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9B4DFF),
                Color(0xFF5B21B6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: hasImage
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: theme.colorScheme.surface,
                    child: const Icon(
                      Icons.person_rounded,
                      color: _lightPurple,
                      size: 38,
                    ),
                  ),
          ),
        ),

        // CAMERA BUTTON
        Positioned(
          right: -3,
          bottom: -2,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                  _isCropping
                      ? null
                      : _showPhotoOptions,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  color: _purple,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        theme.scaffoldBackgroundColor,
                    width: 3,
                  ),
                ),
                child: _isCropping
                    ? const Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor:
            theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.onSurface,
            size: 19,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Account Settings',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // PROFILE
              // ------------------------------------------------

              Text(
                'Profile',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              _sectionCard(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        20,
                        16,
                        20,
                      ),
                      child: Row(
                        children: [
                          _profileAvatar(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameController.text.isEmpty
                                      ? 'SONEXA User'
                                      : nameController.text,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  emailController.text.isEmpty
                                      ? 'user@example.com'
                                      : emailController.text,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.onSurface
                                        .withValues(
                                      alpha: 0.5,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                GestureDetector(
                                  onTap:
                                      _isCropping
                                          ? null
                                          : _showPhotoOptions,
                                  child: Text(
                                    'Change profile photo',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontSize: 11.5,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: colors.onSurface.withValues(
                        alpha: 0.07,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              color: colors.onSurface
                                  .withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: nameController,
                            textCapitalization:
                                TextCapitalization.words,
                            style: TextStyle(
                              color: colors.onSurface,
                            ),
                            decoration:
                                _inputDecoration(
                              'Enter your name',
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Email',
                            style: TextStyle(
                              color: colors.onSurface
                                  .withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: emailController,
                            keyboardType:
                                TextInputType.emailAddress,
                            style: TextStyle(
                              color: colors.onSurface,
                            ),
                            decoration:
                                _inputDecoration(
                              'Enter your email',
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    colors.primary,
                                foregroundColor:
                                    Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    13,
                                  ),
                                ),
                              ),
                              onPressed:
                                  _isSaving
                                      ? null
                                      : _saveChanges,
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 19,
                                      height: 19,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
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
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // SECURITY
              // ------------------------------------------------

              Text(
                'Security',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              _sectionCard(
                child: Column(
                  children: [
                    _settingRow(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle:
                          'Update your account password',
                      onTap: _changePassword,
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      indent: 72,
                      endIndent: 16,
                      color: colors.onSurface.withValues(
                        alpha: 0.07,
                      ),
                    ),

                    _settingRow(
                      icon:
                          Icons.verified_user_outlined,
                      title: 'Account Security',
                      subtitle:
                          'Manage your account security',
                      onTap: () {
                        _showMessage(
                          'Account security settings coming soon',
                        );
                      },
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // DANGER ZONE
              // ------------------------------------------------

              const Text(
                'Danger Zone',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              _sectionCard(
                child: _settingRow(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete Account',
                  subtitle:
                      'Permanently remove your account',
                  onTap: _deleteAccount,
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT DECORATION
  // ------------------------------------------------------------

  InputDecoration _inputDecoration(String hint) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colors.onSurface.withValues(
          alpha: 0.35,
        ),
      ),
      filled: true,
      fillColor: colors.onSurface.withValues(
        alpha: 0.035,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: colors.onSurface.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: colors.onSurface.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: _purple,
          width: 1.3,
        ),
      ),
    );
  }
}