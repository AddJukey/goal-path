import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows a «Готово» bar above the keyboard (iOS numeric pad has no Done key).
class KeyboardToolbarOverlay extends StatelessWidget {
  const KeyboardToolbarOverlay({super.key, required this.child});

  final Widget child;

  static void dismiss(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Stack(
      children: [
        child,
        if (bottomInset > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: Material(
              elevation: 8,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCardElevated
                  : AppColors.lightCard,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: () => dismiss(context),
                        child: const Text(
                          'Готово',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.mint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tap outside inputs to hide keyboard.
class DismissKeyboard extends StatelessWidget {
  const DismissKeyboard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => KeyboardToolbarOverlay.dismiss(context),
      behavior: HitTestBehavior.deferToChild,
      child: child,
    );
  }
}
