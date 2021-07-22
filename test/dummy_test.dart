import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_golden_test/main.dart';

void main() {
  testGoldens('app', (WidgetTester tester) async {
    await loadAppFonts();

    final size = Size(414, 896);
    await tester.pumpWidgetBuilder(MyApp(), surfaceSize: size);
    await screenMatchesGolden(tester, 'myApp_dummy');
  });
}
