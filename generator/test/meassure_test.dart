import 'package:realm_generator/src/meassure.dart';
import 'package:test/test.dart';

void main() {
  test('human readable durations', () {
    expect(humanReadable(const Duration(microseconds: 1)), '1μs');
    expect(humanReadable(const Duration(milliseconds: 1)), '1ms');
    expect(humanReadable(const Duration(seconds: 1)), '1.0s');
    expect(humanReadable(const Duration(minutes: 1)), '1m 0s');
    expect(humanReadable(const Duration(hours: 1)), '1h 0m');
    expect(humanReadable(const Duration(days: 1)), '24h 0m');
  });
}
