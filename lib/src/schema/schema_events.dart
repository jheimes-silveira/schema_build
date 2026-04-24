import 'package:flutter/foundation.dart';

/// Tipos de atualização que podem ser disparados no sistema de schema.
enum SchemaUpdateType {
  /// Atualiza componentes específicos pelo seu ID único.
  byId,

  /// Atualiza todos os componentes de um determinado tipo.
  byType,

  /// Força a atualização de todos os componentes renderizados.
  all,
}

/// Evento de atualização capturado pelos controladores de componentes.
@immutable
class SchemaUpdateEvent {
  const SchemaUpdateEvent({
    required this.type,
    this.targetId,
    this.targetComponentType,
  });

  final SchemaUpdateType type;
  final String? targetId;
  final String? targetComponentType;

  /// Atalho para criar um evento por ID.
  factory SchemaUpdateEvent.byId(String id) => SchemaUpdateEvent(
        type: SchemaUpdateType.byId,
        targetId: id,
      );

  /// Atalho para criar um evento por Tipo.
  factory SchemaUpdateEvent.byType(String componentType) => SchemaUpdateEvent(
        type: SchemaUpdateType.byType,
        targetComponentType: componentType,
      );

  /// Atalho para criar um evento global.
  factory SchemaUpdateEvent.all() => const SchemaUpdateEvent(
        type: SchemaUpdateType.all,
      );
}

/// Evento disparado quando uma ação é solicitada para um componente.
@immutable
class SchemaActionEvent {
  const SchemaActionEvent({
    required this.requestId,
    required this.action,
    this.targetId,
    this.targetComponentType,
    this.data,
  });

  final String requestId;
  final String action;
  final String? targetId;
  final String? targetComponentType;
  final Object? data;

  bool matches(String nodeId, String componentType) {
    if (targetId != null && targetId!.isNotEmpty) return targetId == nodeId;
    if (targetComponentType != null && targetComponentType!.isNotEmpty) {
      return targetComponentType == componentType;
    }
    return true; // Ação global se ambos forem nulos ou vazios
  }
}

/// Evento disparado para retornar o resultado de uma ação.
@immutable
class SchemaActionResponseEvent {
  const SchemaActionResponseEvent({
    required this.requestId,
    this.result,
    this.error,
  });

  final String requestId;
  final Object? result;
  final Object? error;
}

/// Evento para injeção de dados via Push (dispara rebuild na UI).
@immutable
class SchemaPushDataEvent {
  const SchemaPushDataEvent({
    required this.data,
    this.targetId,
    this.targetComponentType,
  });

  final Object? data;
  final String? targetId;
  final String? targetComponentType;

  bool matches(String nodeId, String componentType) {
    if (targetId != null) return targetId == nodeId;
    if (targetComponentType != null) return targetComponentType == componentType;
    return false;
  }
}

/// Evento de observação lógica (não dispara rebuild na UI).
@immutable
class SchemaObservationEvent {
  const SchemaObservationEvent({
    required this.id,
    required this.type,
    required this.data,
  });

  final String id;
  final String type;
  final Object? data;
}
