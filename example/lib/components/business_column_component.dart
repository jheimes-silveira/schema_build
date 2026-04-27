import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';

class BusinessColumnComponent extends ComponentDefinition {
  @override
  String get type => 'business_column';

  @override
  String get name => 'Seção (Coluna)';

  @override
  String get description => 'Agrupador vertical para componentes de negócio.';

  @override
  bool get acceptsChildren => true;

  @override
  ComponentBuilder get builder => (context, node, children, {data}) {
    final p = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final spacing = (p['spacing'] as num?)?.toDouble() ?? 16.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      ),
    );
  };
}
