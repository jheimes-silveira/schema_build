import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import 'components/device_frame.dart';
import 'schema_data.dart';
import 'test_repository.dart';

class ExamplePreviewComponents extends StatefulWidget {
  const ExamplePreviewComponents({super.key});

  @override
  State<ExamplePreviewComponents> createState() =>
      _ExamplePreviewComponentsState();
}

class _ExamplePreviewComponentsState extends State<ExamplePreviewComponents> {
  bool _isLoading = true;
  Map<String, dynamic>? _apiData;
  final TestRepository _repository = TestRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.test();
      setState(() {
        _apiData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schema = SchemaData.lastSavedSchema;

    if (schema == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: const Center(
          child: Text(
              'No saved schema to visualize.\nGo back to the editor and make some changes.',
              textAlign: TextAlign.center),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('App Preview')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading simulation data...'),
            ],
          ),
        ),
      );
    }

    // Extract configurations and root nodes
    final configMap = schema['config'] as Map<String, dynamic>? ?? {};
    final rootNodesJson = schema['rootNodes'] as List<dynamic>? ?? [];

    // Convert JSON to model objects
    final config = SchemaConfig.fromJson(configMap);
    final rootNodes = rootNodesJson
        .map((j) => WidgetNode.fromJson(j as Map<String, dynamic>))
        .toList();

    // Build the overrides map for the whole tree
    final overrides = _buildOverrides(rootNodes, _apiData ?? {});

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('App Preview (With Data)',
            style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Update data',
          ),
        ],
      ),
      body: DeviceFrame(
        backgroundColor: config.backgroundColor,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: rootNodes
              .map((node) => SchemaWidget(
                    key: ValueKey(node.id),
                    node: node,
                    dataOverrides: overrides,
                    onAction: (node, action, data) {
                      debugPrint(
                          '[Preview Action] Component: ${node.type} ($action) -> $data');
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Recursively builds a dataOverrides map for the entire tree using simulated API data.
  Map<String, dynamic> _buildOverrides(
      List<WidgetNode> nodes, Map<String, dynamic> apiData) {
    final overrides = <String, dynamic>{};
    for (final node in nodes) {
      final nodeData = _prepareDataForComponent(node.type, apiData);
      if (nodeData.isNotEmpty) {
        overrides[node.id] = nodeData;
      }
      if (node.children.isNotEmpty) {
        overrides.addAll(_buildOverrides(node.children, apiData));
      }
    }
    return overrides;
  }

  /// Converts the flat map from the API into a map compatible with the component (Binding Simulation)
  Map<String, dynamic> _prepareDataForComponent(
      String type, Map<String, dynamic> apiData) {
    final result = <String, dynamic>{};

    // Known mappings for example components
    final mappings = {
      'content': 'title', // For the Text component
      'title': 'title', // For ActionCard
      'subtitle': 'subtitle', // For ActionCard
      'imageUrl': 'imageUrl', // For ActionCard/Image
      'url': 'imageUrl', // For Image
      'text': 'buttonText', // For Button
      'items': 'items', // For InfoList
    };

    mappings.forEach((compKey, apiKey) {
      if (apiData.containsKey(apiKey)) {
        result[compKey] = apiData[apiKey];
      }
    });

    return result;
  }
}
