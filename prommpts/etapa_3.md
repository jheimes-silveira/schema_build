# Etapa 3: Sistema de Extensibilidade e Registro de Componentes (Schema Registry)

O objetivo desta etapa é refatorar o `schema_build` para deixar de usar o enum `WidgetNodeType` como fonte única de verdade e passar a usar um sistema de registro dinâmico. Isso permitirá que novos componentes sejam adicionados sem modificar o core da biblioteca.

## 1. Estrutura de Pastas e Arquivos
Crie os seguintes arquivos em `lib/src/schema/`:
- `component_property.dart`: Definições de propriedades.
- `component_definition.dart`: Metadados e builder do componente.
- `schema_manager.dart`: Gerenciador de registro.
- `schema_base.dart`: Interface para agrupamento de componentes.

## 2. Definições Técnicas

### ComponentProperty
Refine a classe para incluir tipos de propriedades, o que facilitará a criação automática de editores na UI:
```dart
enum PropertyType { string, number, color, boolean, alignment, icon }

abstract class ComponentProperty {
  String get id;
  String get name;
  PropertyType get type;
  dynamic get defaultValue;
  String? get description;
}
```

### ComponentDefinition
O `builder` deve ser compatível com a árvore do `WidgetNode` e receber o contexto, as propriedades processadas e os filhos já renderizados:
```dart
typedef ComponentBuilder = Widget Function(
  BuildContext context, 
  Map<String, dynamic> properties, 
  List<Widget> children
);

abstract class ComponentDefinition {
  String get type; // Identificador único (ex: 'container', 'custom_card')
  String get name;
  String get description;
  IconData get icon;
  bool get acceptsChildren;
  int get maxChildren; // -1 para ilimitado
  List<ComponentProperty> get properties;
  ComponentBuilder get builder;
}
```

### SchemaManager & Schemas (Global Registry)
Crie um `SchemaManager` que gerencie o registro e uma classe estática `Schemas` para acesso fácil:
```dart
class SchemaManager {
  final Map<String, ComponentDefinition> _components = {};

  void registerComponent(ComponentDefinition component) {
    _components[component.type] = component;
  }

  ComponentDefinition? getDefinition(String type) => _components[type];
  List<ComponentDefinition> getAllDefinitions() => _components.values.toList();
}

class Schemas {
  static final SchemaManager _instance = SchemaManager();
  static SchemaManager get manager => _instance;
  
  // Atalho para registro de pacotes de componentes
  static void load(Schema schema) => schema.components(_instance);
}
```

## 3. Integração com o Código Existente

### Modificações no `WidgetNode`:
- Altere `WidgetNode.type` de `WidgetNodeType` (enum) para `String`.
- Atualize os métodos `toJson` e `fromJson` para lidar com a string.
- O método `canAcceptChildren` agora deve consultar o `Schemas.manager.getDefinition(type)`.

### Modificações no `SchemaEditorState`:
- Em vez de usar `WidgetDefaults.forType(type)`, use `Schemas.manager.getDefinition(type).properties` para inicializar os valores padrão de um novo nó.
- A paleta de componentes (`sidebar/widget_palette.dart`) deve agora iterar sobre `Schemas.manager.getAllDefinitions()`.

## 4. Implementação do "CoreSchema"
Crie uma implementação de `Schema` chamada `CoreSchema` que registre os componentes atuais (Container, Text, Image, Button, Column, Row, ListView, GridView) usando a nova estrutura, garantindo retrocompatibilidade com as propriedades já definidas em `WidgetDefaults`.

## 5. Renderização e Injeção de Dados Dinâmicos (Runtime)

A lib deve fornecer uma forma de renderizar o schema em produção, permitindo que dados externos (ex: chamadas API) sejam injetados nas propriedades dos componentes.

### SchemaWidget (O Renderizador)
Crie um widget chamado `SchemaWidget` que recebe um `WidgetNode` e resolve a renderização recursivamente. Ele deve permitir sobrepor propriedades em tempo de execução.

```dart
class SchemaWidget extends StatelessWidget {
  final WidgetNode node;
  final Map<String, dynamic>? dataOverrides;

  const SchemaWidget({required this.node, this.dataOverrides});

  @override
  Widget build(BuildContext context) {
    final definition = Schemas.manager.getDefinition(node.type);
    if (definition == null) return const SizedBox.shrink();

    // Mescla propriedades salvas no JSON com dados dinâmicos da tela (ex: API)
    final effectiveProperties = {
      ...node.properties,
      if (dataOverrides != null) ...dataOverrides!,
    };

    return definition.builder(
      context,
      effectiveProperties,
      node.children.map((child) => SchemaWidget(
        node: child, 
        dataOverrides: dataOverrides
      )).toList(),
    );
  }
}
```

### Objetivo de Uso
O desenvolvedor deve conseguir recuperar o builder de um componente via `Schemas.manager` ou usar o `SchemaWidget` passando um `dataOverrides`. Isso permite que dados de uma chamada HTTPS, por exemplo, preencham as propriedades de um componente customizado na Home do app.