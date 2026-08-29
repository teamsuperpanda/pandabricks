import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/models/game_types.dart';
import 'package:pandabricks/widgets/game/draw_board.dart';
import 'package:pandabricks/widgets/game/game_palette.dart';

void main() {
  group('drawBoard', () {
    test('buildShaderGradients covers the full palette', () {
      final gradients = buildShaderGradients(kGamePalette);

      expect(gradients.length, kGamePalette.length);
      for (var i = 0; i < kGamePalette.length; i++) {
        expect(gradients[i], isNotNull);
      }
    });

    test('renders an empty board without throwing', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      drawBoard(
        canvas,
        const Size(300, 600),
        10,
        20,
        const [],
        const [],
        kGamePalette,
        buildShaderGradients(kGamePalette),
      );

      expect(recorder.endRecording(), isNotNull);
    });

    test('renders filled and ghost cells without throwing', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const cells = [
        CellRender(x: 0, y: 19, colorIndex: 0, isGhost: false),
        CellRender(x: 5, y: 5, colorIndex: 7, isGhost: false),
        CellRender(x: 5, y: 15, colorIndex: 2, isGhost: true),
      ];

      drawBoard(
        canvas,
        const Size(300, 600),
        10,
        20,
        cells,
        const [],
        kGamePalette,
        buildShaderGradients(kGamePalette),
      );

      expect(recorder.endRecording(), isNotNull);
    });

    test('renders sparkle effects without throwing', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const effects = [
        EffectRender(x: 3, y: 0, type: EffectType.column, alpha: 160),
        EffectRender(x: 0, y: 18, type: EffectType.row, alpha: 80),
      ];

      drawBoard(
        canvas,
        const Size(300, 600),
        10,
        20,
        const [],
        effects,
        kGamePalette,
        buildShaderGradients(kGamePalette),
      );

      expect(recorder.endRecording(), isNotNull);
    });
  });
}
