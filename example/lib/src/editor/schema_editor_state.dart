import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import 'package:uuid/uuid.dart';

/// Central state manager for the Schema Editor.
///
/// Manages the configuration, the widget tree of the canvas, and the selection state.
/// Uses [ChangeNotifier] for reactive UI updates.
class SchemaEditorState extends ChangeNotifier {
  SchemaEditorState({
    SchemaConfig? config,
    List<WidgetNode>? rootNodes,
  })  : _config = config ?? const SchemaConfig(),
        _rootNodes = rootNodes ?? [];

  SchemaConfig _config;

  // Notifiers para atualizações granulares
  final ChangeNotifier structureChanged = ChangeNotifier();
  final ValueNotifier<String?> selectionChanged = ValueNotifier<String?>(null);

  // Widget tree state
  final List<WidgetNode> _rootNodes;
  String? _selectedWidgetId;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  SchemaConfig get config => _config;

  /// Root level widget nodes on the canvas.
  List<WidgetNode> get rootNodes => List.unmodifiable(_rootNodes);

  /// ID of the currently selected widget (null if none).
  String? get selectedWidgetId => _selectedWidgetId;

  /// The currently selected widget node (null if none).
  WidgetNode? get selectedWidget {
    if (_selectedWidgetId == null) return null;
    return _findNode(_selectedWidgetId!, _rootNodes);
  }

  // ---------------------------------------------------------------------------
  // Configuration Mutations
  // ---------------------------------------------------------------------------

  void updateConfig({
    Color? backgroundColor,
  }) {
    _config = _config.copyWith(
      backgroundColor: backgroundColor,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Widget Tree Mutations
  // ---------------------------------------------------------------------------

  /// Adds a new widget of [type] to the root level of the canvas.
  void addWidgetToCanvas(String type) {
    final definition = Schemas.manager.getDefinition(type);
    if (definition == null) return;

    final node = WidgetNode(
      id: const Uuid().v4(),
      type: type,
      properties: definition.properties != null
          ? Map<String, dynamic>.from(definition.properties!)
          : null,
    );
    _rootNodes.add(node);
    structureChanged.notifyListeners();
    notifyListeners();
  }

  /// Adds a new widget of [type] as a child of [parentId].
  void addWidgetToParent(String parentId, String type) {
    final parent = _findNode(parentId, _rootNodes);
    if (parent == null || !parent.canAcceptChildren) return;

    final definition = Schemas.manager.getDefinition(type);
    if (definition == null) return;

    final node = WidgetNode(
      id: const Uuid().v4(),
      type: type,
      parentId: parentId,
      properties: definition.properties != null
          ? Map<String, dynamic>.from(definition.properties!)
          : null,
    );
    parent.children.add(node);
    structureChanged.notifyListeners();
    notifyListeners();
  }

  /// Removes a widget and all its children from the tree.
  void removeWidget(String widgetId) {
    if (_removeFromList(_rootNodes, widgetId)) {
      if (_selectedWidgetId == widgetId) {
        _selectedWidgetId = null;
        selectionChanged.value = null;
      }
      structureChanged.notifyListeners();
      notifyListeners();
    }
  }

  /// Selects a widget by its ID.
  void selectWidget(String? widgetId) {
    if (_selectedWidgetId == widgetId) return;
    _selectedWidgetId = widgetId;
    selectionChanged.value = widgetId;
    // Note: Não chamamos notifyListeners() aqui para evitar rebuild da lista inteira
  }

  /// Clears the current widget selection.
  void clearSelection() {
    if (_selectedWidgetId == null) return;
    _selectedWidgetId = null;
    selectionChanged.value = null;
    // Note: Não chamamos notifyListeners() aqui para evitar rebuild da lista inteira
  }

  /// Moves a widget to a new position, optionally under a new parent.
  void moveWidget(String widgetId, int newIndex, {String? newParentId}) {
    final node = _findNode(widgetId, _rootNodes);
    if (node == null) return;

    // Remove from current location
    _removeFromList(_rootNodes, widgetId);

    // Add to new location
    if (newParentId == null) {
      final clampedIndex = newIndex.clamp(0, _rootNodes.length);
      _rootNodes.insert(clampedIndex, node.copyWith(parentId: null));
    } else {
      final newParent = _findNode(newParentId, _rootNodes);
      if (newParent != null && newParent.canAcceptChildren) {
        final clampedIndex = newIndex.clamp(0, newParent.children.length);
        newParent.children
            .insert(clampedIndex, node.copyWith(parentId: newParentId));
      } else {
        // Fallback: add to root
        _rootNodes.add(node.copyWith(parentId: null));
      }
    }
    notifyListeners();
  }

  /// Updates the properties of a widget.
  void updateWidgetProperties(String widgetId, Map<String, dynamic> properties) {
    final node = _findNode(widgetId, _rootNodes);
    if (node == null) return;

    node.properties.addAll(properties);
    notifyListeners();
  }

  /// Reorders widgets within the same parent or at the root level.
  void reorderWidgets(int oldIndex, int newIndex, {String? parentId}) {
    debugPrint('REORDER: old=$oldIndex, new=$newIndex, parent=$parentId');
    // Ajuste padrão do ReorderableListView
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    if (oldIndex == newIndex) return;

    List<WidgetNode> targetList;
    if (parentId == null) {
      targetList = _rootNodes;
    } else {
      final parent = _findNode(parentId, _rootNodes);
      if (parent == null) return;
      targetList = parent.children;
    }

    if (oldIndex >= 0 && oldIndex < targetList.length) {
      final node = targetList.removeAt(oldIndex);
      final clampedIndex = newIndex.clamp(0, targetList.length);
      targetList.insert(clampedIndex, node);
      
      // Importante: notifyListeners disparado após a mutação completa
      structureChanged.notifyListeners();
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Schema Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toSchema() {
    return {
      'config': _config.toJson(),
      'rootNodes': _rootNodes.map((node) => node.toJson()).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Recursively searches for a node by ID in the tree.
  WidgetNode? _findNode(String id, List<WidgetNode> nodes) {
    for (final node in nodes) {
      if (node.id == id) return node;
      final found = _findNode(id, node.children);
      if (found != null) return found;
    }
    return null;
  }

  /// Recursively removes a node by ID from the tree.
  bool _removeFromList(List<WidgetNode> nodes, String id) {
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i].id == id) {
        nodes.removeAt(i);
        return true;
      }
      if (_removeFromList(nodes[i].children, id)) return true;
    }
    return false;
  }
}
