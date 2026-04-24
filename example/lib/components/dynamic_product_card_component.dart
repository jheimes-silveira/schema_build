import 'dart:math';
import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';

/// Um componente que demonstra atualizações dinâmicas e reativas.
/// 
/// Ele exibe um "preço" que é gerado aleatoriamente toda vez que o 
/// [onUpdateData] é chamado, permitindo testar o mecanismo de gatilho.
class DynamicProductCardComponent extends ComponentDefinition {
  @override
  String get type => 'dynamic_product_card';

  @override
  String get name => 'Card de Produto Dinâmico';

  @override
  String get description => 'Card com preço que atualiza via trigger.';

  @override
  bool get acceptsChildren => false;

  @override
  Future<void> onInit(BuildContext context, WidgetNode node) async {
    // Simula uma busca inicial
    final random = Random();
    final price = 50.0 + random.nextDouble() * 150.0;
    
    SchemaComponentController.dispatchDataById(node.id, {
      'id': node.id,
      'title': 'Produto Especial ${node.id.substring(0, 4)}',
      'price': price,
      'lastUpdate': DateTime.now().toString().split('.').first.split(' ').last,
    });
  }

  @override
  ComponentBuilder get builder => (context, children, {data}) {
    final Map<String, dynamic> info = data is Map<String, dynamic> ? data : {};
    final title = info['title'] ?? 'Carregando...';
    final price = info['price'] as double? ?? 0.0;
    final lastUpdate = info['lastUpdate'] ?? '--:--:--';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.shopping_bag, size: 40, color: Colors.blue)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'R\$ ${price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                Text(
                  lastUpdate,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  };
}
