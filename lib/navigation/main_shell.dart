import 'package:flutter/material.dart';

import '../player/player_controller.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/mini_player.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // ============================================================
  // PAGE CONTROLLER
  // ============================================================

  final PageController _pageController = PageController();

  // ============================================================
  // PLAYER
  // ============================================================

  final PlayerController player = PlayerController();

  // ============================================================
  // NAVIGATION
  // ============================================================

  int selectedIndex = 0;

  // ============================================================
  // SWIPE VARIABLES
  // ============================================================

  double _dragStartPixels = 0.0;

  bool _isDragging = false;

  static const double _minimumSwipeDistance = 10.0;
  static const double _fastSwipeVelocity = 200.0;
  static const double _normalSwipePageThreshold = 0.12;

  // ============================================================
  // BOTTOM NAVIGATION PAGE CHANGE
  // ============================================================

  void _changePage(int index) {
    if (index == selectedIndex) return;

    setState(() {
      selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  // ============================================================
  // SWIPE START
  // ============================================================

  void _onHorizontalDragStart(
    DragStartDetails details,
  ) {
    if (!_pageController.hasClients) return;

    _isDragging = true;

    _dragStartPixels =
        _pageController.position.pixels;
  }

  // ============================================================
  // SWIPE UPDATE
  // ============================================================

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
  ) {
    if (!_isDragging ||
        !_pageController.hasClients) {
      return;
    }

    final ScrollPosition position =
        _pageController.position;

    final double newPixels =
        position.pixels - details.delta.dx;

    final double clampedPixels =
        newPixels.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    _pageController.jumpTo(
      clampedPixels,
    );
  }

  // ============================================================
  // SWIPE END
  // ============================================================

  void _onHorizontalDragEnd(
    DragEndDetails details,
  ) {
    if (!_isDragging ||
        !_pageController.hasClients) {
      return;
    }

    _isDragging = false;

    final double currentPixels =
        _pageController.position.pixels;

    final double pageWidth =
        _pageController.position.viewportDimension;

    if (pageWidth <= 0) return;

    final double currentPage =
        currentPixels / pageWidth;

    final double velocity =
        details.primaryVelocity ?? 0.0;

    final int startPage =
        (_dragStartPixels / pageWidth).round();

    int targetPage = startPage;

    // ==========================================================
    // FAST FLICK
    // ==========================================================

    if (velocity.abs() >= _fastSwipeVelocity &&
        (currentPixels - _dragStartPixels).abs() >=
            _minimumSwipeDistance) {
      if (velocity < 0) {
        targetPage = startPage + 1;
      } else {
        targetPage = startPage - 1;
      }
    }

    // ==========================================================
    // NORMAL DRAG
    // ==========================================================

    else {
      final double movedPages =
          currentPage - startPage;

      if (movedPages.abs() >=
          _normalSwipePageThreshold) {
        if (movedPages > 0) {
          targetPage = startPage + 1;
        } else {
          targetPage = startPage - 1;
        }
      } else {
        targetPage = startPage;
      }
    }

    // ==========================================================
    // SAFETY
    // ==========================================================

    targetPage =
        targetPage.clamp(0, 3);

    // ==========================================================
    // UPDATE SELECTED TAB
    // ==========================================================

    if (targetPage != selectedIndex) {
      setState(() {
        selectedIndex = targetPage;
      });
    }

    // ==========================================================
    // SMOOTH SETTLE
    // ==========================================================

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    player.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    // ==========================================================
    // THEME COLORS
    // ==========================================================

    final Color scaffoldBackground =
        theme.scaffoldBackgroundColor;

    final Color navBackground = isDark
        ? const Color(0xFF111019)
        : const Color(0xFFFFFFFF);

    // IMPORTANT:
    // Dark mode = dark border
    // Light mode = light border
    final Color navBorder = isDark
        ? const Color(0xFF292231)
        : const Color(0xFFE3DDE9);

    final Color selectedBackground = isDark
        ? const Color(0xFF2B193F)
        : const Color(0xFFF0E7FA);

    final Color selectedColor =
        theme.colorScheme.primary;

    final Color unselectedColor = isDark
        ? const Color(0xFF777080)
        : const Color(0xFF817989);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        return Scaffold(
          backgroundColor:
              scaffoldBackground,

          // ====================================================
          // KEYBOARD OPEN HONE PAR
          // NAVIGATION BAR / MINI PLAYER UPAR NAHI JAYEGA
          // ====================================================

          resizeToAvoidBottomInset: false,

          body: Stack(
            children: [
              // ==================================================
              // MAIN PAGES
              // ==================================================

              Positioned.fill(
                child: GestureDetector(
                  behavior:
                      HitTestBehavior.opaque,

                  onHorizontalDragStart:
                      _onHorizontalDragStart,

                  onHorizontalDragUpdate:
                      _onHorizontalDragUpdate,

                  onHorizontalDragEnd:
                      _onHorizontalDragEnd,

                  child: PageView(
                    controller:
                        _pageController,

                    // Manual swipe handling.
                    physics:
                        const NeverScrollableScrollPhysics(),

                    onPageChanged: (index) {
                      if (!mounted) return;

                      setState(() {
                        selectedIndex = index;
                      });
                    },

                    children: const [
                      HomeScreen(),
                      SearchScreen(),
                      LibraryScreen(),
                      SettingsScreen(),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // MINI PLAYER + BOTTOM NAVIGATION
              // ==================================================

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // =================================================
                    // MINI PLAYER
                    // =================================================

                    const MiniPlayer(),

                    // =================================================
                    // BOTTOM NAVIGATION
                    // =================================================

                    Container(
                      height: 54,
                      // Exact 2px outer margin on both sides.
                      width: MediaQuery.sizeOf(context).width - 4,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            navBackground,

                        borderRadius:
                            BorderRadius.circular(18),

                        // Dark = dark border
                        // Light = light border
                        border: Border.all(
                          color: navBorder,
                          width: 1,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(
                                    alpha: 0.33,
                                  )
                                : Colors.black.withValues(
                                    alpha: 0.10,
                                  ),
                            blurRadius: 18,
                            offset:
                                const Offset(0, 7),
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          // =================================================
                          // HOME
                          // =================================================

                          _navItem(
                            index: 0,
                            icon:
                                Icons.home_rounded,
                            label: 'Home',
                            selectedColor:
                                selectedColor,
                            unselectedColor:
                                unselectedColor,
                            selectedBackground:
                                selectedBackground,
                          ),

                          // =================================================
                          // SEARCH
                          // =================================================

                          _navItem(
                            index: 1,
                            icon:
                                Icons.search_rounded,
                            label: 'Search',
                            selectedColor:
                                selectedColor,
                            unselectedColor:
                                unselectedColor,
                            selectedBackground:
                                selectedBackground,
                          ),

                          // =================================================
                          // LIBRARY
                          // =================================================

                          _navItem(
                            index: 2,
                            icon:
                                Icons.library_music_rounded,
                            label: 'Library',
                            selectedColor:
                                selectedColor,
                            unselectedColor:
                                unselectedColor,
                            selectedBackground:
                                selectedBackground,
                          ),

                          // =================================================
                          // SETTINGS
                          // =================================================

                          _navItem(
                            index: 3,
                            icon:
                                Icons.settings_rounded,
                            label: 'Settings',
                            selectedColor:
                                selectedColor,
                            unselectedColor:
                                unselectedColor,
                            selectedBackground:
                                selectedBackground,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // NAV ITEM
  // ============================================================

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
    required Color selectedColor,
    required Color unselectedColor,
    required Color selectedBackground,
  }) {
    final bool isSelected =
        selectedIndex == index;

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTap: () {
        _changePage(index);
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 160),

        curve:
            Curves.easeOut,

        width: 68,
        height: 42,

        decoration: BoxDecoration(
          color: isSelected
              ? selectedBackground
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(14),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? selectedColor
                  : unselectedColor,
            ),

            const SizedBox(height: 2),

            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: isSelected
                    ? selectedColor
                    : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
