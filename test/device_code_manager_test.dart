import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_curl_tracking/src/device_code_manager.dart';

void main() {
  group('DeviceCodeManager', () {
    test('generateCode returns 6-character uppercase alphanumeric string', () {
      final code = DeviceCodeManager.generateCode(Random(42));
      expect(code.length, 6);
      expect(RegExp(r'^[A-Z0-9]{6}$').hasMatch(code), isTrue);
    });

    test('generateCode produces different codes with different seeds', () {
      final code1 = DeviceCodeManager.generateCode(Random(1));
      final code2 = DeviceCodeManager.generateCode(Random(2));
      expect(code1, isNot(equals(code2)));
    });
  });
}
