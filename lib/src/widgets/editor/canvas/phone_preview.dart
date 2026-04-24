import 'package:flutter/material.dart';

import 'package:schema_build/schema_build.dart';
import 'canvas_node_renderer.dart';

/// A phone-shaped preview that renders the current schema configuration.
///
/// Includes a simulated status bar and a content area displaying the widget tree.
class PhonePreview extends StatelessWidget {
  const PhonePreview({super.key, required this.state});

  final SchemaEditorState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final phoneHeight = constraints.maxHeight * 0.9;
            final phoneWidth = phoneHeight * 0.48; // Proporção aproximada de um smartphone moderno

            return Container(
              width: phoneWidth,
              height: phoneHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.shade800, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  children: [
                    // Status bar
                    _StatusBar(),

                    // Content area
                    Expanded(
                      child: GestureDetector(
                        onTap: () => state.clearSelection(),
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          color: state.config.backgroundColor,
                          child: _buildContent(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent() {
    final nodes = state.rootNodes;

    if (nodes.isEmpty) {
      return _EmptyCanvas();
    }

    return ReorderableListView(
      padding: const EdgeInsets.all(8),
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        state.reorderWidgets(oldIndex, newIndex);
      },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Material(
              color: Colors.transparent,
              elevation: 0,
              child: child,
            );
          },
        );
      },
      children: nodes
          .asMap()
          .entries
          .map((entry) => Padding(
                key: ValueKey(entry.value.id),
                padding: const EdgeInsets.only(bottom: 4),
                child: CanvasNodeRenderer(
                  node: entry.value,
                  state: state,
                  index: entry.key,
                ),
              ))
          .toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Icon(Icons.signal_cellular_4_bar,
              size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Icon(Icons.wifi, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Icon(Icons.battery_full, size: 12, color: Colors.grey.shade700),
        ],
      ),
    );
  }
}

class _EmptyCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  const Color(0xFF2196F3).withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Icon(
              Icons.touch_app,
              size: 28,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Drag widgets here',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575), // grey[600]
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Drag widgets from the sidebar palette to build your application layout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
