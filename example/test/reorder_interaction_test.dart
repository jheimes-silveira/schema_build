import 'package:example/src/editor/canvas/phone_preview.dart';
import 'package:example/src/editor/schema_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schema_build/schema_build.dart';

// Mock components for testing
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
  ComponentBuilder get builder => (context, node, children, {data}) => Container(
        height: 100,
        color: Colors.blue,
        child: Text(node.properties['text'] ?? 'Text Component'),
      );
}

void main() {
  setUpAll(() {
    Schemas.manager.registerComponent(MockTextComponent());
  });

  testWidgets('Should reorder components via long press drag', (WidgetTester tester) async {
    // 1. Initialize state with 3 components
    final state = SchemaEditorState(rootNodes: [
      WidgetNode(id: '1', type: 'text', properties: {'text': 'Component 1'}),
      WidgetNode(id: '2', type: 'text', properties: {'text': 'Component 2'}),
      WidgetNode(id: '3', type: 'text', properties: {'text': 'Component 3'}),
    ]);

    // 2. Build the PhonePreview
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800,
            width: 400,
            child: PhonePreview(state: state),
          ),
        ),
      ),
    );

    // 3. Verify initial order
    expect(find.text('Component 1'), findsOneWidget);
    expect(find.text('Component 2'), findsOneWidget);
    expect(find.text('Component 3'), findsOneWidget);
    
    // Check vertical order (using offsets)
    final firstY = tester.getCenter(find.text('Component 1')).dy;
    final secondY = tester.getCenter(find.text('Component 2')).dy;
    final thirdY = tester.getCenter(find.text('Component 3')).dy;
    
    expect(firstY < secondY, isTrue);
    expect(secondY < thirdY, isTrue);

    // 4. Perform Reorder: Move 'Component 1' to the bottom (below 'Component 3')
    // Long press to start drag (due to ReorderableDelayedDragStartListener)
    final firstComponent = find.text('Component 1');
    final thirdComponent = find.text('Component 3');
    
    final longPressGesture = await tester.startGesture(tester.getCenter(firstComponent));
    await tester.pump(const Duration(seconds: 1)); // Wait for long press timeout
    
    // Drag below the third component
    await longPressGesture.moveTo(tester.getCenter(thirdComponent) + const Offset(0, 50));
    await tester.pump();
    await longPressGesture.up();
    await tester.pumpAndSettle();

    // 5. Verify final state and UI
    expect(state.rootNodes[0].id, '2');
    expect(state.rootNodes[1].id, '3');
    expect(state.rootNodes[2].id, '1');

    final newFirstY = tester.getCenter(find.text('Component 2')).dy;
    final newSecondY = tester.getCenter(find.text('Component 3')).dy;
    final newThirdY = tester.getCenter(find.text('Component 1')).dy;

    expect(newFirstY < newSecondY, isTrue);
    expect(newSecondY < newThirdY, isTrue);
  });

  testWidgets('Should select component on short tap without dragging', (WidgetTester tester) async {
    final state = SchemaEditorState(rootNodes: [
      WidgetNode(id: '1', type: 'text', properties: {'text': 'Component 1'}),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhonePreview(state: state),
        ),
      ),
    );

    // Short tap
    await tester.tap(find.text('Component 1'));
    await tester.pumpAndSettle();

    // Verify selection
    expect(state.selectedWidgetId, '1');
  });
}
