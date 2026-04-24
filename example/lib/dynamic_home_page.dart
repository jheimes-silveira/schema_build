import 'package:flutter/material.dart';
import 'package:schema_build/schema_build.dart';
import 'components/device_frame.dart';

class DynamicHomePage extends StatefulWidget {
  const DynamicHomePage({super.key});

  @override
  State<DynamicHomePage> createState() => _DynamicHomePageState();
}

class _DynamicHomePageState extends State<DynamicHomePage> {
  final SchemaRepository _repository = SchemaRepository();
  late Future<Map<String, dynamic>> _layoutFuture;

  @override
  void initState() {
    super.initState();
    _layoutFuture = _repository.getRemoteLayout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produção (SDUI)'),
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

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum layout disponível.'));
          }

          // Converte o JSON recebido do repositório em uma árvore de nós
          final rootNode = WidgetNode.fromJson(snapshot.data!);

          return Container(
            color: const Color(0xFFF5F5F5),
            child: DeviceFrame(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SchemaWidget(
                  node: rootNode,
                  dataOverrides: const {
                    // Aqui injetamos dados dinâmicos do app real
                    'user_greeting': {
                      'content': 'Olá, Cliente! Boas compras.',
                      'color': '#FF2196F3'
                    },
                    // Podemos até mudar cores ou propriedades de tipos inteiros
                    'button': {
                      'borderRadius': 20.0,
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
