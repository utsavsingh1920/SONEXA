
import 'package:flutter/material.dart';

import '../player/player_scope.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    SettingsScreen(),
  ];

  void _changePage(int index) {
    if (index < 0 ||
        index >= _pages.length ||
        index == selectedIndex) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primary = theme.colorScheme.primary;
    final background =
        isDark ? AppTheme.background : AppTheme.lightBackground;
    final surface =
        isDark ? const Color(0xFF130D20) : Colors.white;
    final border =
        isDark ? const Color(0xFF302342) : const Color(0xFFE5DCEE);
    final selectedFill =
        isDark ? const Color(0xFF442079) : const Color(0xFFF0E4FF);
    final activeColor =
        isDark ? const Color(0xFFDCC2FF) : const Color(0xFF7124C8);
    final inactiveColor =
        isDark ? const Color(0xFFAEA2C0) : const Color(0xFF867993);

    final player = PlayerScope.of(context);

    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        return PopScope(
          canPop: selectedIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && selectedIndex != 0 && mounted) {
              _changePage(0);
            }
          },
          child: Scaffold(
            backgroundColor: background,
            resizeToAvoidBottomInset: true,

            // IMPORTANT:
            // Keep content, mini-player and navigation in separate
            // layout areas instead of overlaying them using Stack.
            body: Column(
              children: [
                // Screen receives only the available content height.
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: _pages,
                  ),
                ),

                // Persistent playback controls and bottom navigation.
                SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MiniPlayer(),

                      Container(
                        height: 60,
                        margin: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: border,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _navItem(
                              0,
                              Icons.home_rounded,
                              'Home',
                              primary,
                              activeColor,
                              inactiveColor,
                              selectedFill,
                            ),
                            _navItem(
                              1,
                              Icons.search_rounded,
                              'Search',
                              primary,
                              activeColor,
                              inactiveColor,
                              selectedFill,
                            ),
                            _navItem(
                              2,
                              Icons.library_music_rounded,
                              'Library',
                              primary,
                              activeColor,
                              inactiveColor,
                              selectedFill,
                            ),
                            _navItem(
                              3,
                              Icons.settings_rounded,
                              'Settings',
                              primary,
                              activeColor,
                              inactiveColor,
                              selectedFill,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
    Color primary,
    Color activeColor,
    Color inactiveColor,
    Color selectedFill,
  ) {
    final selected = index == selectedIndex;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _changePage(index),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOutCubic,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? selectedFill
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? primary.withValues(alpha: 0.28)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 23,
                    color: selected ? activeColor : inactiveColor,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.1,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected ? activeColor : inactiveColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
