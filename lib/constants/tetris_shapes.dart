import 'package:flutter/material.dart';

class TetrisShapes {
  static const List<List<List<int>>> shapes = [
    // I shape
    [
      [1, 1, 1, 1],
    ],
    // J shape
    [
      [0, 0, 1],
      [1, 1, 1],
    ],
    // L shape
    [
      [1, 0, 0],
      [1, 1, 1],
    ],
    // O shape
    [
      [1, 1],
      [1, 1],
    ],
    // S shape
    [
      [0, 1, 1],
      [1, 1, 0],
    ],
    // T shape
    [
      [0, 1, 0],
      [1, 1, 1],
    ],
    // Z shape
    [
      [1, 1, 0],
      [0, 1, 1],
    ],
  ];

  static const List<Color> colors = [
    Colors.cyan, // I shape
    Colors.blue, // J shape
    Colors.orange, // L shape
    Colors.yellow, // O shape
    Colors.green, // S shape
    Colors.purple, // T shape
    Colors.red, // Z shape
  ];
}
