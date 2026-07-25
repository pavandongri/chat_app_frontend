import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tiled doodle-pattern wallpaper for the chat conversation screen only
/// (not the chat list). Built from Material glyphs rather than a bitmap
/// asset — the reference look (WhatsApp's chat wallpaper) is a licensed
/// asset we can't ship, so this reproduces the effect procedurally and
/// adapts it to the current theme brightness.
class ChatBackgroundPattern extends StatelessWidget {
  const ChatBackgroundPattern({super.key});

  static const _glyphs = [
    Icons.chat_bubble_outline,
    Icons.favorite_border,
    Icons.star_border_rounded,
    Icons.circle_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.chatWallpaperDark
            : AppColors.chatWallpaperLight,
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DoodlePatternPainter(
            glyphColor: isDark
                ? AppColors.chatDoodleDark
                : AppColors.chatDoodleLight,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _DoodlePatternPainter extends CustomPainter {
  const _DoodlePatternPainter({required this.glyphColor});

  final Color glyphColor;

  static const _tileSize = 64.0;
  static const _glyphSize = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final columns = (size.width / _tileSize).ceil() + 1;
    final rows = (size.height / _tileSize).ceil() + 1;
    var glyphIndex = 0;

    for (var row = -1; row < rows; row++) {
      final rowOffset = row.isOdd ? _tileSize / 2 : 0.0;
      for (var col = -1; col < columns; col++) {
        final glyph = ChatBackgroundPattern
            ._glyphs[glyphIndex % ChatBackgroundPattern._glyphs.length];
        glyphIndex++;
        _paintGlyph(
          canvas,
          glyph,
          Offset(col * _tileSize + rowOffset, row * _tileSize),
        );
      }
    }
  }

  void _paintGlyph(Canvas canvas, IconData icon, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: _glyphSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: glyphColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _DoodlePatternPainter oldDelegate) =>
      oldDelegate.glyphColor != glyphColor;
}
