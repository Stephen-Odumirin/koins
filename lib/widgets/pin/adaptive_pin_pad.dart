import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'pin_dots.dart';
import '../../l10n/app_localizations.dart';

const double _maxKeySize = 88;

/// Numeric keypad that scales to the screen. Tracks its own digits, shows
/// [PinDots], and calls [onCompleted] once [length] digits are entered.
/// Call [AdaptivePinPadState.clear] through a GlobalKey to reset it.
class AdaptivePinPad extends StatefulWidget {
  const AdaptivePinPad({
    super.key,
    required this.onCompleted,
    required this.length,
  });

  final void Function(String digits) onCompleted;
  final int length;

  @override
  State<AdaptivePinPad> createState() => AdaptivePinPadState();
}

class AdaptivePinPadState extends State<AdaptivePinPad> {
  String _digits = '';

  void clear() {
    if (!mounted) return;
    setState(() => _digits = '');
  }

  void _add(String d) {
    if (_digits.length >= widget.length) return;
    HapticFeedback.selectionClick();
    setState(() => _digits += d);
    if (_digits.length == widget.length) widget.onCompleted(_digits);
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final size = math
            .min(width / 4, height / 7)
            .clamp(AppSpacing.keyMinSize, _maxKeySize);
        Widget digit(String d) => _PinKey(
          key: Key('pin-key-$d'),
          size: size,
          semanticLabel: d,
          onTap: () => _add(d),
          child: Text(d),
        );
        final blank = SizedBox(width: size, height: size);
        Widget row(List<Widget> cells) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                cells[i],
              ],
            ],
          ),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PinDots(length: widget.length, filled: _digits.length),
            const SizedBox(height: AppSpacing.sm),
            row([digit('1'), digit('2'), digit('3')]),
            row([digit('4'), digit('5'), digit('6')]),
            row([digit('7'), digit('8'), digit('9')]),
            row([
              blank,
              digit('0'),
              _PinKey(
                key: const Key('pin-backspace'),
                size: size,
                semanticLabel: AppLocalizations.of(context)!.pinDelete,
                onTap: _backspace,
                child: const Icon(Icons.backspace_outlined),
              ),
            ]),
          ],
        );
      },
    );
  }
}

class _PinKey extends StatefulWidget {
  const _PinKey({
    super.key,
    required this.size,
    required this.onTap,
    required this.child,
    required this.semanticLabel,
  });

  final double size;
  final VoidCallback onTap;
  final Widget child;
  final String semanticLabel;

  @override
  State<_PinKey> createState() => _PinKeyState();
}

class _PinKeyState extends State<_PinKey> {
  bool _pressed = false;

  void _set(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pressed
                  ? AppColors.brand.withValues(alpha: 0.35)
                  : AppColors.surface,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: widget.size * 0.36,
                fontWeight: FontWeight.w600,
                color: AppColors.heading,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  size: widget.size * 0.34,
                  color: AppColors.heading,
                ),
                child: FittedBox(fit: BoxFit.scaleDown, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
