import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_curl_tracking/src/curl_tracking_interceptor.dart';

void main() {
  group('CurlTrackingInterceptor', () {
    group('toCurl', () {
      test('converts GET request to curl string', () {
        final options = RequestOptions(
          path: 'https://api.example.com/users',
          method: 'GET',
          headers: {'Authorization': 'Bearer token123'},
        );

        final curl = CurlTrackingInterceptor.toCurl(options);

        expect(curl, contains('curl'));
        expect(curl, contains('--request GET'));
        expect(curl, contains('--url https://api.example.com/users'));
        expect(curl, contains("--header 'Authorization: Bearer token123'"));
      });

      test('converts POST request with body to curl string', () {
        final options = RequestOptions(
          path: 'https://api.example.com/users',
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          data: {'name': 'test'},
        );

        final curl = CurlTrackingInterceptor.toCurl(options);

        expect(curl, contains('--request POST'));
        expect(curl, contains('--data'));
        expect(curl, contains('"name":"test"'));
      });
    });
  });
}
