import 'package:flutter_test/flutter_test.dart';
import 'package:wings_of_power_app/app/core/config/app_config.dart';

void main() {
  test('AppConfig.appName is Wings of Power', () {
    expect(AppConfig.appName, 'Wings of Power');
  });
}
