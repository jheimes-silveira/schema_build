import 'package:flutter/material.dart';

/// Global configuration for the Schema Editor.
///
/// Controls visual settings like background color for the canvas.
class SchemaConfig {
  const SchemaConfig({
    this.backgroundColor = Colors.white,
  });

  final Color backgroundColor;

  SchemaConfig copyWith({
    Color? backgroundColor,
  }) {
    return SchemaConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': _colorToHex(backgroundColor),
    };
  }

  factory SchemaConfig.fromJson(Map<String, dynamic> json) {
    return SchemaConfig(
      backgroundColor:
          _colorFromHex(json['backgroundColor'] as String?) ?? Colors.white,
    );
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
