import 'dart:async';
import 'package:flutter/material.dart';
import '../models/widget_node.dart';

/// Signature for the function that builds a widget from data and children.
typedef ComponentBuilder = Widget Function(
  BuildContext context,
  WidgetNode node,
  List<Widget> children, {
  Object? data,
});

/// Defines a component that can be used in the schema editor and renderer.
abstract class ComponentDefinition {
  /// Unique identifier for the component type (e.g., 'container').
  String get type;

  /// Human-readable name in the palette.
  String get name;

  /// Short description of the component.
  String get description;

  /// Indicates whether this component can contain other widgets.
  bool get acceptsChildren;

  /// The actual builder function that returns the Flutter widget.
  ComponentBuilder get builder;

  /// Default properties for this component type.
  ///
  /// These properties are copied to the [WidgetNode] when it's created.
  Map<String, dynamic>? get properties => null;

  /// Initializes the component.
  ///
  /// Called exactly once when the component is inserted into the tree (controller's initState).
  /// Use this method to perform initial setup, API calls, or register listeners.
  ///
  /// To update the component's UI, use [SchemaComponentController.dispatchDataById].
  Future<void> onInit(BuildContext context, WidgetNode node) async {}

  /// Handles actions sent by the App Host or other components.
  ///
  /// Returns a [FutureOr] with the result of the action.
  FutureOr<Object?> onReceiveAction(
    BuildContext context,
    WidgetNode node,
    String action,
    Object? data,
  ) =>
      null;
}
