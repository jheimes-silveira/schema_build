# Etapa 5: Componentes Inteligentes e Ciclo de Vida de Dados

O objetivo desta etapa é evoluir o `SchemaWidget` e o `ComponentDefinition` para suportar o carregamento de dados reativo e descentralizado. Cada componente deve ser capaz de gerenciar sua própria lógica de busca de dados (ex: APIs, DB local) sem sobrecarregar a árvore de renderização global.

## 1. Evolução do ComponentDefinition (Lifecycle Hooks)

Adicionar hooks de ciclo de vida para que o componente possa sinalizar ao renderizador que precisa de dados externos.

```dart
typedef ComponentBuilder = Widget Function(
  BuildContext context,
  Map<String, dynamic> properties,
  List<Widget> children, {
  Object? data,
});

abstract class ComponentDefinition {
  // ... (propriedades atuais)

  /// Chamado uma única vez na inicialização do widget.
  void onInitData(BuildContext context, WidgetNode node, void Function(Object? data) onDataReturned) {}

  /// Chamado quando propriedades externas ou contexto mudam.
  void onUpdateData(BuildContext context, WidgetNode node, void Function(Object? data) onDataReturned) {}
}
```

## 2. Refatoração do SchemaWidget para StatefulWidget

O `SchemaWidget` deixará de ser um StatelessWidget puro. Ele passará a ser um **StatefulWidget** que gerencia o estado interno do dado retornado pelo componente.

### Fluxo de Funcionamento:
1. `SchemaWidget.initState()` chama `definition.onInitData`.
2. O componente executa sua lógica (ex: `http.get`).
3. Ao retornar o dado via `onDataReturned`, o `SchemaWidget` executa um `setState` interno.
4. O `builder` é chamado passando o objeto carregado (`data`), economizando processamento ao evitar rebuilds desnecessários.

---

## 3. Exemplo Prático: Componente de Estoque em Tempo Real

```dart
class StockStatusComponent extends ComponentDefinition {
  @override
  String get type => 'stock_status';

  @override
  void onInitData(BuildContext context, WidgetNode node, onData) {
    // Exemplo: Filtro por ID ou Type específico
    if (node.id == 'main_inventory_display') {
      ApiService.fetchStock(node.properties['sku']).then(onData);
    }
  }

  @override
  ComponentBuilder get builder => (context, p, children, {Object? data}) {
    // O dado chega aqui após o carregamento interno
    final stockCount = data as int? ?? 0;
    return Text('Estoque: $stockCount unidades');
  };
}
```

---

## 4. Checklist de Implementação

- [ ] **Hooks de Dados**: Incluir `onInitData` e `onUpdateData` no `ComponentDefinition`.
- [ ] **Renderizador Inteligente**: Converter `SchemaWidget` para `StatefulWidget`.
- [ ] **Gerenciamento de Estado**: Implementar a lógica de `onDataReturned` para atualizar apenas o widget local.
- [ ] **Targeted Fetching**: Implementar no exemplo a lógica de verificação de `type` e `id` dentro do componente para disparar ações específicas.
- [ ] **Memoização**: Garantir que o `builder` só seja processado novamente se as propriedades do nó ou os dados retornados mudarem de fato.