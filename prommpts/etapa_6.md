# Etapa 6: Refatoração para Componentes de Dados Autogerenciados

## Objetivo
Evoluir a arquitetura do `schema_build` para suportar **Componentes de Dados Autogerenciados**. O objetivo é remover a dependência de propriedades estáticas (`properties`) e permitir que cada componente gerencie seu próprio estado de dados através de ganchos de ciclo de vida.

## 1. Limpeza e Simplificação (Breaking Changes)
- **Remover `PropertyType` e `ComponentProperty`**:
  - Eliminar o arquivo `lib/src/schema/component_property.dart`.
  - Remover todas as referências a estes tipos no projeto.
- **Refatorar `ComponentDefinition`**:
  - Remover os campos: `icon`, `maxChildren` e `properties`.
  - Ajustar o `builder` para não receber mais o mapa de `properties`.
- **Refatorar `WidgetNode`**:
  - Remover o campo `properties`.
  - Atualizar construtores, `copyWith`, `toJson` e `fromJson`.

## 2. Ciclo de Vida e Gerenciamento de Dados
- **Hooks em `ComponentDefinition`**:
  - Padronizar `onInitData` e `onUpdateData` para buscar dados externos:
    ```dart
    void onInitData(BuildContext context, WidgetNode node, void Function(Object? data) onDataReturned);
    void onUpdateData(BuildContext context, WidgetNode node, void Function(Object? data) onDataReturned);
    ```
- **Novo `SchemaComponentController`**:
  - Implementar um controlador/widget que gerencie o estado do componente.
  - Ele deve ser responsável por disparar `onInitData` e `onUpdateData`.
  - Deve armazenar o `Object? data` e notificar a reconstrução do widget quando os dados chegarem.

## 3. Renderização e Builder
- **Nova Assinatura do `ComponentBuilder`**:
  ```dart
  typedef ComponentBuilder = Widget Function(
    BuildContext context,
    List<Widget> children, {
    Object? data,
  });
  ```
- **Fluxo de Montagem**:
  - O `builder` utiliza o `data` retornado pelos hooks para sua lógica interna.
  - O `builder` recebe a lista de `children` (widgets já processados) para compor o layout final.

## 4. Critérios de Aceite
- [ ] O projeto compila sem erros após a remoção de `properties`.
- [ ] Cada componente é capaz de buscar seus próprios dados de forma assíncrona.
- [ ] A estrutura do `WidgetNode` no JSON torna-se puramente estrutural (`id`, `type`, `children`).
- [ ] Os componentes existentes (ActionCard, etc) foram migrados para o novo padrão.