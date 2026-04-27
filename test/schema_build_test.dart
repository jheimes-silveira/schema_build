import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_build/schema_build.dart';

// Mock components for testing since CoreSchema was removed
class MockTextComponent extends ComponentDefinition {
  @override
  String get type => 'text';
  @override
  String get name => 'Text';
  @override
  String get description => '';
  @override
  bool get acceptsChildren => false;
  @override
  ComponentBuilder get builder => (context, node, children, {data}) => Text(data?.toString() ?? '');
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
  ComponentBuilder get builder => (context, node, children, {data}) => Column(children: children);
}

void main() {
  setUpAll(() {
    Schemas.manager.registerComponent(MockTextComponent());
    Schemas.manager.registerComponent(MockColumnComponent());
  });

  group('WidgetNode', () {
    test('should create with default properties', () {
      final node = WidgetNode(id: '1', type: 'text');
      expect(node.id, '1');
      expect(node.type, 'text');
      expect(node.children, isEmpty);
    });

    test('should serialize to JSON and back', () {
      final node = WidgetNode(
        id: 'root',
        type: 'column',
        children: [
          WidgetNode(id: 'child1', type: 'text'),
        ],
      );

      final json = node.toJson();
      final fromJson = WidgetNode.fromJson(json);

      expect(fromJson.id, 'root');
      expect(fromJson.type, 'column');
      expect(fromJson.children.length, 1);
      expect(fromJson.children.first.id, 'child1');
    });
  });

}
