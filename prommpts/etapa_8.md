# Etapa 8: Refatoração do Ciclo de Vida e Otimização de Updates

## Objetivo
Unificar o ciclo de vida de inicialização e atualização de dados no `SchemaComponentController` e otimizar a performance evitando chamadas redundantes.

## Tarefas

### 1. Refatoração da `ComponentDefinition`
- Remover o método `onInitData`. Toda a lógica de carga inicial deve ser migrada para o `onUpdateData`.
- O `onUpdateData` deve ser o único responsável por buscar ou atualizar os dados do componente.

### 2. Evolução do `SchemaComponentController`
- O controlador deve ser capaz de disparar atualizações baseando-se em mapeamentos de `type` e `id`.
- Implementar a lógica de prioridade nas atualizações:
    1. **ID do Nó**: Se houver uma atualização específica para o ID, ela tem precedência total.
    2. **Tipo do Nó**: Caso não haja por ID, utiliza a atualização genérica pelo tipo do componente.
- **Controle de Redundância**: Implementar um mecanismo para evitar chamadas duplicadas ao `onUpdateData` (ex: comparar o estado anterior, usar um hash das propriedades ou um controle de "dirty" state).

### 3. Mecanismo de Gatilho (Trigger)
- O `SchemaComponentController` deve expor uma forma de ser notificado externamente para re-executar o `onUpdateData` quando dados globais ou específicos mudarem.

### 4. Exemplo Prático e App de Exemplo
- Criar um componente de exemplo (ex: `DynamicProductCard`) que utilize o novo fluxo para atualizar preços ou estoque em tempo real via `onUpdateData`.
- No **projeto de exemplo** (`example/`), implementar telas que demonstrem:
    - Atualização baseada em **ID** (ex: um componente específico que muda de cor ou dado).
    - Atualização baseada em **Type** (ex: todos os botões mudando de estilo simultaneamente).

### 5. Documentação e README
- Atualizar o `README.md` do projeto refletindo a remoção do `onInitData` e explicando o novo fluxo de atualização unificado.
- Criar uma **tabela de referência** no README (ou em um arquivo `ARCHITECTURE.md`) mapeando as principais variáveis, classes e funções do sistema de schema para facilitar o entendimento de novos desenvolvedores.

## Critérios de Aceite
- O código deve estar limpo e seguindo os padrões de Clean Architecture do projeto.
- Nenhuma chamada a `onInitData` deve existir no código.
- As atualizações devem respeitar a hierarquia ID > Type.
- Logs devem demonstrar que updates desnecessários estão sendo evitados.
- O app de exemplo deve ser funcional e demonstrar os dois tipos de atualização.
- O README deve conter a tabela de mapeamento de variáveis e funções solicitada.

---

### Sugestão de Estrutura para a Tabela de Documentação:

| Item | Tipo | Descrição | Escopo/Função |
| :--- | :--- | :--- | :--- |
| `WidgetNode` | Classe | Modelo de dados do nó | Define a estrutura e hierarquia (ID, Type, Children). |
| `ComponentDefinition` | Abstract Class | Definição do componente | Interface para criação de novos componentes SDUI. |
| `onUpdateData` | Função/Hook | Ciclo de vida | Único ponto de entrada para inicialização e atualização de dados. |
| `SchemaComponentController` | Widget | Controlador de Estado | Gerencia o dado interno e resolve overrides por ID/Type. |
| `dataOverrides` | Map | Propriedade | Permite injetar dados externos que sobrescrevem o dado interno do componente. |
| `id` vs `type` | Lógica | Prioridade | Define que configurações por ID específico vencem configurações genéricas por Tipo. |
