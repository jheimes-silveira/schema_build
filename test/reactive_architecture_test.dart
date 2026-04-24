import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_build/schema_build.dart';

class MockComponent extends ComponentDefinition {
  int initCount = 0;

  @override
  String get type => 'mock';
  @override
  String get name => 'Mock';
  @override
  String get description => 'Mock';
  @override
  bool get acceptsChildren => false;

  @override
  Future<void> onInit(BuildContext context, WidgetNode node) async {
    initCount++;
  }

  @override
  ComponentBuilder get builder => (context, children, {data}) {
    return Text(data?.toString() ?? 'no data');
  };
}

void main() {
  testWidgets('Reactive Architecture: dispatchData updates UI and cache', (tester) async {
    final node = WidgetNode(id: 'test_node', type: 'mock');
    final definition = MockComponent();
    
    Schemas.manager.registerComponent(definition);

    await tester.pumpWidget(
      MaterialApp(
        home: SchemaWidget(node: node),
      ),
    );

    expect(find.text('no data'), findsOneWidget);
    expect(definition.initCount, 1);

    // Test dispatchDataById
    SchemaComponentController.dispatchDataById('test_node', 'new data');
    await tester.pump();
    expect(find.text('new data'), findsOneWidget);

    // Test Cache: Rebuild the widget and see if it recovers data
    await tester.pumpWidget(
      MaterialApp(
        home: Container(), // Remove widget
      ),
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: SchemaWidget(node: node),
      ),
    );

    // Should have recovered from cache and NOT called onInit again (since it's a new State but same ID)
    // Wait, onInit is called in initState. If it's a new State, it will call onInit.
    // But it should recover data from cache IMMEDIATELY.
    expect(find.text('new data'), findsOneWidget);
  });

  test('Reactive Architecture: updateExternalState notifies observers', () async {
    final completer = Completer<Object?>();
    final subscription = SchemaComponentController.onObserveDataById('obs_node', (data) {
      if (!completer.isCompleted) completer.complete(data);
    });

    SchemaComponentController.updateExternalState('obs_node', 'mock', 'hello observer');
    
    final observedData = await completer.future.timeout(const Duration(seconds: 2));
    expect(observedData, 'hello observer');
    
    await subscription.cancel();
  });
}
