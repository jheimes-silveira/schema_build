import 'package:flutter/material.dart';

/// Define o tipo de ação que pode ser executada.
enum ActionType {
  navigate,
  print,
  snackBar,
  unknown;

  static ActionType fromString(String? value) {
    return ActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActionType.unknown,
    );
  }
}

/// Gerenciador centralizado para executar ações disparadas pela UI dinâmica.
class ActionHandler {
  /// Executa uma ação baseada em um mapa de dados.
  /// 
  /// Exemplo de [actionData]:
  /// {
  ///   "type": "snack_bar",
  ///   "params": { "message": "Olá do JSON!" }
  /// }
  static void execute(BuildContext context, Map<String, dynamic>? actionData) {
    if (actionData == null) return;

    final type = ActionType.fromString(actionData['type'] as String?);
    final params = Map<String, dynamic>.from(actionData['params'] as Map? ?? {});

    switch (type) {
      case ActionType.navigate:
        final route = params['route'] as String?;
        if (route != null) {
          Navigator.of(context).pushNamed(route);
        }
        break;

      case ActionType.print:
        final message = params['message'] as String?;
        debugPrint('Action Print: $message');
        break;

      case ActionType.snackBar:
        final message = params['message'] as String?;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
        break;

      case ActionType.unknown:
        debugPrint('Ação desconhecida: ${actionData['type']}');
        break;
    }
  }
}
