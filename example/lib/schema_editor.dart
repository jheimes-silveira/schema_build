import 'package:flutter/material.dart';

import 'dynamic_controller_page.dart';
import 'dynamic_home_page.dart';
import 'package:schema_build/schema_build.dart';
import 'exemple_preview_components.dart';
import 'schema_data.dart';

class SchemaEditorPage extends StatelessWidget {
  const SchemaEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schema Editor', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_input_component),
            tooltip: 'Controller Example',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DynamicControllerPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.rocket_launch),
            tooltip: 'Production View (SDUI)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DynamicHomePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'Preview App',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExamplePreviewComponents(),
                ),
              );
            },
          ),
        ],
      ),
      body: SchemaEditor(
        onSchemaChanged: (schema) {
          SchemaData.lastSavedSchema = schema;
          debugPrint('Schema updated and saved in SchemaData');
        },
      ),
    );
  }
}
