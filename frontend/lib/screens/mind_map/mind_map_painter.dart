import 'package:flutter/material.dart';
import 'package:noteshelper/models/mind_map_node.dart';

class MindMapPainter extends CustomPainter {
  final MindMapNode root;
  final Color lineColor;
  final Color nodeColor;
  final Color textColor;
  final Color nodeBorderColor;

  MindMapPainter({
    required this.root,
    required this.lineColor,
    required this.nodeColor,
    required this.textColor,
    required this.nodeBorderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawConnections(canvas, root);
    _drawNodes(canvas, root, 0);
  }

  void _drawConnections(Canvas canvas, MindMapNode node) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final child in node.children) {
      final start = Offset(node.position.dx, node.position.dy + 20);
      final end = Offset(child.position.dx, child.position.dy - 20);

      // Draw curved connection line
      final controlY = (start.dy + end.dy) / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx,
          controlY,
          end.dx,
          controlY,
          end.dx,
          end.dy,
        );

      canvas.drawPath(path, paint);

      // Recurse
      _drawConnections(canvas, child);
    }
  }

  void _drawNodes(Canvas canvas, MindMapNode node, int depth) {
    final label = node.label;

    // Measure text
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: textColor,
        fontSize: depth == 0 ? 15 : 13,
        fontWeight: depth == 0 ? FontWeight.bold : FontWeight.w500,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: 140);

    final rectWidth = textPainter.width + 28;
    final rectHeight = textPainter.height + 20;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: node.position,
        width: rectWidth,
        height: rectHeight,
      ),
      const Radius.circular(12),
    );

    // Node fill
    final fillPaint = Paint()
      ..color = depth == 0
          ? nodeColor
          : nodeColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, fillPaint);

    // Node border
    final borderPaint = Paint()
      ..color = nodeBorderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rect, borderPaint);

    // Draw text centered in node
    textPainter.paint(
      canvas,
      Offset(
        node.position.dx - textPainter.width / 2,
        node.position.dy - textPainter.height / 2,
      ),
    );

    for (final child in node.children) {
      _drawNodes(canvas, child, depth + 1);
    }
  }

  @override
  bool shouldRepaint(covariant MindMapPainter oldDelegate) {
    return oldDelegate.root != root;
  }
}
