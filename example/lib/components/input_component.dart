import 'dart:async';
import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';

class InputComponent extends ComponentDefinition {
  @override
  String get type => 'input';

  @override
  String get name => 'Input Field';

  @override
  String get description => 'A simple text input field';

  @override
  bool get acceptsChildren => false;

  @override
  Map<String, dynamic> get properties => {'label': 'Type something...'};

  // Em um cenário real, usaríamos um gerenciador de estado para persistir isso
  static final Map<String, TextEditingController> _controllers = {};

  @override
  ComponentBuilder get builder => (context, node, children, {data}) {
    final params = data as Map<String, dynamic>? ?? {};
    final label = params['label'] as String? ?? 'Label';
    
    // Obtém ou cria o controller para este nó específico
    final nodeId = node.id;
    final controller = _controllers.putIfAbsent(nodeId, () => TextEditingController());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  };

  @override
  FutureOr<Object?> onReceiveAction(
    BuildContext context, 
    WidgetNode node, 
    String action, 
    Object? data
  ) {
    final controller = _controllers[node.id];
    if (action == 'get_value') {
      return controller?.text ?? '';
    }
    if (action == 'clear') {
      controller?.clear();
      return true;
    }
    return super.onReceiveAction(context, node, action, data);
  }
}
