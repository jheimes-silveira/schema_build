import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import 'package:schema_build/schema_build.dart';

/// Paleta de widgets na sidebar esquerda.
///
/// Exibe uma grade de tipos de widgets registrados que podem ser arrastados
/// para o canvas para criar componentes de layout.
class WidgetPalette extends StatelessWidget {
  const WidgetPalette({super.key, required this.state});

  final SchemaEditorState state;

  @override
  Widget build(BuildContext context) {
    final definitions = Schemas.manager.getAllDefinitions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da seção
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'WIDGETS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        // Grade de widgets
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: definitions
                .map((def) => _PaletteItem(definition: def))
                .toList(),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _PaletteItem extends StatefulWidget {
  const _PaletteItem({required this.definition});

  final ComponentDefinition definition;

  @override
  State<_PaletteItem> createState() => _PaletteItemState();
}

class _PaletteItemState extends State<_PaletteItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragItemWidget(
      dragItemProvider: (request) async {
        debugPrint('[WidgetPalette] dragItemProvider called for: ${widget.definition.type}');
        final item = DragItem(
          localData: {
            'type': 'widget_palette',
            'widgetType': widget.definition.type,
          },
        );
        item.add(Formats.plainText(widget.definition.name));
        return item;
      },
      allowedOperations: () => [DropOperation.copy],
      child: DraggableWidget(
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 100,
            height: 72,
            decoration: BoxDecoration(
              color: _isHovered
                  ? const Color(0xFF2196F3).withValues(alpha: 0.08)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFF2196F3).withValues(alpha: 0.4)
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.widgets,
                  size: 24,
                  color: _isHovered
                      ? const Color(0xFF2196F3)
                      : Colors.grey.shade600,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.definition.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _isHovered
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

