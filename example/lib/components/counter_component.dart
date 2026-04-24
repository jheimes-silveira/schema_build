import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';

class CounterComponent extends ComponentDefinition {
  @override
  String get type => 'counter';

  @override
  String get name => 'Counter';

  @override
  String get description => 'A simple counter that emits events';

  @override
  bool get acceptsChildren => false;

  @override
  Object? onReceiveAction(BuildContext context, WidgetNode node, String action, Object? data) {
    if (action == 'reset') {
      final bus = SchemaActionScope.of(context);
      bus.emit(node, 'increment', {'current': -1}); // Hack to force 0 if increment does current+1
      // Actually, better emit a proper reset event
      bus.emit(node, 'reset_to_zero', {});
      return 'ok';
    }
    return null;
  }

  @override
  ComponentBuilder get builder => (context, children, {data}) {
    final params = data as Map<String, dynamic>? ?? {};
    final currentCount = params['count'] as int? ?? 0;
    
    // ignore: avoid_dynamic_calls
    final node = (context.widget as dynamic).node as WidgetNode;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Count: $currentCount', style: Theme.of(context).textTheme.headlineMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final bus = SchemaActionScope.of(context);
                  bus.emit(node, 'increment', {'current': currentCount});
                },
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final bus = SchemaActionScope.of(context);
                  bus.emit(node, 'decrement', {'current': currentCount});
                },
              ),
            ],
          ),
        ],
      ),
    );
  };
}
