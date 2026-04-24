import 'package:flutter/material.dart';

import '../models/schema_config.dart';
import '../models/widget_node.dart';
import '../schema/schema_manager.dart';

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
      id: 'wn_${DateTime.now().millisecondsSinceEpoch}_${_rootNodes.length}',
      type: type,
    );
    _rootNodes.add(node);
    notifyListeners();
  }

  /// Adds a new widget of [type] as a child of [parentId].
  void addWidgetToParent(String parentId, String type) {
    final parent = _findNode(parentId, _rootNodes);
    if (parent == null || !parent.canAcceptChildren) return;

    final definition = Schemas.manager.getDefinition(type);
    if (definition == null) return;

    final node = WidgetNode(
      id: 'wn_${DateTime.now().millisecondsSinceEpoch}_${parent.children.length}',
      type: type,
      parentId: parentId,
    );
    parent.children.add(node);
    notifyListeners();
  }

  /// Removes a widget and all its children from the tree.
  void removeWidget(String widgetId) {
    if (_removeFromList(_rootNodes, widgetId)) {
      if (_selectedWidgetId == widgetId) {
        _selectedWidgetId = null;
      }
      notifyListeners();
    }
  }

  /// Selects a widget by its ID.
  void selectWidget(String? widgetId) {
    if (_selectedWidgetId == widgetId) return;
    _selectedWidgetId = widgetId;
    notifyListeners();
  }

  /// Clears the current widget selection.
  void clearSelection() {
    if (_selectedWidgetId == null) return;
    _selectedWidgetId = null;
    notifyListeners();
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

  /// Reorders widgets within the same parent or at the root level.
  void reorderWidgets(int oldIndex, int newIndex, {String? parentId}) {
    if (oldIndex < newIndex) newIndex -= 1;

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
