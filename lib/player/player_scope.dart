import 'package:flutter/material.dart';

import 'player_controller.dart';

class PlayerScope extends InheritedNotifier<PlayerController> {
  const PlayerScope({
    super.key,
    required PlayerController controller,
    required super.child,
  }) : super(
          notifier: controller,
        );

  static PlayerController of(BuildContext context) {
    final PlayerScope? scope =
        context.dependOnInheritedWidgetOfExactType<PlayerScope>();

    assert(
      scope != null,
      'PlayerScope not found in widget tree.',
    );

    return scope!.notifier!;
  }

  static PlayerController read(BuildContext context) {
    final PlayerScope? scope =
        context.getInheritedWidgetOfExactType<PlayerScope>();

    assert(
      scope != null,
      'PlayerScope not found in widget tree.',
    );

    return scope!.notifier!;
  }
}