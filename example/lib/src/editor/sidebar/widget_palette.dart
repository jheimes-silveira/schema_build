import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:schema_build/schema_build.dart';
import '../schema_editor_state.dart';

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
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Text(
            'COMPONENTES DISPONÍVEIS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Color(0xFF616161), // grey[700]
            ),
          ),
        ),

        // Lista de widgets
        ...definitions.map((def) => _PaletteItem(definition: def)),

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
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? const Color(0xFFF0F0F0)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFFE0E0E0)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? const Color(0xFF2196F3).withValues(alpha: 0.1)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(widget.definition.type),
                  size: 20,
                  color: _isHovered ? const Color(0xFF2196F3) : const Color(0xFF757575),
                ),
              ),
              title: Text(
                widget.definition.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? const Color(0xFF212121) : const Color(0xFF424242),
                ),
              ),
              subtitle: Text(
                widget.definition.description,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF757575), // grey[600]
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'texto': return Icons.title;
      case 'container': return Icons.check_box_outline_blank;
      case 'coluna': return Icons.view_column_outlined;
      case 'linha': return Icons.view_headline;
      case 'imagem': return Icons.image_outlined;
      case 'botao': return Icons.smart_button;
      case 'icone': return Icons.star_border;
      default: return Icons.widgets_outlined;
    }
  }
}
