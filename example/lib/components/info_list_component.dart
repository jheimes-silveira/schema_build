import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import '../test_repository.dart';

/// Componente de Info List
/// Uma lista que exibe itens com ícone, título, descrição e URL de imagem.
class InfoListComponent extends ComponentDefinition {
  @override
  String get type => 'info_list';
  @override
  String get name => 'Lista de Informações';
  @override
  String get description => 'Lista com itens ricos';
  @override
  bool get acceptsChildren => false;

  @override
  Future<void> onInit(BuildContext context, WidgetNode node) async {
    final data = await TestRepository().test();
    SchemaComponentController.dispatchDataById(node.id, data);
  }

  @override
  ComponentBuilder get builder => (context, children, {data}) {
        List<dynamic> items = [];
        
        if (data is List) {
          items = data;
        } else if (data is Map<String, dynamic> && data.containsKey('items')) {
          items = data['items'] as List<dynamic>;
        }

        if (items.isEmpty) {
          items = [
            {
              'title': 'Item Padrão',
              'description': 'Descrição do item padrão',
              'imageUrl': 'https://picsum.photos/50/50',
              'icon': Icons.info_outline,
            }
          ];
        }

        return Column(
          children: items.map((item) {
            final itemData = item as Map<String, dynamic>;
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  itemData['imageUrl'] as String? ?? '',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, stackTrace) =>
                      Icon(itemData['icon'] as IconData? ?? Icons.help_outline),
                ),
              ),
              title: Text(itemData['title'] as String? ?? '',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(itemData['description'] as String? ?? '',
                  style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              dense: true,
            );
          }).toList(),
        );
      };
}
