import 'dart:convert';
import 'package:dio/dio.dart';
import 'curl_tracking.dart';
import 'http_logs_service.dart';

class CurlTrackingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curlCommand = toCurl(options);

    // Send to remote server
    CurlTracking.instance?.sendCurlLog(
      curl: curlCommand,
      method: options.method,
      url: options.uri.toString(),
    );

    // Store locally for in-app log viewer
    HttpLogsService.instance.addLog(
      method: options.method,
      uri: options.uri.toString(),
      curlCommand: curlCommand,
    );

    super.onRequest(options, handler);
  }

  /// Converts a Dio RequestOptions to a curl command string.
  static String toCurl(RequestOptions options) {
    final buffer = StringBuffer('curl');
    buffer.write(' --request ${options.method}');

    // Headers
    options.headers.forEach((key, value) {
      final headerValue = value is List ? value.join(',') : value.toString();
      buffer.write(
        " --header '${_escapeSingleQuotes(key)}: ${_escapeSingleQuotes(headerValue)}'",
      );
    });

    // Data
    final data = options.data;
    if (data != null) {
      final body = data is String ? data : jsonEncode(data);
      buffer.write(" --data '${_escapeSingleQuotes(body)}'");
    }

    // URL
    buffer.write(' --url ${options.uri}');

    return buffer.toString();
  }

  static String _escapeSingleQuotes(String value) {
    return value.replaceAll("'", "'\\''");
  }
}
