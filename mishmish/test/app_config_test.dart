import 'package:flutter_test/flutter_test.dart';
import 'package:mishmish/config/app_config.dart';

void main() {
  setUp(() {
    AppConfig.overrideHost = null;
    AppConfig.activeHost = '127.0.0.1';
  });

  tearDown(() {
    AppConfig.overrideHost = null;
    AppConfig.activeHost = '127.0.0.1';
  });

  test('default baseUrl targets local api', () {
    expect(AppConfig.baseUrl, 'http://127.0.0.1:8000/api');
  });

  test('overrideHost switches baseUrl for physical devices', () {
    AppConfig.overrideHost = '192.168.1.100';
    expect(AppConfig.baseUrl, 'http://192.168.1.100:8000/api');
  });

  test('serverRoot strips the /api suffix for image urls', () {
    expect(AppConfig.serverRoot, 'http://127.0.0.1:8000');
  });

  test('request timeout is generous enough for real networks', () {
    expect(AppConfig.requestTimeout.inSeconds, greaterThanOrEqualTo(8));
  });
}
