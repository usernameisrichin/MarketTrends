// ============================================================
// shared/widgets/balance_visibility_wrapper.dart
// ============================================================
//
// Wraps any widget and shows a blurred overlay by default.
// Tapping the eye icon reveals the content.
//
// Used on: Dashboard total value, asset values, family net worth
//
// How the blur works:
//   - We paint a Stack: [actual_content, blur_overlay]
//   - When isHidden=true, the blur overlay is visible
//   - When isHidden=false, the content shows through
//
// For biometric unlock, wrap _toggleVisibility with:
//   final authenticated = await LocalAuthentication().authenticate(...)
//   if (authenticated) setState(() => _isHidden = false);
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';

class BalanceVisibilityWrapper extends StatefulWidget {
  /// The widget whose content should be hidden/revealed
  final Widget child;

  /// If true, starts in hidden (blurred) state
  final bool startHidden;

  const BalanceVisibilityWrapper({
    super.key,
    required this.child,
    this.startHidden = true,
  });

  @override
  State<BalanceVisibilityWrapper> createState() => _BalanceVisibilityWrapperState();
}

class _BalanceVisibilityWrapperState extends State<BalanceVisibilityWrapper> {
  late bool _isHidden;

  @override
  void initState() {
    super.initState();
    _isHidden = widget.startHidden;
  }

  void _toggleVisibility() {
    // For biometric:
    //   final auth = LocalAuthentication();
    //   final ok = await auth.authenticate(localizedReason: 'Reveal balance');
    //   if (ok) setState(() => _isHidden = false);
    setState(() => _isHidden = !_isHidden);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // ── Actual content ────────────────────────────────
        widget.child,

        // ── Blur overlay (only when hidden) ──────────────
        if (_isHidden)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
            ),
          ),

        // ── Eye toggle button ─────────────────────────────
        GestureDetector(
          onTap: _toggleVisibility,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              _isHidden ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
