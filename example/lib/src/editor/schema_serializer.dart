import 'package:schema_build/schema_build.dart';
import 'schema_editor_state.dart';

/// Utility class for serializing/deserializing the editor schema.
class SchemaSerializer {
  const SchemaSerializer._();

  /// Converts the current editor state into a JSON-compatible map.
  static Map<String, dynamic> toJson(SchemaEditorState state) {
    return state.toSchema();
  }

  /// Creates a new [SchemaEditorState] from a JSON map.
  static SchemaEditorState fromJson(Map<String, dynamic> json) {
    final config = json['config'] != null
        ? SchemaConfig.fromJson(json['config'] as Map<String, dynamic>)
        : const SchemaConfig();

    final rootNodes = (json['rootNodes'] as List<dynamic>?)
            ?.map((e) => WidgetNode.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SchemaEditorState(
      config: config,
      rootNodes: rootNodes,
    );
  }
}
