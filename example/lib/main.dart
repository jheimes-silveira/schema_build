import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import 'components/custom_app_schema.dart';
import 'schema_editor.dart';

void main() {
  // Registra os componentes customizados do app de exemplo
  Schemas.load(CustomAppSchema());

  runApp(const SchemaBuilderApp());
}

class SchemaBuilderApp extends StatelessWidget {
  const SchemaBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schema Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SchemaEditorPage(),
    );
  }
}
