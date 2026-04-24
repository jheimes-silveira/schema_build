import 'dart:async';
import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import 'component_definition.dart';
import 'schema_events.dart';

/// A widget that manages the data lifecycle of a single component.
///
/// Responsible for triggering initialization and storing the component's internal state,
/// resolving conflicts with [dataOverrides].
class SchemaComponentController extends StatefulWidget {
  const SchemaComponentController({
    super.key,
    required this.node,
    required this.definition,
    required this.builder,
    this.dataOverrides,
  });

  /// The widget node this controller manages.
  final WidgetNode node;

  /// The component definition associated with the node.
  final ComponentDefinition definition;

  /// External data overrides (e.g., from the real app).
  final Map<String, dynamic>? dataOverrides;

  /// Builder that receives the final processed data to render the component.
  final Widget Function(BuildContext context, Object? effectiveData) builder;

  /// Global Stream Controller for triggering update events.
  static final _eventController =
      StreamController<SchemaUpdateEvent>.broadcast();

  /// Global Stream Controller for triggering actions.
  static final _actionController =
      StreamController<SchemaActionEvent>.broadcast();

  /// Global Stream Controller for capturing action responses.
  static final _responseController =
      StreamController<SchemaActionResponseEvent>.broadcast();

  /// Global Stream Controller for Push data injection (UI).
  static final _pushController =
      StreamController<SchemaPushDataEvent>.broadcast();

  /// Global Stream Controller for logical observation (Events).
  static final _observationController =
      StreamController<SchemaObservationEvent>.broadcast();

  /// Global state cache for components.
  static final Map<String, Object?> _stateCache = {};

  static int _requestCounter = 0;

  /// Dispatches an update event for specific or global components.
  static void dispatchUpdate(SchemaUpdateEvent event) {
    _eventController.add(event);
  }

  /// Injects data into a specific component by ID (Triggers rebuild).
  static void dispatchDataById(String id, Object? data) {
    _stateCache[id] = data;
    _pushController.add(SchemaPushDataEvent(targetId: id, data: data));
  }

  /// Injects data into all components of a given type (Triggers rebuild).
  static void dispatchDataByType(String type, Object? data) {
    _pushController.add(
        SchemaPushDataEvent(targetComponentType: type, data: data));
  }

  /// Notifies external observers about a state change (Without triggering UI rebuild).
  static void updateExternalState(String id, String type, Object? data) {
    _observationController
        .add(SchemaObservationEvent(id: id, type: type, data: data));
  }

  /// Registers a listener for a specific component that calls [updateExternalState].
  static StreamSubscription onObserveDataById(
      String id, Function(Object?) onDataReturned) {
    return _observationController.stream
        .where((event) => event.id == id)
        .listen((event) => onDataReturned(event.data));
  }

  /// Registers a listener for all components of a type that call [updateExternalState].
  static StreamSubscription onObserveDataByType(
      String type, Function(Object?) onDataReturned) {
    return _observationController.stream
        .where((event) => event.type == type)
        .listen((event) => onDataReturned(event.data));
  }

  /// Sends an action to a specific component and awaits the response.
  static Future<T?> dispatchAction<T>(
    String targetId,
    String action, {
    Object? data,
    String? targetComponentType,
  }) async {
    final requestId =
        'req_${_requestCounter++}_${DateTime.now().microsecondsSinceEpoch}_$targetId';
    final completer = Completer<T?>();

    StreamSubscription? subscription;
    subscription = _responseController.stream.listen((response) {
      if (response.requestId == requestId) {
        subscription?.cancel();
        if (response.error != null) {
          completer.completeError(response.error!);
        } else {
          completer.complete(response.result as T?);
        }
      }
    });

    _actionController.add(SchemaActionEvent(
      requestId: requestId,
      action: action,
      targetId: targetId,
      targetComponentType: targetComponentType,
      data: data,
    ));

    // Timeout para evitar que o completer fique aberto para sempre
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        subscription?.cancel();
        debugPrint('SchemaComponentController: Timeout na ação "$action" para "$targetId"');
        return null;
      },
    );
  }

  @override
  State<SchemaComponentController> createState() =>
      _SchemaComponentControllerState();
}

class _SchemaComponentControllerState extends State<SchemaComponentController> {
  Object? _internalData;
  StreamSubscription? _eventSubscription;
  StreamSubscription? _actionSubscription;
  StreamSubscription? _pushSubscription;

  // Controle de prioridade e tempo
  int _lastPushTimestamp = 0;

  @override
  void initState() {
    super.initState();
    
    // Recupera do cache se existir
    if (SchemaComponentController._stateCache.containsKey(widget.node.id)) {
      _internalData = SchemaComponentController._stateCache[widget.node.id];
    }

    _subscribeToUpdates();
    _subscribeToActions();
    _subscribeToPushData();

    // Ciclo de vida: onInit chamado uma única vez
    _initComponent();
  }

  Future<void> _initComponent() async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    await widget.definition.onInit(context, widget.node);
    
    // Se um push chegou durante o onInit (mais recente), não sobrescrevemos
    if (mounted && _lastPushTimestamp < startTime) {
      // Nota: o onInit deve usar dispatchDataById para atualizar o estado
      // mas se ele retornasse algo, trataríamos aqui. 
      // Seguindo a especificação, onInit é Future<void>.
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _actionSubscription?.cancel();
    _pushSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToUpdates() {
    _eventSubscription = SchemaComponentController._eventController.stream.listen((event) {
      if (!mounted) return;

      bool shouldRefresh = false;

      switch (event.type) {
        case SchemaUpdateType.all:
          shouldRefresh = true;
          break;
        case SchemaUpdateType.byId:
          shouldRefresh = event.targetId == widget.node.id;
          break;
        case SchemaUpdateType.byType:
          shouldRefresh = event.targetComponentType == widget.node.type;
          break;
      }

      if (shouldRefresh) {
        setState(() {}); // Força rebuild da UI
      }
    });
  }

  void _subscribeToPushData() {
    _pushSubscription = SchemaComponentController._pushController.stream.listen((event) {
      if (!mounted) return;

      if (event.matches(widget.node.id, widget.node.type)) {
        _lastPushTimestamp = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          _internalData = event.data;
        });
        
        // Atualiza cache apenas se for por ID específico
        if (event.targetId == widget.node.id) {
          SchemaComponentController._stateCache[widget.node.id] = event.data;
        }
      }
    });
  }

  void _subscribeToActions() {
    _actionSubscription = SchemaComponentController._actionController.stream.listen((event) async {
      if (!mounted) return;

      if (event.matches(widget.node.id, widget.node.type)) {
        try {
          final result = await widget.definition.onReceiveAction(
            context,
            widget.node,
            event.action,
            event.data,
          );

          SchemaComponentController._responseController.add(SchemaActionResponseEvent(
            requestId: event.requestId,
            result: result,
          ));
        } catch (e) {
          SchemaComponentController._responseController.add(SchemaActionResponseEvent(
            requestId: event.requestId,
            error: e,
          ));
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant SchemaComponentController oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Se o nó mudou, verificamos cache novamente
    if (widget.node.id != oldWidget.node.id) {
       if (SchemaComponentController._stateCache.containsKey(widget.node.id)) {
        setState(() {
          _internalData = SchemaComponentController._stateCache[widget.node.id];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveData = _resolveEffectiveData();
    return widget.builder(context, effectiveData);
  }

  /// Resolve o dado final: mescla o dado interno do componente com overrides se forem Maps.
  Object? _resolveEffectiveData() {
    final overrides = _getOverridesForNode(widget.node);

    if (overrides == null) return _internalData;

    if (_internalData is Map<String, dynamic> &&
        overrides is Map<String, dynamic>) {
      return {
        ...(_internalData as Map<String, dynamic>),
        ...overrides,
      };
    }

    // Se não for um mapa, o override tem precedência (ex: uma String ou int)
    return overrides;
  }

  /// Extrai sobrescrições relevantes para este nó específico.
  dynamic _getOverridesForNode(WidgetNode node) {
    if (widget.dataOverrides == null) return null;

    final dataOverrides = widget.dataOverrides!;

    // 1. Verifica sobrescrições pelo ID do nó (Alta prioridade)
    if (dataOverrides.containsKey(node.id)) {
      return dataOverrides[node.id];
    }

    // 2. Verifica sobrescrições pelo tipo do nó (Baixa prioridade)
    if (dataOverrides.containsKey(node.type)) {
      return dataOverrides[node.type];
    }

    return null;
  }
}
