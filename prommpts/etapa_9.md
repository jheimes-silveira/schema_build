# Etapa 9: Comunicação Bidirecional e Ações Dinâmicas

## Objetivo
Implementar uma camada de comunicação robusta que permita ao App Host interagir com componentes específicos (solicitando dados ou disparando comportamentos internos) e aos componentes notificarem o App Host sobre eventos e interações do usuário.

## Tarefas

### 1. Sistema de Requisição e Resposta (Inbound)
- Evoluir o `SchemaComponentController.dispatchUpdate` para um modelo de **Ações/Requisições**.
- Implementar o método `static Future<T?> dispatchAction<T>(String targetId, String action, {Object? data})`.
- Este método deve permitir que o App Host envie um comando para um componente específico (via ID) e aguarde um retorno assíncrono (ex: solicitar o valor atual de um campo de texto).

### 2. Hook de Recebimento no `ComponentDefinition`
- Adicionar o método `onAction` na classe base `ComponentDefinition`:
  ```dart
  FutureOr<Object?> onReceiveAction(
    BuildContext context, 
    WidgetNode node, 
    String action, 
    Object? data
  ) => null;
  ```
- O `SchemaComponentController` deve escutar as ações globais e, se o `targetId` coincidir, repassar para este hook do componente.

### 3. Comunicação Outbound (Componente -> App Host)
- Adicionar ao `SchemaWidget` um parâmetro `onAction`:
  ```dart
  final void Function(WidgetNode node, String action, Object? data)? onAction;
  ```
- Implementar um `InheritedWidget` chamado `SchemaActionScope` para prover aos componentes uma forma simples de disparar eventos para cima:
  ```dart
  // Exemplo de uso dentro de um componente:
  SchemaActionScope.of(context).emit(node, 'button_clicked', {'id': 'submit_btn'});
  ```

### 4. Gestão de Estado Global (Opcional, mas recomendado)
- Criar um mecanismo para que componentes possam registrar "provedores de dados" ou "serviços" dinâmicos que outros componentes (ou o Host) possam consultar.

### 5. Exemplo Prático e Validação
No app de exemplo, implementar os seguintes cenários:
1. **Solicitação de Dados:** Um botão fora do `SchemaWidget` que, ao ser clicado, chama `dispatchAction` para um componente de "Input" dentro do schema e exibe o valor retornado em um Snackbar.
2. **Notificação de Evento:** Um componente de "Counter" dentro do schema que notifica o App Host toda vez que o valor muda, e o Host atualiza um log na tela principal.
3. **Ações em Lote:** Disparar uma ação para todos os componentes de um determinado `type` (ex: "reset_fields").

## Critérios de Aceite
- O método `dispatchAction` deve ser tipado e suportar `Future`.
- Componentes devem conseguir emitir eventos sem precisar de referências diretas a callbacks complexos (usando o `Scope`).
- O `SchemaWidget` deve repassar corretamente as ações para o desenvolvedor que está utilizando a biblioteca.
- Documentar no README como realizar a comunicação bidirecional.

---

### Sugestão de Assinatura para o Scope:
```dart
abstract class SchemaActionBus {
  void emit(WidgetNode node, String action, Object? data);
}
```