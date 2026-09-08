import 'package:flutter/material.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() =>
      _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState
    extends State<ConnectedDevicesScreen> {
  static const Color _purple = Color(0xFF9B6BFF);

  final List<_Device> _devices = [
    const _Device(
      name: 'This Device',
      type: 'Android Phone',
      icon: Icons.smartphone_rounded,
      current: true,
    ),
  ];

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF080812)
        : const Color(0xFFF7F5FA);
  }

  Color _card(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF11111D)
        : Colors.white;
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? Colors.white
        : const Color(0xFF18151D);
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFAAA6B5)
        : const Color(0xFF6F6878);
  }

  Color _mutedText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF85818F)
        : const Color(0xFF7A7483);
  }

  Color _sectionText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF8E8A9A)
        : const Color(0xFF6F6878);
  }

  Color _border(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFE3DDEB);
  }

  Color _iconBackground(BuildContext context) {
    return _isDark(context)
        ? _purple.withValues(alpha: 0.12)
        : const Color(0xFFF0E8FF);
  }

  Color _infoBackground(BuildContext context) {
    return _purple.withValues(alpha: 0.08);
  }

  Color _infoBorder(BuildContext context) {
    return _purple.withValues(alpha: 0.18);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _background(context),
      appBar: AppBar(
        backgroundColor: _background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: _primaryText(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Connected Devices',
          style: TextStyle(
            color: _primaryText(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _infoBackground(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _infoBorder(context),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.devices_rounded,
                  color: theme.colorScheme.primary,
                  size: 27,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    'Manage devices connected to your SONEXA account.',
                    style: TextStyle(
                      color: _secondaryText(context),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'YOUR DEVICES',
            style: TextStyle(
              color: _sectionText(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 12),

          ..._devices.map(
            (device) => _deviceTile(
              context,
              device,
            ),
          ),

          const SizedBox(height: 14),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _addDevice,
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: _card(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(
                      alpha: 0.25,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: _iconBackground(context),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect a device',
                            style: TextStyle(
                              color: _primaryText(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Connect another device to SONEXA',
                            style: TextStyle(
                              color: _mutedText(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'ABOUT DEVICES',
            style: TextStyle(
              color: _sectionText(context),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Devices connected to your account can access your SONEXA music experience. Remove any device you no longer use.',
            style: TextStyle(
              color: _mutedText(context),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceTile(
    BuildContext context,
    _Device device,
  ) {
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: device.current
              ? theme.colorScheme.primary.withValues(alpha: 0.30)
              : _border(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _iconBackground(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              device.icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (device.current) ...[
                      const SizedBox(width: 7),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  device.type,
                  style: TextStyle(
                    color: _mutedText(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (!device.current)
            IconButton(
              onPressed: () => _removeDevice(device),
              icon: Icon(
                Icons.more_vert_rounded,
                color: _mutedText(context),
              ),
            ),
        ],
      ),
    );
  }

  void _addDevice() {
    final bool dark = _isDark(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Device connection will be available soon',
        ),
        backgroundColor: dark
            ? const Color(0xFF21182C)
            : const Color(0xFF6D3DB8),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeDevice(_Device device) {
    setState(() {
      _devices.remove(device);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${device.name} removed'),
        backgroundColor: _isDark(context)
            ? const Color(0xFF21182C)
            : const Color(0xFF6D3DB8),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _Device {
  final String name;
  final String type;
  final IconData icon;
  final bool current;

  const _Device({
    required this.name,
    required this.type,
    required this.icon,
    required this.current,
  });
}