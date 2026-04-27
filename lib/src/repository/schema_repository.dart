import 'dart:async';

/// Repositório para gerenciar o carregamento de layouts dinâmicos (SDUI).
class SchemaRepository {
  static final SchemaRepository _instance = SchemaRepository._internal();
  factory SchemaRepository() => _instance;
  SchemaRepository._internal();

  /// Simula uma busca remota de layout usando apenas componentes de negócio.
  Future<Map<String, dynamic>> getRemoteLayout() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      "id": "root_page",
      "type": "business_column",
      "children": [
        {
          "id": "user_greeting",
          "type": "action_card",
        },
        {
          "id": "card_welcome",
          "type": "action_card",
        },
        {
          "id": "main_inventory_display",
          "type": "stock_status",
        },
        {
          "id": "product_grid",
          "type": "business_column",
          "children": [
            {
              "id": "dynamic_prod_a",
              "type": "dynamic_product_card",
            },
            {
              "id": "dynamic_prod_b",
              "type": "dynamic_product_card",
            }
          ]
        },
        {
          "id": "demo_input",
          "type": "input",
        },
        {
          "id": "demo_counter",
          "type": "counter",
        },
        {
          "id": "welcome_text",
          "type": "action_card",
        },
        {
          "id": "banner_home",
          "type": "action_card",
        },
        {
          "id": "btn_confirm",
          "type": "loading_button",
        },
        {
          "id": "btn_cart",
          "type": "loading_button",
        }
      ]
    };
  }

  /// Busca as propriedades/configurações de um nó específico.
  Future<Map<String, dynamic>> getPropertiesForNode(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final db = {
      "root_page": {"spacing": 20.0},
      "user_greeting": {
        "title": "Olá, Usuário!",
        "subtitle": "Bem-vindo de volta à nossa loja.",
      },
      "card_welcome": {
        "title": "Bem-vindo à Flux Store",
        "subtitle": "Explore nossos componentes de negócio customizados.",
        "imageUrl": "https://picsum.photos/400/200?random=10"
      },
      "main_inventory_display": {"sku": "FLUX-MAC-BOOK-2024"},
      "product_grid": {"spacing": 12.0},
      "dynamic_prod_a": {"title": "MacBook Pro M3"},
      "dynamic_prod_b": {"title": "iPhone 15 Pro"},
      "demo_input": {"label": "Nome do Cliente"},
      "demo_counter": {"count": 0},
      "welcome_text": {
        "title": "Ofertas do Dia",
        "subtitle": "Confira as melhores promoções hoje.",
      },
      "banner_home": {
        "imageUrl": "https://picsum.photos/800/200?random=11",
      },
      "btn_confirm": {"label": "Finalizar Pedido"},
      "btn_cart": {"label": "Adicionar ao Carrinho"}
    };

    return db[id] ?? {};
  }
}
