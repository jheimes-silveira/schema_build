import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';

/// Componente que demonstra o ciclo de vida de dados (onUpdateData).
class StockStatusComponent extends ComponentDefinition {
  @override
  String get type => 'stock_status';

  @override
  String get name => 'Status de Estoque';

  @override
  String get description => 'Exibe o estoque reativo de um produto.';

  @override
  bool get acceptsChildren => false;

  @override
  Future<void> onInit(BuildContext context, WidgetNode node) async {
    final sku = "SKU-${node.id.hashCode.abs().toString().substring(0, 4)}";
    
    // Simula delay de rede
    await Future.delayed(const Duration(seconds: 2));
    final stockCount = (sku.hashCode % 100).abs();
    
    SchemaComponentController.dispatchDataById(node.id, {
      'sku': sku,
      'stock': stockCount,
    });
  }

  @override
  ComponentBuilder get builder => (context, children, {data}) {
    final Map<String, dynamic> info = data is Map<String, dynamic> ? data : {};
    final sku = info['sku'] ?? 'Carregando...';
    final stock = info['stock'] as int?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SKU: $sku',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              if (stock == null)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  'Estoque: $stock unidades',
                  style: TextStyle(
                    color: stock > 10 ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  };
}
