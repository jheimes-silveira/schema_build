import 'dart:async';
import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import '../test_repository.dart';

/// Componente de Action Card
/// Um card com imagem, título e botões de ação.
/// Agora integrado com o sistema de Ações e Eventos da Etapa 9.
class ActionCardComponent extends ComponentDefinition {
  @override
  String get type => 'action_card';
  @override
  String get name => 'Card de Ação';
  @override
  String get description => 'Card com imagem e botões interativos';
  @override
  bool get acceptsChildren => false;

  @override
  Future<void> onInit(BuildContext context, WidgetNode node) async {
    final data = await TestRepository().test();
    SchemaComponentController.dispatchDataById(node.id, data);
  }

  @override
  FutureOr<Object?> onReceiveAction(BuildContext context, WidgetNode node, String action, Object? data) {
    if (action == 'get_title') {
      // Exemplo de retorno de dado do componente para o Host
      return 'Título capturado via ação';
    }
    return null;
  }

  @override
  ComponentBuilder get builder => (context, node, children, {data}) {
        final p = data is Map<String, dynamic> ? data : <String, dynamic>{};
        final bus = SchemaActionScope.of(context);

        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                p['imageUrl'] as String? ?? 'https://picsum.photos/400/200',
                height: (p['height'] as num?)?.toDouble() ?? 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, _, stackTrace) => Container(
                    height: (p['height'] as num?)?.toDouble() ?? 140,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] as String? ?? 'Título do Card',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: p['titleColor'] != null
                            ? Color(int.parse(p['titleColor'].toString().replaceAll('#', '0xFF')))
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p['subtitle'] as String? ?? 'Subtítulo detalhado do card para descrever a ação.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Notifica observadores externos (Analytics, Logs, etc)
                        SchemaComponentController.updateExternalState(node.id, type, {'event': 'cancel'});
                        // Mantém compatibilidade com o sistema de ações via Scope se necessário
                        bus.emit(node, 'card_cancel', {'id': node.id});
                      },
                      child: const Text('CANCELAR'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final eventData = {
                          'id': node.id,
                          'timestamp': DateTime.now().toIso8601String(),
                          'event': 'confirm',
                        };
                        // Notifica observadores externos
                        SchemaComponentController.updateExternalState(node.id, type, eventData);
                        // Emite evento via Scope
                        bus.emit(node, 'card_confirm', eventData);
                      },
                      child: const Text('CONFIRMAR'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      };
}
