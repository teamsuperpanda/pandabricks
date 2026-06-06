import 'dart:math' as math;

import 'package:flutter/material.dart';

const _headerHeight = 120.0;
const _footerHeight = 100.0;
const _frameBezelWidth = 4.0;
const _frameCornerRadius = 40.0;
const _screenCornerRadius = 28.0;
const _frameHPadding = 28.0;
const _frameTopPadding = 24.0;
const _frameBottomPadding = 24.0;

class ScreenshotDecorator extends StatelessWidget {
  const ScreenshotDecorator({
    required this.child,
    required this.deviceWidth,
    required this.deviceHeight,
    this.tagline,
    this.marketingLine1,
    this.marketingLine2,
    this.rotationDegrees = 0,
    super.key,
  });

  final Widget child;
  final double deviceWidth;
  final double deviceHeight;
  final String? tagline;
  final String? marketingLine1;
  final String? marketingLine2;
  final double rotationDegrees;

  double get _frameWidth =>
      deviceWidth + _frameHPadding * 2 + _frameBezelWidth * 2;
  double get _frameHeight =>
      _frameTopPadding +
      _frameBezelWidth +
      deviceHeight +
      _frameBezelWidth +
      _frameBottomPadding;

  double get _rotatedFrameWidth {
    if (rotationDegrees == 0) return _frameWidth;
    final rad = rotationDegrees * math.pi / 180;
    return (_frameWidth * math.cos(rad)).abs() +
        (_frameHeight * math.sin(rad)).abs();
  }

  double get _rotatedFrameHeight {
    if (rotationDegrees == 0) return _frameHeight;
    final rad = rotationDegrees * math.pi / 180;
    return (_frameWidth * math.sin(rad)).abs() +
        (_frameHeight * math.cos(rad)).abs();
  }

  double get canvasWidth => math.max(_frameWidth, _rotatedFrameWidth);

  double get canvasHeight =>
      _headerHeight + _rotatedFrameHeight + _footerHeight;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: canvasWidth,
        height: canvasHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: const Color(0xFF0D1117)),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _headerHeight,
              child: _Header(tagline: tagline),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _footerHeight,
              child: _Footer(
                line1: marketingLine1,
                line2: marketingLine2,
              ),
            ),
            Positioned(
              top: _headerHeight,
              left: 0,
              right: 0,
              bottom: _footerHeight,
              child: Center(child: _buildFrame()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrame() {
    final frameContent = SizedBox(
      width: _frameWidth,
      height: _frameHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFF0D1117)),
          ),
          Positioned(
            top: _frameTopPadding,
            left: _frameHPadding,
            child: Container(
              width: deviceWidth + _frameBezelWidth * 2,
              height: deviceHeight + _frameBezelWidth * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_frameCornerRadius),
                border: Border.all(
                  color: Colors.grey.shade700,
                  width: _frameBezelWidth,
                ),
              ),
            ),
          ),
          Positioned(
            top: _frameTopPadding + _frameBezelWidth,
            left: _frameHPadding + _frameBezelWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_screenCornerRadius),
              child: SizedBox(
                width: deviceWidth,
                height: deviceHeight,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );

    if (rotationDegrees == 0) return frameContent;

    return Transform.rotate(
      angle: rotationDegrees * math.pi / 180,
      child: frameContent,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.tagline});

  final String? tagline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cruelty_free_rounded,
                color: Colors.cyanAccent,
                size: 32,
              ),
              const SizedBox(width: 10),
              Text(
                'PANDA BRICKS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Fredoka',
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tagline ?? 'A modern falling blocks game',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Fredoka',
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({this.line1, this.line2});

  final String? line1;
  final String? line2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            line1 ?? 'Classic mode  •  Time Challenge  •  Blitz mode',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Fredoka',
              color: Colors.grey.shade300,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            line2 ?? 'Special bricks  •  13 languages  •  Panda theme',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Fredoka',
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
