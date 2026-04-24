import 'package:flutter/material.dart';
import '../models/widget_node.dart';

/// Define o barramento de comunicação de ações para componentes do schema.
abstract class SchemaActionBus {
  /// Emite uma ação do componente para o App Host.
  void emit(WidgetNode node, String action, Object? data);
}

/// Scope que provê o [SchemaActionBus] para os componentes abaixo dele na árvore.
class SchemaActionScope extends InheritedWidget {
  const SchemaActionScope({
    super.key,
    required this.bus,
    required super.child,
  });

  final SchemaActionBus bus;

  static SchemaActionBus of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SchemaActionScope>();
    if (scope == null) {
      return _NullSchemaActionBus();
    }
    return scope.bus;
  }

  @override
  bool updateShouldNotify(SchemaActionScope oldWidget) {
    return bus != oldWidget.bus;
  }
}

/// Implementação nula do bus para evitar erros quando o scope não está presente.
class _NullSchemaActionBus implements SchemaActionBus {
  @override
  void emit(WidgetNode node, String action, Object? data) {
    debugPrint('SchemaActionScope: Bus não encontrado na árvore. Ação "$action" ignorada.');
  }
}
