import 'package:dio/dio.dart';

class CurlSender {
  final Dio _dio;
  final String _serverUrl;

  CurlSender({required String serverUrl})
      : _serverUrl = serverUrl,
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ));

  /// Sends curl log to server. Fire-and-forget: errors are swallowed.
  Future<void> send({
    required String deviceCode,
    required String curl,
    required String method,
    required String url,
  }) async {
    try {
      await _dio.post(
        '$_serverUrl/api/curl-log',
        data: buildPayload(
          deviceCode: deviceCode,
          curl: curl,
          method: method,
          url: url,
        ),
      );
    } catch (_) {
      // Swallow errors — never break the app's network calls
    }
  }

  /// Builds the JSON payload. Exposed for testing.
  static Map<String, dynamic> buildPayload({
    required String deviceCode,
    required String curl,
    required String method,
    required String url,
  }) {
    return {
      'device_code': deviceCode,
      'curl': curl,
      'method': method,
      'url': url,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
