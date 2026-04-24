# Schema Build

[![pub package](https://img.shields.io/pub/v/schema_build.svg)](https://pub.dev/packages/schema_build)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Schema Build** is a professional **Server-Driven UI (SDUI)** engine and visual builder for Flutter. It enables you to create dynamic, extensible, and real-time updatable interfaces via JSON, without the need for new store deployments.

---

## 🎯 Objective

The primary goal of **Schema Build** is to decouple the UI structure from the application binary. By allowing layouts and component data to be managed externally, teams can:
- **Iterate faster**: Update UI layouts and business logic on the fly.
- **A/B Test**: Deploy different variations of screens to segments of users without app updates.
- **Unified Design**: Centralize component definitions and ensure consistency across platforms.
- **Low Payload**: Optimize bandwidth by sending only the necessary widget tree structure.

---

## 🚀 Key Features

- **Drag-and-Drop Visual Editor**: Intuitive interface to build layouts by dragging components.
- **Native SDUI Architecture**: Render complete interfaces from JSON schemas coming from your backend.
- **Extensible Registry System**: Easily add your own design system components.
- **Push-Based Reactive State**: Inversion of control where the Host or the component itself injects states via `dispatchData`.
- **Async Lifecycle**: Single initialization via `onInit` for setup and listener registration.
- **Logical Observation (Zero-Rebuild)**: Notify external events (Analytics, Logs) via `updateExternalState` without triggering unnecessary UI rebuilds.

---

## 📦 Initialization

First, register the component schemas your app will use:

```dart
void main() {
  // Register your custom business components
  Schemas.load(MyCustomAppSchema());

  runApp(const MyApp());
}
```

---

## 🛠️ Reactive State Architecture

The system uses a **Push-Based** model. Instead of the component "pulling" data continuously, it is initialized once and listens for state updates injected via events.

### 1. Initialization: `onInit`
The `onInit` method is the single entry point for the component lifecycle. It is called only once when the component enters the tree.
```dart
@override
Future<void> onInit(context, node) async {
  // 1. Fetch initial data
  final data = await Api.fetch(node.id);
  // 2. Inject into UI
  SchemaComponentController.dispatchDataById(node.id, data);
}
```

### 2. Data Injection (UI): `dispatchData`
Use these methods to update the interface of one or more components. This triggers the internal `setState` of the controller.
- `dispatchDataById(id, data)`: Specific target.
- `dispatchDataByType(type, data)`: Bulk update by type.

### 3. Logical Notification: `updateExternalState`
Ideal for events the external world needs to know, but should not rebuild the local component (e.g., Analytics, Logs, Notifications).
```dart
// Inside builder:
onTap: () {
  SchemaComponentController.updateExternalState(node.id, node.type, {'action': 'click'});
}
```

### 4. Observers (Logic Listeners)
The App Host can subscribe to these events without rebuilding the UI tree:
```dart
SchemaComponentController.onObserveDataByType('button', (data) {
  print('Analytics: Button clicked -> $data');
});
```

> [!TIP]
> `SchemaComponentController` has internal redundancy control. If you call `dispatchData` with data identical to the previous one, the `builder` will **not** be rebuilt, saving performance.

---

## 📱 Rendering Dynamic Layouts

The schema JSON is focused on hierarchy:

```json
{
  "id": "home_page_root",
  "type": "business_column",
  "children": [
    {
      "id": "hero_banner_1",
      "type": "action_card"
    },
    {
      "id": "featured_product_42",
      "type": "dynamic_product_card"
    }
  ]
}
```

To render, use the `SchemaWidget`:

```dart
class DynamicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchLayoutFromServer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final rootNode = WidgetNode.fromJson(snapshot.data!);
        return SchemaWidget(node: rootNode);
      },
    );
  }
}
```

---

## 📚 Technical Reference Table

| Item | Type | Description | Scope/Function |
| :--- | :--- | :--- | :--- |
| `onInit` | Hook | Lifecycle | Called once upon component creation for setup. |
| `dispatchData` | Static | Push UI | Injects data into the `builder` and triggers rebuild. |
| `updateExternalState` | Static | Logical Event | Notifies external observers without UI rebuild. |
| `onObserveData` | Static | Listener | Allows App Host to listen to component logical events. |
| `State Cache` | Internal | Persistence | Keeps component state even if it leaves the tree temporarily. |
| `WidgetNode` | Class | Data Model | Defines structure and hierarchy (ID, Type, Children). |
| `dispatchAction` | Static | Action (Inbound) | Sends command to a component and awaits async response. |

---

## 🇧🇷 Português (Resumo)

**Schema Build** é um motor de Server-Driven UI e editor visual para Flutter. Ele permite criar layouts dinâmicos via JSON com um sistema de estado reativo baseado em **Push**.

- **Editor Visual**: Arraste e solte componentes para criar schemas.
- **Performance**: Atualizações granulares e controle de redundância (Zero-Rebuild).
- **Extensível**: Registre seus próprios componentes de negócio facilmente.

---

Developed by **Jheime Silveira**
