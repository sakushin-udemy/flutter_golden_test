import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golden_toolkit/golden_toolkit.dart';

// Test Target file. Change here for your target.
import 'package:flutter_golden_test/main.dart';
import 'dart:io';

/*
flutter test --update-goldens
flutter test
 */

void main() {
  const iPhone55 =
      Device(name: 'iPhone55', size: Size(414, 736), devicePixelRatio: 3.0);
  const iPhone65 =
      Device(name: 'iPhone65', size: Size(414, 896), devicePixelRatio: 3.0);
  const iPad129 =
      Device(name: 'iPad129', size: Size(1366, 1024), devicePixelRatio: 2.0);

  testWidgets('description', (WidgetTester tester) async {});

  setUpAll(() async {
    final fontFile = File('test/assets/NotoSansJP-Regular.otf');
    expect(fontFile.existsSync(), true);
    final fontData = await fontFile.readAsBytes();
    final fontLoader = FontLoader('NotoSansJP');
    fontLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
    await fontLoader.load();

    await loadAppFonts();
  });

  testGoldens('app', (WidgetTester tester) async {
    final size = Size(414, 896);
    await tester.pumpWidgetBuilder(MyApp(), surfaceSize: size);
    await screenMatchesGolden(tester, 'myApp');
  });

  testGoldens('CounterText', (tester) async {
    await tester.pumpWidgetBuilder(CountText(counter: 1));
    await screenMatchesGolden(tester, 'countText');
  });

  testGoldens('CounterTextColumn', (tester) async {
    final builder = GoldenBuilder.column()
      ..addScenario('case 1', CountText(counter: 1))
      ..addScenario('case 2', CountText(counter: 2))
      ..addScenario('case 3', CountText(counter: 3))
      ..addScenario('case 4', CountText(counter: 4));
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'countTextColumn');
  });

  testGoldens('CounterTextGrid', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 2)
      ..addScenario('case 1', CountText(counter: 1))
      ..addScenario('case 2', CountText(counter: 2))
      ..addScenario('case 3', CountText(counter: 3))
      ..addScenario('case 4', CountText(counter: 4));
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'countTextGrid');
  });

  testGoldens('TextScaleFactor', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 2)
      ..addTextScaleScenario('case 1', CountText(counter: 1),
          textScaleFactor: 1.0)
      ..addTextScaleScenario('case 2', CountText(counter: 2),
          textScaleFactor: 2.0);
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'textScaleFactor');
  });

  testGoldens('SurfaceSize', (tester) async {
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 2)
      ..addTextScaleScenario('case 1', CountText(counter: 1),
          textScaleFactor: 1.0)
      ..addTextScaleScenario('case 2', CountText(counter: 2),
          textScaleFactor: 2.0)
      ..addTextScaleScenario('case 2', CountText(counter: 2),
          textScaleFactor: 3.2);
    await tester.pumpWidgetBuilder(
      builder.build(),
      surfaceSize: Size(1280, 300),
    );
    await screenMatchesGolden(tester, 'surfaceSize');
  });

  testGoldens('image', (tester) async {
    final builder = GoldenBuilder.column()
      ..addScenario('png', Image.asset('assets/flutter.png'))
      ..addScenario('Material Icons', const Icon(Icons.face));
    await tester.pumpWidgetBuilder(
      builder.build(),
    );
    await screenMatchesGolden(tester, 'image');
  });

  testGoldens('some devices', (tester) async {
    for (Device device in [iPhone55, iPhone65, iPad129]) {
      await tester.pumpWidgetBuilder(MyApp(), surfaceSize: device.size);
      await screenMatchesGolden(tester, 'myApp_${device.name}');
    }
  });

  testGoldens('tap', (tester) async {
    await tester.pumpWidgetBuilder(MyApp(), surfaceSize: iPhone65.size);
    await screenMatchesGolden(tester, 'tap_0');
    await tester.tap(find.byIcon(Icons.add));
    await screenMatchesGolden(tester, 'tap_1');
    await tester.tap(find.byIcon(Icons.add));
    await screenMatchesGolden(tester, 'tap_2');
    await tester.tap(find.byIcon(Icons.add));
    await screenMatchesGolden(tester, 'tap_3');
  });

  testGoldens('myAppMulti', (tester) async {
    List<Device> devices = [iPhone55, iPhone65, iPad129];
    await tester.pumpWidgetBuilder(MyApp());
    await multiScreenGolden(
      tester,
      'myAppMulti0',
      devices: devices,
    );
    await tester.tap(find.byIcon(Icons.add));
    await multiScreenGolden(
      tester,
      'myAppMulti1',
      devices: devices,
    );
  });

  testGoldens('multi devices, multi scenarios', (tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [iPhone55, iPhone65, iPad129])
      ..addScenario(widget: MyApp(), name: 'no tap')
      ..addScenario(
          widget: MyApp(),
          name: 'tap once',
          onCreate: (Key scenarioWidgetKey) async {
            final finder = find.descendant(
                of: find.byKey(scenarioWidgetKey),
                matching: find.byIcon(Icons.add));
            await tester.tap(finder);
          })
      ..addScenario(
          widget: MyApp(),
          name: 'tap five times',
          onCreate: (Key scenarioWidgetKey) async {
            final finder = find.descendant(
                of: find.byKey(scenarioWidgetKey),
                matching: find.byIcon(Icons.add));
            await tester.tap(finder);
            await tester.tap(finder);
            await tester.tap(finder);
            await tester.tap(finder);
            await tester.tap(finder);
          });

    await tester.pumpDeviceBuilder(builder);
    await screenMatchesGolden(tester, 'multiDevicesMultiScenario');
  });
}
