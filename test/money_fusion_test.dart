import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:money_fusion/money_fusion.dart';

void main() {
  test('moneyFusionVersion est alignée sur pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    final version = pubspec
        .firstWhere((line) => line.startsWith('version:'))
        .substring('version:'.length)
        .trim();

    expect(moneyFusionVersion, version);
  });
}
