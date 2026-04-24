# Schema Build — Fase 2: Widget Palette, Canvas Interativo e Painel de Propriedades

## Contexto

O `schema_build` já possui a estrutura base com sidebar de configurações, lista de menu items e um phone preview com drag & drop via `super_drag_and_drop`. Agora queremos evoluir para um **builder real de layouts** onde o usuário arrasta widgets genéricos para o canvas e edita suas propriedades visualmente.

---

## Objetivo

Transformar o painel esquerdo em uma **paleta de widgets** arrastáveis e adicionar um **painel direito de propriedades** que aparece quando um widget é selecionado no canvas.

---

## Widget Palette (Painel Esquerdo)

Os widgets disponíveis para arrastar ao canvas são:

| Widget       | Descrição                                      | Aceita filhos? |
|--------------|------------------------------------------------|----------------|
| `Container`  | Box com cor de fundo, padding, margin, border  | Sim (1 filho)  |
| `Text`       | Texto com estilo (cor, tamanho, peso, alinhamento) | Não         |
| `Image`      | Imagem via URL com fit e dimensões             | Não            |
| `Button`     | Botão com texto, cor, ação (placeholder)       | Não            |
| `Column`     | Layout vertical com espaçamento                | Sim (N filhos) |
| `Row`        | Layout horizontal com espaçamento              | Sim (N filhos) |
| `ListView`   | Lista scrollável vertical                      | Sim (N filhos) |
| `GridView`   | Grade com crossAxisCount configurável          | Sim (N filhos) |

Cada item da paleta deve ser arrastável (`DragItemWidget`) com `localData` contendo o `type` do widget.

---

## Canvas (Painel Central — Phone Preview)

### Comportamento de Drop
- O canvas aceita **N widgets** arrastados da paleta.
- Widgets de layout (`Column`, `Row`, `ListView`, `GridView`, `Container`) devem aceitar **drops aninhados** — ou seja, posso arrastar um `Text` para dentro de um `Column` que já está no canvas.
- Cada widget renderizado no canvas deve ter um estado visual de hover/seleção.

### Seleção de Widget
- Ao **clicar** em um widget no canvas, ele se torna o **widget selecionado** (`selectedWidgetId`).
- O widget selecionado deve ter um destaque visual (borda azul + handles de seleção).
- Clicar fora de qualquer widget ou pressionar `Esc` deve limpar a seleção.

---

## Painel de Propriedades (Painel Direito)

Quando um widget está selecionado, um painel direito (~280px) deve aparecer exibindo editores de propriedades **dinâmicos conforme o tipo** do widget:

### Propriedades por Widget

**Container:**
- Cor de fundo (color picker)
- Padding (top, right, bottom, left)
- Margin (top, right, bottom, left)
- Border radius
- Largura / Altura (opcional, com auto)

**Text:**
- Conteúdo (TextField)
- Tamanho da fonte (slider ou input)
- Peso da fonte (dropdown: normal, bold, w100–w900)
- Cor do texto (color picker)
- Alinhamento (left, center, right, justify)

**Image:**
- URL da imagem (TextField)
- BoxFit (dropdown: cover, contain, fill, fitWidth, fitHeight)
- Largura / Altura

**Button:**
- Texto do botão (TextField)
- Cor de fundo (color picker)
- Cor do texto (color picker)
- Border radius

**Column / Row:**
- MainAxisAlignment (dropdown: start, center, end, spaceBetween, spaceAround, spaceEvenly)
- CrossAxisAlignment (dropdown: start, center, end, stretch)
- Espaçamento entre filhos (input numérico)

**ListView:**
- Direção do scroll (vertical/horizontal)
- Padding
- Espaçamento entre itens

**GridView:**
- crossAxisCount (input numérico)
- mainAxisSpacing / crossAxisSpacing
- childAspectRatio

### Comportamento
- Quando **nenhum widget** está selecionado, o painel direito pode ficar oculto ou exibir uma mensagem "Selecione um widget para editar".
- Alterações nas propriedades devem refletir **instantaneamente** no canvas (reatividade via ChangeNotifier).

---

## Modelo de Dados Sugerido

Cada widget no canvas deve ser representado por um nó na árvore:

```dart
class WidgetNode {
  final String id;
  final String type;           // 'container', 'text', 'image', 'button', 'column', 'row', 'listview', 'gridview'
  final Map<String, dynamic> properties;  // propriedades editáveis
  final List<WidgetNode> children;        // filhos (vazio para widgets leaf)
  final String? parentId;                 // referência ao pai na árvore
}
```

---

## Requisitos Técnicos

- **Estado**: Estender o `SchemaEditorState` existente ou criar um `CanvasState` dedicado com:
  - `List<WidgetNode> rootNodes` — nós raiz do canvas
  - `String? selectedWidgetId` — ID do widget selecionado
  - Métodos: `addWidget()`, `removeWidget()`, `updateProperty()`, `selectWidget()`, `moveWidget()`
- **Serialização**: O `toSchema()` deve incluir a árvore completa de widgets no JSON.
- **UI**: Layout final em 3 colunas: `Palette (240px) | Canvas (flex) | Properties (280px, condicional)`.