import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../curl_tracking.dart';
import '../http_logs_service.dart';

/// Self-contained HTTP request logs view with connect code display.
///
/// Shows the device connect code at the top and a scrollable list of
/// intercepted HTTP requests with expandable curl commands.
class CurlLogsView extends StatelessWidget {
  const CurlLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final logsService = HttpLogsService.instance;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Curl Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear logs',
            onPressed: logsService.clear,
          ),
        ],
      ),
      body: Column(
        children: [
          _ConnectCodeBanner(colorScheme: colorScheme, isDark: isDark),
          Expanded(
            child: AnimatedBuilder(
              animation: logsService,
              builder: (context, _) {
                final logs = logsService.logs;

                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.http_rounded,
                          size: 48,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No requests yet',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Requests will appear here in real-time',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _LogEntryCard(entry: logs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectCodeBanner extends StatefulWidget {
  const _ConnectCodeBanner({
    required this.colorScheme,
    required this.isDark,
  });

  final ColorScheme colorScheme;
  final bool isDark;

  @override
  State<_ConnectCodeBanner> createState() => _ConnectCodeBannerState();
}

class _ConnectCodeBannerState extends State<_ConnectCodeBanner> {
  String _code = '...';

  @override
  void initState() {
    super.initState();
    _loadCode();
  }

  Future<void> _loadCode() async {
    final code = await CurlTracking.getDeviceCode();
    if (mounted) {
      setState(() => _code = code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Connect Code',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: widget.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Code copied: $_code'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _code,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: widget.colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: widget.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter this code on the web dashboard',
            style: TextStyle(
              fontSize: 11,
              color: widget.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogEntryCard extends StatefulWidget {
  const _LogEntryCard({required this.entry});

  final HttpRequestLogEntry entry;

  @override
  State<_LogEntryCard> createState() => _LogEntryCardState();
}

class _LogEntryCardState extends State<_LogEntryCard> {
  bool _expanded = false;

  static const _methodColors = {
    'GET': Color(0xFF2AA198),
    'POST': Color(0xFFB58900),
    'PUT': Color(0xFF268BD2),
    'PATCH': Color(0xFF6C71C4),
    'DELETE': Color(0xFFDC322F),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final method = widget.entry.method.toUpperCase();
    final methodColor = _methodColors[method] ?? colorScheme.primary;
    final time = TimeOfDay.fromDateTime(widget.entry.timestamp);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${widget.entry.timestamp.second.toString().padLeft(2, '0')}';

    String displayPath;
    try {
      displayPath = Uri.parse(widget.entry.uri).path;
    } catch (_) {
      displayPath = widget.entry.uri;
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: methodColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      method,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: methodColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      displayPath,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 20,
                    color: colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox(
              width: double.infinity,
            ),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      widget.entry.curlCommand,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.entry.curlCommand),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Curl copied'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
