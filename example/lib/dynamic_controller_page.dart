import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import 'components/device_frame.dart';

/// An example controller that manages the dynamic state of components.
///
/// This controller demonstrates how we can separate the app's business logic
/// from the dynamic layout rendering, allowing for real-time schema updates.
class SchemaDataController extends ChangeNotifier {
  Map<String, dynamic> _dataOverrides = {};

  /// Returns the current overrides map.
  Map<String, dynamic> get dataOverrides => _dataOverrides;

  /// Updates the data of a specific node.
  void updateNodeData(String nodeId, Map<String, dynamic> newData) {
    debugPrint('[Controller] Updating Node: $nodeId with Data: $newData');
    // We create a new map instance to ensure the ListenableBuilder detects the change
    _dataOverrides = Map.from(_dataOverrides);

    // Merge existing node data with the new data
    final existingNodeData =
        _dataOverrides[nodeId] as Map<String, dynamic>? ?? {};
    _dataOverrides[nodeId] = {
      ...existingNodeData,
      ...newData,
    };

    notifyListeners();
  }

  /// Clears all customizations.
  void reset() {
    debugPrint('[Controller] Resetting all overrides');
    _dataOverrides = {};
    notifyListeners();
  }
}

class DynamicControllerPage extends StatefulWidget {
  const DynamicControllerPage({super.key});

  @override
  State<DynamicControllerPage> createState() => _DynamicControllerPageState();
}

class _DynamicControllerPageState extends State<DynamicControllerPage> {
  final SchemaDataController _controller = SchemaDataController();
  final SchemaRepository _repository = SchemaRepository();
  late Future<Map<String, dynamic>> _layoutFuture;
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    _layoutFuture = _repository.getRemoteLayout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller & Reactivity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _layoutFuture = _repository.getRemoteLayout();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _layoutFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading remote layout.'));
          }

          final rootNode = WidgetNode.fromJson(snapshot.data!);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Simulation Panel (App Logic) - Sidebar
              SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: _buildAppLogicPanel(),
                ),
              ),

              const VerticalDivider(width: 1),

              // 2. Dynamic Layout Rendering (SDUI) - Inside Device
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F5F5),
                  child: DeviceFrame(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: SchemaWidget(
                            node: rootNode,
                            dataOverrides: _controller.dataOverrides,
                            onAction: (node, action, data) {
                              final eventMsg =
                                  '[${node.type}:${node.id}] -> $action: $data';
                              debugPrint('[Schema Event] $eventMsg');

                              setState(() {
                                _eventLog.insert(
                                    0,
                                    '${DateTime.now().toString().split(' ').last.split('.').first} | $eventMsg');
                                if (_eventLog.length > 5) _eventLog.removeLast();
                              });

                              if (node.type == 'counter') {
                                final current = data is Map
                                    ? (data['current'] as int? ?? 0)
                                    : 0;
                                if (action == 'increment') {
                                  _controller.updateNodeData(
                                      node.id, {'count': current + 1});
                                } else if (action == 'decrement') {
                                  _controller.updateNodeData(
                                      node.id, {'count': current - 1});
                                } else if (action == 'reset_to_zero') {
                                  _controller.updateNodeData(node.id, {'count': 0});
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a panel that simulates app interactions that update the layout.
  Widget _buildAppLogicPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings_suggest, color: Colors.blueGrey.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'App Logic Simulation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _controller.reset,
                icon: const Icon(Icons.restore, size: 16),
                label: const Text('Clear Overrides'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Section 1: Overrides (Global Reactivity)
          const Text(
            '1. REACTIVITY BY OVERRIDES (GLOBAL STATE)',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip(
                label: 'VIP Greeting',
                icon: Icons.person,
                onPressed: () {
                  _controller.updateNodeData('user_greeting', {
                    'content': 'Hello, Premium Member! Special for you:',
                    'color': '#FFD700',
                  });
                },
              ),
              _buildActionChip(
                label: 'Flash Sale',
                icon: Icons.flash_on,
                onPressed: () {
                  _controller.updateNodeData('btn_cart', {
                    'text': 'BUY NOW (50% OFF)',
                    'backgroundColor': '#FF5252',
                  });
                },
              ),
              _buildActionChip(
                label: 'Change Colors',
                icon: Icons.palette,
                onPressed: () {
                  _controller.updateNodeData('welcome_text', {
                    'color': '#FF9C27B0',
                  });
                  _controller.updateNodeData('banner_home', {
                    'height': 120.0,
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section 2: Triggers (Granular Reactivity)
          const Text(
            '2. REACTIVITY BY TRIGGERS (GRANULAR EVENTS)',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip(
                label: 'Update Prod A (ID)',
                icon: Icons.update,
                onPressed: () {
                  debugPrint('[Simulation] Trigger: Update Prod A (ID)');
                  SchemaComponentController.dispatchUpdate(
                    SchemaUpdateEvent.byId('dynamic_prod_a'),
                  );
                },
              ),
              _buildActionChip(
                label: 'Update All Cards (Type)',
                icon: Icons.auto_awesome_motion,
                onPressed: () {
                  debugPrint('[Simulation] Trigger: Update All Cards (Type)');
                  SchemaComponentController.dispatchUpdate(
                    SchemaUpdateEvent.byType('dynamic_product_card'),
                  );
                },
              ),
              _buildActionChip(
                label: 'Update Buttons (Type)',
                icon: Icons.smart_button,
                onPressed: () {
                  debugPrint('[Simulation] Trigger: Update Buttons (Type)');
                  SchemaComponentController.dispatchUpdate(
                    SchemaUpdateEvent.byType('button'),
                  );
                },
              ),
              _buildActionChip(
                label: 'Global Refresh',
                icon: Icons.public,
                onPressed: () {
                  debugPrint('[Simulation] Trigger: Global Refresh');
                  SchemaComponentController.dispatchUpdate(
                    SchemaUpdateEvent.all(),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section 3: Bidirectional Communication
          const Text(
            '3. BIDIRECTIONAL COMMUNICATION (ACTIONS & EVENTS)',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip(
                label: 'Get Input Value',
                icon: Icons.input,
                onPressed: () async {
                  debugPrint('[Simulation] Action: Get Input Value');
                  final value = await SchemaComponentController.dispatchAction<
                      String>('demo_input', 'get_value');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Input Value: "$value"')),
                    );
                  }
                },
              ),
              _buildActionChip(
                label: 'Clear Input',
                icon: Icons.clear_all,
                onPressed: () {
                  debugPrint('[Simulation] Action: Clear Input');
                  SchemaComponentController.dispatchAction(
                      'demo_input', 'clear');
                },
              ),
              _buildActionChip(
                label: 'Get Card Title',
                icon: Icons.card_membership,
                onPressed: () async {
                  debugPrint('[Simulation] Action: Get Card Title');
                  final title = await SchemaComponentController.dispatchAction<
                      String>('card_welcome', 'get_title');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Card Title: "$title"')),
                    );
                  }
                },
              ),
              _buildActionChip(
                label: 'Reset Counters (Batch)',
                icon: Icons.restart_alt,
                onPressed: () {
                  debugPrint('[Simulation] Action: Reset Counters (Batch)');
                  SchemaComponentController.dispatchAction('', 'reset',
                      targetComponentType: 'counter');
                },
              ),
            ],
          ),

          if (_eventLog.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Latest Schema Events:',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ..._eventLog.map((log) => Text(log,
                      style: const TextStyle(
                          fontSize: 9, fontFamily: 'monospace'))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onPressed,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blueGrey.shade200),
    );
  }
}
