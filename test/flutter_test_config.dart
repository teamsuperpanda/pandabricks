import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

Future<void> testExecutable(Future<void> Function() testRunner) async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  final fontDir = '$flutterRoot/bin/cache/artifacts/material_fonts';

  final materialIcons =
      await File('$fontDir/MaterialIcons-Regular.otf').readAsBytes();
  final iconLoader = FontLoader('MaterialIcons');
  iconLoader.addFont(Future<ByteData>.value(materialIcons.buffer.asByteData()));
  await iconLoader.load();

  final fredokaDir = '${Directory.current.path}/assets/fonts';

  final fredokaRegular =
      await File('$fredokaDir/Fredoka-Regular.ttf').readAsBytes();
  final fredokaMedium =
      await File('$fredokaDir/Fredoka-Medium.ttf').readAsBytes();
  final fredokaBold =
      await File('$fredokaDir/Fredoka-Bold.ttf').readAsBytes();

  final fredokaLoader = FontLoader('Fredoka');
  fredokaLoader
      .addFont(Future<ByteData>.value(fredokaRegular.buffer.asByteData()));
  fredokaLoader
      .addFont(Future<ByteData>.value(fredokaMedium.buffer.asByteData()));
  fredokaLoader.addFont(Future<ByteData>.value(fredokaBold.buffer.asByteData()));
  await fredokaLoader.load();

  await testRunner();
}
