import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import 'package:schema_build/schema_build.dart';

/// Zona de drop que envolve o canvas do preview do telefone.
///
/// Usa [DropRegion] de `super_drag_and_drop` para aceitar widgets arrastados
/// da paleta e adicioná-los à raiz do canvas.
class CanvasDropZone extends StatefulWidget {
  const CanvasDropZone({
    super.key,
    required this.state,
    required this.child,
  });

  final SchemaEditorState state;
  final Widget child;

  @override
  State<CanvasDropZone> createState() => _CanvasDropZoneState();
}

class _CanvasDropZoneState extends State<CanvasDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.opaque,
      onDropOver: (event) {
        final item = event.session.items.first;
        if (item.localData is Map) {
          if (!_isDragOver) {
            setState(() => _isDragOver = true);
          }
          return DropOperation.copy;
        }
        return DropOperation.none;
      },
      onDropEnter: (event) {
        setState(() => _isDragOver = true);
      },
      onDropLeave: (event) {
        setState(() => _isDragOver = false);
      },
      onPerformDrop: (event) async {
        setState(() => _isDragOver = false);
        final item = event.session.items.first;

        if (item.localData is Map) {
          final data = item.localData as Map;

          // Handle widget palette drops
          if (data['type'] == 'widget_palette') {
            final type = data['widgetType'] as String?;
            if (type != null) {
              widget.state.addWidgetToCanvas(type);
            }
            return;
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: _isDragOver
              ? Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                  width: 3,
                )
              : null,
          boxShadow: _isDragOver
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

