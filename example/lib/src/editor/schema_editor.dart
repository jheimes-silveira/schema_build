import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'schema_editor_state.dart';
import 'sidebar/properties_panel.dart';
import 'sidebar/widget_palette.dart';
import 'canvas/canvas_drop_zone.dart';
import 'canvas/phone_preview.dart';

/// Root widget for the Schema Builder Editor.
///
/// Renders a three-panel layout:
/// - **Left Sidebar** (240px): Widget palette.
/// - **Central Canvas** (flex): Phone preview with drop zone.
/// - **Right Sidebar** (280px, conditional): Property editor for the selected widget.
///
/// Usage:
/// ```dart
/// SchemaEditor(
///   onSchemaChanged: (schema) => print(schema),
/// )
/// ```
class SchemaEditor extends StatefulWidget {
  const SchemaEditor({
    super.key,
    this.initialState,
    this.onSchemaChanged,
  });

  /// Optional initial state. If null, creates a new state.
  final SchemaEditorState? initialState;

  /// Called whenever the schema changes.
  final ValueChanged<Map<String, dynamic>>? onSchemaChanged;

  @override
  State<SchemaEditor> createState() => _SchemaEditorState();
}

class _SchemaEditorState extends State<SchemaEditor> {
  late final SchemaEditorState _editorState;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editorState = widget.initialState ?? SchemaEditorState();
    _editorState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _editorState.removeListener(_onStateChanged);
    if (widget.initialState == null) {
      _editorState.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    widget.onSchemaChanged?.call(_editorState.toSchema());
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _editorState.clearSelection();
        }
      },
      child: Row(
        children: [
          // ---- Left Sidebar (Widgets) ----
          _Sidebar(state: _editorState),

          // ---- Central Canvas ----
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: CanvasDropZone(
                  state: _editorState,
                  child: PhonePreview(state: _editorState),
                ),
              ),
            ),
          ),

          // ---- Right Sidebar (Properties) ----
          PropertiesPanel(state: _editorState),
        ],
      ),
    );
  }
}

/// Sidebar showing the Widget Palette.
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.state});
  final SchemaEditorState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: const Text(
              'Widgets Palette',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),

          // Widget Palette
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: WidgetPalette(state: state),
            ),
          ),
        ],
      ),
    );
  }
}
