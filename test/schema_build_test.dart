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
  ComponentBuilder get builder => (context, children, {data}) => Text(data?.toString() ?? '');
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

  group('SchemaEditorState', () {
    test('should add widget to canvas', () {
      final state = SchemaEditorState();
      state.addWidgetToCanvas('text');
      expect(state.rootNodes, isNotEmpty);
      expect(state.rootNodes.last.type, 'text');
    });

    test('should add widget to parent', () {
      final state = SchemaEditorState();
      state.addWidgetToCanvas('column');
      final parentId = state.rootNodes.first.id;

      state.addWidgetToParent(parentId, 'text');
      expect(state.rootNodes.first.children, isNotEmpty);
      expect(state.rootNodes.first.children.first.type, 'text');
    });

    test('should select and clear widget', () {
      final state = SchemaEditorState();
      state.addWidgetToCanvas('text');
      final id = state.rootNodes.first.id;

      state.selectWidget(id);
      expect(state.selectedWidgetId, id);

      state.clearSelection();
      expect(state.selectedWidgetId, isNull);
    });

    test('should remove widget', () {
      final state = SchemaEditorState();
      state.addWidgetToCanvas('text');
      final id = state.rootNodes.first.id;

      state.removeWidget(id);
      expect(state.rootNodes, isEmpty);
    });
  });

  group('SchemaSerializer', () {
    test('should generate valid schema JSON with widget tree', () {
      final state = SchemaEditorState();
      state.addWidgetToCanvas('column');
      final parentId = state.rootNodes.first.id;
      state.addWidgetToParent(parentId, 'text');

      final schema = SchemaSerializer.toJson(state);

      expect(schema['rootNodes'], isNotNull);
      expect(schema['rootNodes'][0]['type'], 'column');
      expect(schema['rootNodes'][0]['children'], isList);
      expect(schema['rootNodes'][0]['children'][0]['type'], 'text');
    });
  });
}
