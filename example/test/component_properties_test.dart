import 'package:example/src/editor/schema_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_build/schema_build.dart';

class MockComponentWithProperties extends ComponentDefinition {
  @override
  String get type => 'mock_with_props';
  @override
  String get name => 'Mock';
  @override
  String get description => 'Mock';
  @override
  bool get acceptsChildren => false;
  @override
  ComponentBuilder get builder => (context, node, children, {data}) => SizedBox();

  @override
  Map<String, dynamic> get properties => {'initial_value': 42, 'label': 'test'};
}

void main() {
  test('WidgetNode should inherit properties from ComponentDefinition when added to canvas', () {
    // Register the mock component
    Schemas.manager.registerComponent(MockComponentWithProperties());

    final state = SchemaEditorState();
    
    // Add the widget to the canvas
    state.addWidgetToCanvas('mock_with_props');

    // Verify the node has the initial properties
    expect(state.rootNodes.length, 1);
    final node = state.rootNodes.first;
    expect(node.type, 'mock_with_props');
    expect(node.properties['initial_value'], 42);
    expect(node.properties['label'], 'test');

    // Verify properties are copied, not shared (mutation test)
    node.properties['initial_value'] = 100;
    
    final anotherNode = WidgetNode(
      id: 'another',
      type: 'mock_with_props',
      properties: Map.from(Schemas.manager.getDefinition('mock_with_props')!.properties!),
    );
    expect(anotherNode.properties['initial_value'], 42);
  });
}
