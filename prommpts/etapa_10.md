# Etapa 10: Evolução para Arquitetura de Estado Reativo e Push-Based

O objetivo desta etapa é inverter o controle de dados, permitindo que o `SchemaComponentController` injete estados diretamente nos componentes via eventos, e formalizar um ciclo de vida assíncrono para as definições.

## 1. Refatoração da Base (`ComponentDefinition`)

- **Remover** `onUpdateData`: Este hook de "pull" será substituído pelo modelo de injeção reativa.
- **Adicionar** `Future<void> onInit(BuildContext context, WidgetNode node)`:
    - Chamado **uma única vez** no `initState` do controlador.
    - **Uso**: Realizar o setup inicial, como chamadas HTTP internas para buscar dados ou configuração de listeners específicos.
    - **Facilidade**: Para atualizar seu próprio estado (UI), o componente pode chamar `SchemaComponentController.dispatchDataById(node.id, data)`.
- **Mecanismo de Estado**:
    - **Injeção Automática (Zero-Config)**: O `SchemaComponentController` deve assinar automaticamente o Stream de dados para o `ID` e `Type` do nó. Qualquer dado enviado via `dispatch` deve atualizar o `builder` automaticamente.
    - **updateExternalState(Object? data)**: Método (estático ou via contexto) que o componente chama para notificar ouvintes lógicos (Observers). **Importante**: Chamar este método NÃO dispara rebuild no `builder`, servindo apenas para comunicação de eventos.
    - **Regra de Prioridade**: Dados vindos de `dispatchData` (Push) sempre têm precedência. Se um dado for injetado via push enquanto o `onInit` ainda está processando, o resultado final do `onInit` não deve sobrescrever o dado do push.

## 2. Upgrade do `SchemaComponentController` (Push-Based)

- **Gerenciamento de Cache**: O Controller deve implementar um mecanismo de persistência de estado (cache) para que, se um componente for removido e reinserido na árvore (ex: scroll de lista), ele recupere o último dado recebido (seja via `onInit` ou Push) sem precisar de um novo fetch.
- **Mecanismo de Escuta (UI)**: O controlador gerencia a assinatura do stream global para atualizações de UI (`dispatchData`).
- **Mecanismo de Observação (Lógica)**: 
    - `static void onObserveDataById(String id, Function(Object?) onDataReturned)`: Registra um ouvinte que será disparado **apenas** quando o componente com o ID específico chamar `updateExternalState`.
    - `static void onObserveDataByType(String type, Function(Object?) onDataReturned)`: Registra um ouvinte para todos os componentes de um tipo que chamarem `updateExternalState`.
    - **Ciclo de Vida**: O controlador deve garantir o descarte (cancel/dispose) desses ouvintes quando não forem mais necessários para evitar memory leaks.
- **Novos Métodos Estáticos**:
    - `static void dispatchDataById(String id, Object? data)`: Envia dados para a UI de um componente específico.
    - `static void dispatchDataByType(String type, Object? data)`: Envia dados para a UI de todos os componentes de um tipo.

## 3. Documentação, Migração e Testes

- **Migração de Exemplos**: Adaptar os componentes do diretório `example/` para o novo padrão `onInit`. Cada componente deve ter testes completos de suas funcionalidades com comentários claros.
- **Documentação**: 
    - Atualizar o `README.md` detalhando a separação entre `dispatchData` (UI) e `updateExternalState` (Eventos/Observadores).
- **Testes Unitários e de Integração**:
    - Validar a persistência de cache ao reconstruir widgets.
    - Validar que `updateExternalState` dispara os Observers mas NÃO dispara o builder.

## 4. Exemplos de Implementação e Uso

### Exemplo 1: Componente de Busca com Estado Inicial e Push
```dart
class SearchComponent extends ComponentDefinition {
  @override
  String get type => 'search';

  @override
  Future<void> onInit(context, node) async {
    // Carrega sugestões iniciais
    final suggestions = await api.getSuggestions();
    SchemaComponentController.dispatchDataById(node.id, suggestions);
  }

  @override
  ComponentBuilder get builder => (context, children, {data}) {
    return Column(
      children: [
        TextField(
          onChanged: (val) {
            // Notifica o mundo externo sem rebuild local
            SchemaComponentController.updateExternalState(node.id, val);
          },
        ),
        if (data != null) Text('Sugestões: $data'),
      ],
    );
  };
}
```

### Exemplo 2: App Host injetando dados (Push-Based)
```dart
// No código do aplicativo real, injetando dados no schema dinamicamente
void onPriceUpdated(double newPrice) {
  // Atualiza todos os componentes de preço de uma vez
  SchemaComponentController.dispatchDataByType('price_tag', {'price': newPrice});
  
  // Ou atualiza um produto específico pelo ID
  SchemaComponentController.dispatchDataById('product_123', {'price': newPrice, 'promo': true});
}
```

### Exemplo 3: Escutando Eventos Lógicos (Observers)
```dart
// Registrando um observador para logs ou analytics
void setupAnalytics() {
  SchemaComponentController.onObserveDataByType('button', (data) {
    print('Botão clicado com os dados: $data');
    // Enviar para Firebase, Mixpanel, etc.
  });
}
```

### Exemplo 4: Registro de Listener no `onInit`
```dart
class ChatComponent extends ComponentDefinition {
  @override
  Future<void> onInit(context, node) async {
    // Escuta um socket ou stream externo e faz o dispatch
    myWebSocket.listen((message) {
      SchemaComponentController.dispatchDataById(node.id, message);
    });
  }

  @override
  ComponentBuilder get builder => (context, children, {data}) {
    return ListView(children: [Text(data ?? 'Sem mensagens')]);
  };
}
```