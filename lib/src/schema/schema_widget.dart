import 'package:flutter/material.dart';

import '../models/widget_node.dart';
import 'schema_component_controller.dart';
import 'schema_manager.dart';
import 'schema_action_scope.dart';

/// A widget that renders a [WidgetNode] tree using registered components.
///
/// Acts as the tree coordinator, delegating data state management
/// to the [SchemaComponentController].
class SchemaWidget extends StatelessWidget {
  const SchemaWidget({
    super.key,
    required this.node,
    this.dataOverrides,
    this.onAction,
  });

  /// The root node of the widget tree to be rendered.
  final WidgetNode node;

  /// Optional data to override or complement node state at runtime.
  final Map<String, dynamic>? dataOverrides;

  /// Callback triggered when an internal component emits an action.
  final void Function(WidgetNode node, String action, Object? data)? onAction;

  @override
  Widget build(BuildContext context) {
    final definition = Schemas.manager.getDefinition(node.type);

    if (definition == null) {
      return const SizedBox.shrink();
    }

    return SchemaActionScope(
      bus: _SchemaActionBusDelegate(onAction),
      child: SchemaComponentController(
        key: ValueKey(node.id),
        node: node,
        definition: definition,
        dataOverrides: dataOverrides,
        builder: (context, effectiveData) {
          return definition.builder(
            context,
            node,
            node.children
                .map(
                  (child) => SchemaWidget(
                    key: ValueKey(child.id),
                    node: child,
                    dataOverrides: dataOverrides,
                    onAction: onAction,
                  ),
                )
                .toList(),
            data: effectiveData,
          );
        },
      ),
    );
  }
}

class _SchemaActionBusDelegate implements SchemaActionBus {
  _SchemaActionBusDelegate(this.onAction);
  final void Function(WidgetNode node, String action, Object? data)? onAction;

  @override
  void emit(WidgetNode node, String action, Object? data) {
    onAction?.call(node, action, data);
  }
}
