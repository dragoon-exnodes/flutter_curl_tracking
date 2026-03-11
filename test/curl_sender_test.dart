import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_curl_tracking/src/curl_sender.dart';

void main() {
  group('CurlSender', () {
    test('buildPayload creates correct JSON structure', () {
      final payload = CurlSender.buildPayload(
        deviceCode: 'ABC123',
        curl: 'curl --request GET --url https://example.com',
        method: 'GET',
        url: 'https://example.com',
      );

      expect(payload['device_code'], 'ABC123');
      expect(payload['curl'], 'curl --request GET --url https://example.com');
      expect(payload['method'], 'GET');
      expect(payload['url'], 'https://example.com');
      expect(payload['timestamp'], isA<int>());
    });
  });
}
