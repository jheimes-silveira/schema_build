import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_build/schema_build.dart';

// Mock components for testing since CoreSchema was removed
class MockActionComponent extends ComponentDefinition {
  @override
  String get type => 'mock_action';
  @override
  String get name => 'Mock Action';
  @override
  String get description => '';
  @override
  bool get acceptsChildren => false;
  @override
  ComponentBuilder get builder => (context, children, {data}) => const SizedBox();
  @override
  FutureOr<Object?> onReceiveAction(context, node, action, data) {
    if (action == 'test_echo') return data;
    if (action == 'test_async') return Future.value('async_response');
    if (action == 'test_error') throw Exception('test_error_message');
    return null;
  }
}

class MockEventComponent extends ComponentDefinition {
  @override
  String get type => 'mock_event';
  @override
  String get name => 'Mock Event';
  @override
  String get description => '';
  @override
  bool get acceptsChildren => false;
  @override
  ComponentBuilder get builder => (context, children, {data}) {
    // ignore: avoid_dynamic_calls
    final node = (context.widget as dynamic).node as WidgetNode;
    return ElevatedButton(
      onPressed: () {
        SchemaActionScope.of(context).emit(node, 'event_triggered', {'value': 42});
      },
      child: const Text('Trigger Event'),
    );
  };
}

class MockColumnComponent extends ComponentDefinition {
  @override
  String get type => 'column';
  @override
  String get name => 'Column';
  @override
  String get description => '';
  @override
  bool get acceptsChildren => true;
  @override
  ComponentBuilder get builder => (context, children, {data}) => Column(children: children);
}

class BatchTestComponent extends ComponentDefinition {
  BatchTestComponent(this.type, this.onAction);
  @override
  final String type;
  final Function(String action) onAction;
  @override
  String get name => 'Batch Test';
  @override
  String get description => '';
  @override
  bool get acceptsChildren => false;
  @override
  ComponentBuilder get builder => (context, children, {data}) => const SizedBox();
  @override
  FutureOr<Object?> onReceiveAction(context, node, action, data) {
    onAction(action);
    return 'ok';
  }
}

void main() {
  setUpAll(() {
    Schemas.manager.registerComponent(MockActionComponent());
    Schemas.manager.registerComponent(MockEventComponent());
    Schemas.manager.registerComponent(MockColumnComponent());
  });

  group('Stage 9: Bidirectional Communication (Unit Logic)', () {
    testWidgets('should handle dispatchAction correctly', (tester) async {
      await tester.runAsync(() async {
        final node = WidgetNode(id: 'target_1', type: 'mock_action');
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SchemaWidget(node: node))));
        
        final response = await SchemaComponentController.dispatchAction<String>(
          'target_1', 
          'test_echo', 
          data: 'hello'
        );
        expect(response, 'hello');
      });
    });

    testWidgets('should handle batch actions correctly', (tester) async {
      await tester.runAsync(() async {
        final node1 = WidgetNode(id: 'node_1', type: 'mock_action');
        final node2 = WidgetNode(id: 'node_2', type: 'mock_action');
        final root = WidgetNode(id: 'root', type: 'column', children: [node1, node2]);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SchemaWidget(node: root))));

        final response = await SchemaComponentController.dispatchAction<String>(
          '', 
          'test_echo', 
          data: 'batch',
          targetComponentType: 'mock_action'
        );
        expect(response, 'batch');
      });
    });

    testWidgets('should emit events correctly', (tester) async {
      final node = WidgetNode(id: 'event_node', type: 'mock_event');
      WidgetNode? receivedNode;
      String? receivedAction;
      Object? receivedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SchemaWidget(
              node: node,
              onAction: (n, a, d) {
                receivedNode = n;
                receivedAction = a;
                receivedData = d;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(receivedNode?.id, 'event_node');
      expect(receivedAction, 'event_triggered');
      expect((receivedData as Map)['value'], 42);
    });

    testWidgets('should reach all matching components in batch', (tester) async {
      await tester.runAsync(() async {
        int receivedCount = 0;
        const testType = 'batch_test_final';
        
        Schemas.manager.registerComponent(BatchTestComponent(testType, (a) {
          receivedCount++;
        }));

        final node1 = WidgetNode(id: 'b1', type: testType);
        final node2 = WidgetNode(id: 'b2', type: testType);
        final root = WidgetNode(id: 'root', type: 'column', children: [node1, node2]);

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: SchemaWidget(node: root))));

        await SchemaComponentController.dispatchAction('', 'ping', targetComponentType: testType);
        expect(receivedCount, 2);
      });
    });
  });
}
