import 'dart:ui';

class MindMapNode {
  final String id;
  final String label;
  final List<MindMapNode> children;
  Offset position;

  MindMapNode({
    required this.id,
    required this.label,
    List<MindMapNode>? children,
    Offset? position,
  })  : children = children ?? [],
        position = position ?? Offset.zero;

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      children: json['children'] != null
          ? (json['children'] as List)
              .map((c) => MindMapNode.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      position: json['position'] != null
          ? Offset(
              (json['position']['x'] as num?)?.toDouble() ?? 0.0,
              (json['position']['y'] as num?)?.toDouble() ?? 0.0,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'children': children.map((c) => c.toJson()).toList(),
      'position': {
        'x': position.dx,
        'y': position.dy,
      },
    };
  }

  /// Recursively compute layout positions for the tree, starting from root.
  static void layoutTree(MindMapNode root, {double startX = 400, double startY = 60}) {
    _layoutSubtree(root, startX, startY, 0);
  }

  static double _layoutSubtree(MindMapNode node, double x, double y, int depth) {
    const double verticalSpacing = 100.0;
    const double horizontalSpacing = 160.0;

    if (node.children.isEmpty) {
      node.position = Offset(x, y);
      return horizontalSpacing;
    }

    double childX = x - ((node.children.length - 1) * horizontalSpacing / 2);
    double childY = y + verticalSpacing;
    double totalWidth = 0;

    for (final child in node.children) {
      double childWidth = _layoutSubtree(child, childX, childY, depth + 1);
      childX += childWidth;
      totalWidth += childWidth;
    }

    // Center the parent above its children
    double firstChildX = node.children.first.position.dx;
    double lastChildX = node.children.last.position.dx;
    node.position = Offset((firstChildX + lastChildX) / 2, y);

    return totalWidth > horizontalSpacing ? totalWidth : horizontalSpacing;
  }
}
