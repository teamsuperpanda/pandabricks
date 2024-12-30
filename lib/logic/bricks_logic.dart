import 'package:flutter/material.dart';

class BrickShapes {
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
    // Panda shape (2x2)
    [
      [8, 8],
      [8, 8],
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
    Colors.white, // Panda shape (white while falling)
    Colors.grey, // Panda shape when locked at bottom
  ];
}
