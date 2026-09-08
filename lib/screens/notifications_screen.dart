import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;

  bool isRead;

  _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
  }) : isRead = false;
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  static const Color _purple = Color(0xFF9B6BFF);

  late List<_NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();

    _notifications = <_NotificationItem>[
      _NotificationItem(
        icon: Icons.music_note_rounded,
        iconColor: const Color(0xFFB45CFF),
        title: 'New music for you',
        message:
            'Discover fresh tracks based on your taste.',
        time: 'Just now',
      ),
      _NotificationItem(
        icon: Icons.auto_awesome_rounded,
        iconColor: const Color(0xFFFFB45C),
        title: 'Your daily mix is ready',
        message:
            'We created a new mix for your listening mood.',
        time: '10 min ago',
      ),
      _NotificationItem(
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFFFF5FA4),
        title: 'Liked songs',
        message:
            'Your favorite songs are waiting for you.',
        time: '1 hour ago',
      ),
      _NotificationItem(
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xFF5CB8FF),
        title: 'Trending now',
        message:
            'Check out the songs everyone is listening to.',
        time: '2 hours ago',
      ),
    ];
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF07070D)
        : const Color(0xFFF7F5FA);
  }

  Color _appBarColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF07070D)
        : const Color(0xFFF7F5FA);
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF111017)
        : Colors.white;
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF29232F)
        : const Color(0xFFE3DDEB);
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? Colors.white
        : const Color(0xFF18151D);
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF8B8494)
        : const Color(0xFF6F6878);
  }

  Color _timeText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF655E6E)
        : const Color(0xFF928B9D);
  }

  Color _iconBackground(
    BuildContext context,
    Color iconColor,
  ) {
    return iconColor.withValues(
      alpha: _isDark(context) ? 0.12 : 0.10,
    );
  }

  Color _snackBarColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF21182C)
        : const Color(0xFF6D3DB8);
  }

  int get _unreadCount {
    return _notifications
        .where(
          (_NotificationItem notification) =>
              !notification.isRead,
        )
        .length;
  }

  void _toggleRead(int index) {
    if (index < 0 || index >= _notifications.length) {
      return;
    }

    final bool wasRead = _notifications[index].isRead;

    setState(() {
      _notifications[index].isRead = !wasRead;
    });

    _showMessage(
      wasRead
          ? 'Notification marked as unread'
          : 'Notification marked as read',
    );
  }

  void _deleteNotification(int index) {
    if (index < 0 || index >= _notifications.length) {
      return;
    }

    final _NotificationItem removed =
        _notifications[index];

    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Notification deleted',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _snackBarColor(context),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            if (!mounted) {
              return;
            }

            setState(() {
              final int insertIndex =
                  index.clamp(
                0,
                _notifications.length,
              );

              _notifications.insert(
                insertIndex,
                removed,
              );
            });
          },
        ),
      ),
    );
  }

  void _markAllAsRead() {
    if (_notifications.isEmpty) {
      return;
    }

    final bool hasUnread = _notifications.any(
      (_NotificationItem notification) =>
          !notification.isRead,
    );

    if (!hasUnread) {
      _showMessage(
        'All notifications are already read',
      );
      return;
    }

    setState(() {
      for (final _NotificationItem notification
          in _notifications) {
        notification.isRead = true;
      }
    });

    _showMessage(
      'All notifications marked as read',
    );
  }

  Future<void> _clearAll() async {
    if (_notifications.isEmpty) {
      return;
    }

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final bool dark = _isDark(dialogContext);

        return AlertDialog(
          backgroundColor: dark
              ? const Color(0xFF17131F)
              : Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Clear all notifications?',
            style: TextStyle(
              color: _primaryText(dialogContext),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'All notifications will be removed from this screen.',
            style: TextStyle(
              color: _secondaryText(dialogContext),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _secondaryText(dialogContext),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: _purple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _notifications.clear();
    });

    _showMessage('All notifications cleared');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _snackBarColor(context),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationActions(int index) {
    if (index < 0 || index >= _notifications.length) {
      return;
    }

    final _NotificationItem notification =
        _notifications[index];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _cardColor(context),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _isDark(sheetContext)
                        ? const Color(0xFF4A4353)
                        : const Color(0xFFD0C9D8),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _iconBackground(
                          sheetContext,
                          notification.iconColor,
                        ),
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                      child: Icon(
                        notification.icon,
                        color: notification.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _primaryText(
                            sheetContext,
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  color: _borderColor(sheetContext),
                  height: 1,
                ),
                const SizedBox(height: 6),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  leading: Icon(
                    notification.isRead
                        ? Icons
                            .mark_email_unread_outlined
                        : Icons
                            .mark_email_read_outlined,
                    color: _purple,
                  ),
                  title: Text(
                    notification.isRead
                        ? 'Mark as unread'
                        : 'Mark as read',
                    style: TextStyle(
                      color: _primaryText(sheetContext),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _toggleRead(index);
                  },
                ),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 2,
                  ),
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF5F6D),
                  ),
                  title: Text(
                    'Delete notification',
                    style: TextStyle(
                      color: _primaryText(sheetContext),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _deleteNotification(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openNotification(int index) {
    if (index < 0 || index >= _notifications.length) {
      return;
    }

    final _NotificationItem notification =
        _notifications[index];

    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
    }

    _showMessage(
      '${notification.title} opened',
    );
  }

  @override
  Widget build(BuildContext context) {
    final int unreadCount = _unreadCount;

    return Scaffold(
      backgroundColor: _background(context),
      appBar: AppBar(
        backgroundColor: _appBarColor(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _primaryText(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: _primaryText(context),
              ),
              color: _cardColor(context),
              onSelected: (String value) {
                if (value == 'read') {
                  _markAllAsRead();
                } else if (value == 'clear') {
                  _clearAll();
                }
              },
              itemBuilder: (BuildContext menuContext) {
                return [
                  PopupMenuItem<String>(
                    value: 'read',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.done_all_rounded,
                          size: 20,
                          color: _purple,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Mark all as read',
                          style: TextStyle(
                            color: _primaryText(
                              menuContext,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_sweep_outlined,
                          size: 20,
                          color: Color(0xFFFF5F6D),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Clear all',
                          style: TextStyle(
                            color: _primaryText(
                              menuContext,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _emptyState(context)
          : ListView(
              physics:
                  const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                30,
              ),
              children: [
                if (unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: Text(
                      '$unreadCount unread notification'
                      '${unreadCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                for (
                  int index = 0;
                  index < _notifications.length;
                  index++
                ) ...[
                  _notificationCard(
                    context: context,
                    index: index,
                    notification:
                        _notifications[index],
                  ),
                  if (index !=
                      _notifications.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _notificationCard({
    required BuildContext context,
    required int index,
    required _NotificationItem notification,
  }) {
    final bool isRead = notification.isRead;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openNotification(index),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isRead ? 0.62 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _iconBackground(
                        context,
                        notification.iconColor,
                      ),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 22,
                    ),
                  ),
                  if (!isRead)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: _purple,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _cardColor(context),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _primaryText(
                                context,
                              ),
                              fontSize: 12.5,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () =>
                              _showNotificationActions(
                            index,
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: _secondaryText(
                              context,
                            ),
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 9.5,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.time,
                      style: TextStyle(
                        color: _timeText(context),
                        fontSize: 8,
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

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? const Color(0xFF17111F)
                    : const Color(0xFFF0E8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 36,
                color: _purple,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No notifications',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'You are all caught up.\nNew updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _notifications = [
                    _NotificationItem(
                      icon: Icons.music_note_rounded,
                      iconColor:
                          const Color(0xFFB45CFF),
                      title: 'New music for you',
                      message:
                          'Discover fresh tracks based on your taste.',
                      time: 'Just now',
                    ),
                  ];
                });
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: BorderSide(
                  color:
                      _purple.withValues(alpha: 0.45),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}