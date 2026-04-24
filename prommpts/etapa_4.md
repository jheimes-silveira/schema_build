# Etapa 4: Integração em Produção e Server-Driven UI (SDUI)

O objetivo desta etapa é consolidar o uso da `schema_build` como um motor de **Server-Driven UI**. Isso permite que o app real consuma configurações de interface vindas de um backend e as renderize dinamicamente, utilizando tanto os componentes core quanto componentes de negócio customizados.

## 1. Visão Geral do Fluxo SDUI

O fluxo típico para um app real utilizando esta lib será:
1. **Registro**: O app registra os esquemas (core + customizados) na inicialização.
2. **Fetch**: O app busca o JSON de configuração de uma API ou Firebase Remote Config.
3. **Parsing**: O JSON é convertido em uma árvore de `WidgetNode`.
4. **Renderização**: O `SchemaWidget` transforma a árvore em widgets Flutter reais, injetando dados dinâmicos.

---

## 2. Sugestão de Implementação: Componentes de Domínio

Para que o SDUI seja útil, você deve registrar componentes que façam sentido para o seu negócio.

### Exemplo: Registro de um Card de Produto
```dart
class ProductCardComponent extends ComponentDefinition {
  @override
  String get type => 'product_card';
  @override
  String get name => 'Card de Produto';
  @override
  String get description => 'Exibe foto, nome e preço de um produto.';
  @override
  IconData get icon => Icons.shopping_cart;
  @override
  bool get acceptsChildren => false;
  @override
  int get maxChildren => 0;

  @override
  List<ComponentProperty> get properties => [
    const ComponentProperty(id: 'productId', name: 'ID do Produto', type: PropertyType.string),
    const ComponentProperty(id: 'showPrice', name: 'Mostrar Preço', type: PropertyType.boolean, defaultValue: true),
  ];

  @override
  ComponentBuilder get builder => (context, p, children) {
    // Aqui você pode usar seu Design System real
    return MyProductCard(
      id: p['productId'],
      showPrice: p['showPrice'] ?? true,
      onTap: () => Navigator.pushNamed(context, '/product/${p['productId']}'),
    );
  };
}
```

---

## 3. Exemplo de Uso no App Real

Abaixo, um exemplo de como carregar uma Home dinâmica:

```dart
class DynamicHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flux Store')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Api.getHomeLayout(), // Busca o JSON do servidor
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          // 1. Converte o JSON em Node
          final rootNode = WidgetNode.fromJson(snapshot.data!);

          // 2. Renderiza com SchemaWidget
          return SingleChildScrollView(
            child: SchemaWidget(
              node: rootNode,
              dataOverrides: {
                // Injeção de dados que o JSON pode não ter (ex: nome do usuário logado)
                'user_greeting': {'content': 'Olá, João!'},
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## 4. Próximos Passos Sugeridos

Para levar a implementação ao próximo nível, considere adicionar:

- **Actions System**: No `properties` do JSON, adicione um campo `onTap` que descreva uma ação (ex: `{"action": "navigate", "route": "/cart"}`). Crie um `ActionHandler` na lib para executar essas strings.
- **Dynamic Keys**: Permitir que propriedades usem chaves como `$user.name` que o `SchemaWidget` resolve automaticamente a partir de um `DataProvider`.
- **Local Persistence**: Criar uma extensão para salvar o último JSON baixado no `shared_preferences` para permitir uso offline (Offline-First SDUI).

---

## 5. Tarefas de Implementação (Checklist)

Para concretizar esta etapa, siga este roteiro de desenvolvimento:

- [ ] **Criar um Mock Repository**: 
  - Implementar uma classe `SchemaRepository` que simule uma chamada de rede com `Future.delayed`.
  - Ela deve retornar um JSON complexo contendo uma mistura de componentes core e componentes customizados.
  
- [ ] **Mapear Ações (onTap)**:
  - Adicionar o suporte a `onTap` no `ComponentDefinition`.
  - Criar um `ActionHandler` global que receba um `Map<String, dynamic>` (a ação) e execute a lógica correspondente (ex: `Navigator.push`, `print`, `showSnackBar`).
  
- [ ] **Testar com Overrides Dinâmicos**:
  - Utilizar o parâmetro `dataOverrides` do `SchemaWidget` para injetar dados reais.
  - **Exemplo**: Passar um preço atualizado de um produto ou o nome do usuário logado, garantindo que o `WidgetNode` (JSON) permaneça estático enquanto os valores exibidos são dinâmicos.