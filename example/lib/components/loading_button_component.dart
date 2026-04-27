import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import '../test_repository.dart';

/// Componente de Loading Button
/// Um botão que pode mostrar um indicador de carregamento e um ícone.
class LoadingButtonComponent extends ComponentDefinition {
  @override
  String get type => 'loading_button';
  @override
  String get name => 'Botão de Carregamento';
  @override
  String get description => 'Botão com ícone e estado de loading';
  @override
  bool get acceptsChildren => false;

  @override
  Future<void> onInit(BuildContext context, WidgetNode node) async {
    final data = await TestRepository().test();
    SchemaComponentController.dispatchDataById(node.id, data);
  }

  @override
  ComponentBuilder get builder => (context, node, children, {data}) {
        final p = data is Map<String, dynamic> ? data : <String, dynamic>{};
        final isLoading = p['isLoading'] as bool? ?? false;
        
        return ElevatedButton.icon(
          onPressed: isLoading ? null : () {},
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check),
          label: Text(p['label'] as String? ?? 'Confirmar'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: p['backgroundColor'] != null
                ? Color(int.parse(p['backgroundColor'].toString().replaceAll('#', '0xFF')))
                : null,
            foregroundColor: p['backgroundColor'] != null ? Colors.white : null,
          ),
        );
      };
}
