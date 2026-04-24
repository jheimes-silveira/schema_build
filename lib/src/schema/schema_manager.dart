import 'component_definition.dart';
import 'schema_base.dart';

/// Manages the registration and retrieval of component definitions.
class SchemaManager {
  final Map<String, ComponentDefinition> _components = {};

  /// Registers a new component definition.
  void registerComponent(ComponentDefinition component) {
    _components[component.type] = component;
  }

  /// Retrieves a component definition by its unique type.
  ComponentDefinition? getDefinition(String type) => _components[type];

  /// Returns all registered component definitions.
  List<ComponentDefinition> getAllDefinitions() =>
      _components.values.toList();
}

/// Global registry for all schemas and components.
class Schemas {
  const Schemas._();

  static final SchemaManager _instance = SchemaManager();

  /// Accesses the global instance of [SchemaManager].
  static SchemaManager get manager => _instance;

  /// Loads a component package (a [Schema]) into the registry.
  static void load(Schema schema) {
    schema.components(_instance);
  }
}
