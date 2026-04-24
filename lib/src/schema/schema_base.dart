import 'schema_manager.dart';

/// Interface para definir uma coleção de componentes relacionados.
abstract class Schema {
  /// Registra todos os componentes deste schema no gerenciador.
  void components(SchemaManager schemaManager);
}
