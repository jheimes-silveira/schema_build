import '../schema/schema_manager.dart';

/// Represents a single widget node in the canvas tree.
///
/// Each node has a type and optional children.
/// The tree structure supports nesting (e.g., a Text inside a Column).
class WidgetNode {
  WidgetNode({
    required this.id,
    required this.type,
    List<WidgetNode>? children,
    this.parentId,
  }) : children = children ?? [];

  final String id;

  /// The unique type of the component (e.g., 'container', 'text').
  final String type;

  final List<WidgetNode> children;
  final String? parentId;

  /// Indicates whether this node can accept child drops.
  bool get canAcceptChildren {
    final definition = Schemas.manager.getDefinition(type);
    if (definition == null) return false;
    return definition.acceptsChildren;
  }

  WidgetNode copyWith({
    String? id,
    String? type,
    List<WidgetNode>? children,
    String? parentId,
  }) {
    return WidgetNode(
      id: id ?? this.id,
      type: type ?? this.type,
      children: children ?? this.children.map((c) => c.copyWith()).toList(),
      parentId: parentId ?? this.parentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'children': children.map((c) => c.toJson()).toList(),
      if (parentId != null) 'parentId': parentId,
    };
  }

  factory WidgetNode.fromJson(Map<String, dynamic> json) {
    return WidgetNode(
      id: json['id'] as String,
      type: json['type'] as String,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => WidgetNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      parentId: json['parentId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetNode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WidgetNode(id: $id, type: $type, '
      'children: ${children.length})';
}

