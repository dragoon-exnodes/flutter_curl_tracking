import 'package:flutter/material.dart';
import 'curl_logs_view.dart';

/// A draggable floating button that opens the [CurlLogsView] when tapped.
///
/// Wrap your app's root widget with this to show the debug overlay.
/// Only use in debug/dev builds.
///
/// Pass [navigatorKey] if the overlay is placed above the Navigator
/// (e.g. inside MaterialApp.builder). This lets it push routes
/// even without a Navigator ancestor in the context.
///
/// ```dart
/// CurlTrackingOverlay(
///   navigatorKey: GlobalContext.navigatorKey,
///   child: child!,
/// )
/// ```
class CurlTrackingOverlay extends StatefulWidget {
  const CurlTrackingOverlay({
    super.key,
    required this.child,
    this.navigatorKey,
  });

  final Widget child;

  /// Optional navigator key to use when context has no Navigator ancestor.
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<CurlTrackingOverlay> createState() => _CurlTrackingOverlayState();
}

class _CurlTrackingOverlayState extends State<CurlTrackingOverlay> {
  late Offset _position;
  bool _isInitialized = false;

  void _openLogsView() {
    final route = MaterialPageRoute<void>(
      builder: (_) => const CurlLogsView(),
    );

    // Use navigatorKey if provided (for when context has no Navigator ancestor)
    if (widget.navigatorKey?.currentState != null) {
      widget.navigatorKey!.currentState!.push(route);
      return;
    }

    // Fallback: try context-based navigation
    try {
      Navigator.of(context, rootNavigator: true).push(route);
    } catch (_) {
      // Last resort: find navigator via context traversal
      try {
        Navigator.of(context).push(route);
      } catch (_) {
        debugPrint('CurlTrackingOverlay: No Navigator found. '
            'Pass navigatorKey to CurlTrackingOverlay.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double diameter = 44;

    if (!_isInitialized) {
      _position = Offset(
        size.width - diameter - 16,
        size.height - diameter - 120,
      );
      _isInitialized = true;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _openLogsView,
            onPanUpdate: (details) {
              setState(() {
                final maxX = size.width - diameter;
                final maxY = size.height - diameter;
                _position = Offset(
                  (_position.dx + details.delta.dx).clamp(0.0, maxX),
                  (_position.dy + details.delta.dy).clamp(0.0, maxY),
                );
              });
            },
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.terminal_rounded,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
