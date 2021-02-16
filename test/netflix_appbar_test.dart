import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netflix_appbar/netflix_appbar.dart';

void main() {
  const MethodChannel channel = MethodChannel('netflix_appbar');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NetflixAppBar.platformVersion, '42');
  });
}
