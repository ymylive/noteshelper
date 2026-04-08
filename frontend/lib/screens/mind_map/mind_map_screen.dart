import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:noteshelper/providers/note_provider.dart';
import 'package:noteshelper/screens/mind_map/mind_map_painter.dart';
import 'package:noteshelper/widgets/loading_widget.dart';
import 'package:noteshelper/widgets/error_widget.dart';

class MindMapScreen extends ConsumerWidget {
  final String noteId;

  const MindMapScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mindMapAsync = ref.watch(mindMapProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mind Map',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: mindMapAsync.when(
        loading: () => const LoadingWidget(message: 'Loading mind map...'),
        error: (error, _) => AppErrorWidget(
          message: 'Failed to load mind map',
          onRetry: () => ref.invalidate(mindMapProvider(noteId)),
        ),
        data: (root) {
          if (root == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_tree_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No mind map available for this note'),
                ],
              ),
            );
          }

          final isDark = theme.brightness == Brightness.dark;

          return InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(400),
            minScale: 0.3,
            maxScale: 3.0,
            child: SizedBox(
              width: 1200,
              height: 1200,
              child: CustomPaint(
                painter: MindMapPainter(
                  root: root,
                  lineColor: isDark
                      ? Colors.white.withOpacity(0.25)
                      : Colors.black.withOpacity(0.15),
                  nodeColor: isDark
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.primaryContainer,
                  textColor: isDark
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onPrimaryContainer,
                  nodeBorderColor: isDark
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.colorScheme.primary.withOpacity(0.3),
                ),
                size: const Size(1200, 1200),
              ),
            ),
          );
        },
      ),
    );
  }
}
