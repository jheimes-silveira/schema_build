import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:schema_build/schema_build.dart';
import '../schema_editor_state.dart';

/// Renderiza recursivamente uma árvore [WidgetNode] no canvas.
///
/// Cada nó é renderizado como seu widget Flutter correspondente com
/// destaque de seleção e suporte a drop aninhado para widgets de layout.
class CanvasNodeRenderer extends StatelessWidget {
  const CanvasNodeRenderer({
    super.key,
    required this.node,
    required this.state,
    this.index,
  });

  final WidgetNode node;
  final SchemaEditorState state;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final definition = Schemas.manager.getDefinition(node.type);
    final acceptsChildren = definition?.acceptsChildren ?? false;

    // Renderiza o widget base fora do ListenableBuilder para evitar reconstrução recursiva
    // da árvore inteira quando apenas a seleção muda ou um item é reordenado.
    final Widget renderedWidget = _renderNode(context);

    // Envolve o widget com o feedback de seleção de forma estável
    Widget content = Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (state.selectedWidgetId == node.id) {
            state.clearSelection();
          } else {
            state.selectWidget(node.id);
          }
        },
        child: ValueListenableBuilder<String?>(
          valueListenable: state.selectionChanged,
          builder: (context, selectedId, _) {
            final isSelected = selectedId == node.id;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: AbsorbPointer(
                absorbing: !acceptsChildren,
                child: renderedWidget,
              ),
            );
          },
        ),
      ),
    );

    // Se este nó aceita filhos, envolve com DropRegion
    if (node.canAcceptChildren) {
      content = _NestedDropZone(
        node: node,
        state: state,
        child: content,
      );
    }

    return content;
  }

  Widget _renderNode(BuildContext context) {
    final definition = Schemas.manager.getDefinition(node.type);
    if (definition == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red.shade50,
        child: Text('Componente desconhecido: ${node.type}',
            style: const TextStyle(color: Colors.red, fontSize: 10)),
      );
    }

    final children = node.children
        .map((child) => CanvasNodeRenderer(node: child, state: state))
        .toList();

    Widget built = SchemaComponentController(
      key: ValueKey(node.id),
      node: node,
      definition: definition,
      builder: (context, effectiveData) {
        return definition.builder(
          context,
          node,
          children,
          data: effectiveData,
        );
      },
    );

    // Se for um widget de layout que está vazio, mostra um placeholder
    if (definition.acceptsChildren && children.isEmpty) {
      built = Stack(
        alignment: Alignment.center,
        children: [
          built,
          _EmptySlot(label: definition.name),
        ],
      );
    }

    return built;
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40, minWidth: 60),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey.shade50,
      ),
      child: Center(
        child: Text(
          'Arraste para $label',
          style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NestedDropZone extends StatefulWidget {
  const _NestedDropZone({
    required this.node,
    required this.state,
    required this.child,
  });

  final WidgetNode node;
  final SchemaEditorState state;
  final Widget child;

  @override
  State<_NestedDropZone> createState() => _NestedDropZoneState();
}

class _NestedDropZoneState extends State<_NestedDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      hitTestBehavior: HitTestBehavior.translucent,
      onDropOver: (event) {
        final item = event.session.items.first;
        if (item.localData is Map) {
          final data = item.localData as Map;
          if (data['type'] == 'widget_palette') {
            return DropOperation.copy;
          }
        }
        return DropOperation.none;
      },
      onDropEnter: (_) => setState(() => _isDragOver = true),
      onDropLeave: (_) => setState(() => _isDragOver = false),
      onPerformDrop: (event) async {
        setState(() => _isDragOver = false);
        final item = event.session.items.first;
        if (item.localData is Map) {
          final data = item.localData as Map;
          if (data['type'] == 'widget_palette') {
            final type = data['widgetType'] as String?;
            if (type != null) {
              widget.state.addWidgetToParent(widget.node.id, type);
            }
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: _isDragOver
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                  width: 1.5,
                ),
              )
            : const BoxDecoration(),
        child: widget.child,
      ),
    );
  }
}
