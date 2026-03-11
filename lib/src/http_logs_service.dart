import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Model representing a single HTTP request log entry.
class HttpRequestLogEntry {
  const HttpRequestLogEntry({
    required this.method,
    required this.uri,
    required this.curlCommand,
    required this.timestamp,
  });

  final String method;
  final String uri;
  final String curlCommand;
  final DateTime timestamp;
}

/// In-memory HTTP request logs storage for debugging/QC purposes.
///
/// This service keeps only the most recent [maxEntries] requests in memory.
class HttpLogsService extends ChangeNotifier {
  HttpLogsService._();

  static final HttpLogsService _instance = HttpLogsService._();
  static HttpLogsService get instance => _instance;

  static const int maxEntries = 200;

  final List<HttpRequestLogEntry> _logs = <HttpRequestLogEntry>[];

  UnmodifiableListView<HttpRequestLogEntry> get logs =>
      UnmodifiableListView(_logs);

  void addLog({
    required String method,
    required String uri,
    required String curlCommand,
    DateTime? timestamp,
  }) {
    final entry = HttpRequestLogEntry(
      method: method,
      uri: uri,
      curlCommand: curlCommand,
      timestamp: (timestamp ?? DateTime.now()).toLocal(),
    );

    _logs.insert(0, entry);

    if (_logs.length > maxEntries) {
      _logs.removeRange(maxEntries, _logs.length);
    }

    notifyListeners();
  }

  void clear() {
    if (_logs.isEmpty) return;
    _logs.clear();
    notifyListeners();
  }
}
