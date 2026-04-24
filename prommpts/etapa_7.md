# Etapa 7: Desacoplamento da Interface do Editor e Refatoração do Core

## Objetivo
Refatorar a estrutura do projeto para separar completamente o **Core de Renderização e Lógica** (na biblioteca `schema_build`) da **Interface Visual do Editor** (no projeto `example`). A biblioteca deve se tornar um motor (engine) de schema, enquanto a interface de arrastar e soltar e as ferramentas de edição ficam no projeto de exemplo.

## Infraestrutura e Dependências
1. **Limpeza do Pubspec da Lib**:
   - [ ] Remover a dependência `super_drag_and_drop` do arquivo `pubspec.yaml` da biblioteca `schema_build`.
2. **Atualização do Pubspec do Exemplo**:
   - [ ] Adicionar `super_drag_and_drop: ^0.8.23` ao `pubspec.yaml` do projeto `example`.

## Migração de Código (Lib -> Example)
Mover os seguintes componentes de UI da pasta `lib/src/widgets/` para o projeto `example/lib/editor/`:

1. **Estrutura do Editor**: `schema_editor.dart` (será o novo entry point do editor no exemplo).
2. **Canvas de Edição**: Toda a pasta `canvas/` (incluindo `drop_region.dart`, etc).
3. **Barra Lateral**: Toda a pasta `sidebar/` (incluindo o menu de componentes e propriedades).
4. **Visualização de Device**: Mover qualquer lógica que gere o mockup de celular/device para o exemplo.

## Refatoração da Biblioteca (`schema_build`)
A biblioteca deve manter apenas o que é essencial para o funcionamento do schema:
1. **Core Models**: `WidgetNode`, `SchemaConfig`, `MenuItemModel`, etc.
2. **State Management**: Manter o `SchemaEditorState` (ou renomear para `SchemaController`) se ele contiver a lógica de manipulação da árvore de widgets que o renderizador precisa.
3. **Render Engine**: O `SchemaWidget` deve continuar sendo o componente principal de renderização.
4. **Exports**: Ajustar o arquivo `lib/schema_build.dart` para expor apenas as classes necessárias para que o projeto `example` consiga construir o Editor e renderizar o Schema.

## Padronização de Registro de Widgets (Remoção de Defaults)
A biblioteca não deve mais possuir widgets "embutidos" ou registrados por padrão no `SchemaManager`.
1. **Registro Mandatório**: Todos os widgets utilizados devem ser registrados obrigatoriamente através da implementação da interface `Schema` definida em `lib/src/schema/schema_base.dart`.
2. **Mapeamento Explícito**: O `SchemaManager` deve conter apenas os componentes que forem mapeados e carregados via `Schemas.load()`.
3. **Refatoração de Core Widgets**: Mover os widgets básicos que hoje estão na lib para um `CoreSchema` (ou similar) e carregá-lo no projeto `example` para manter a funcionalidade.

## Critérios de Aceitação
- [ ] O projeto `example` compila sem erros.
- [ ] A funcionalidade de Drag & Drop continua funcionando no projeto `example`.
- [ ] A biblioteca `schema_build` não contém referências a pacotes de terceiros exclusivos de edição (como o `super_drag_and_drop`).
- [ ] **Novo**: Não existem widgets registrados automaticamente; todo o catálogo de widgets do Editor é populado via `Schemas.load()`.
- [ ] Separação clara: Lib = Lógica/Renderização | Example = Interface de Edição.