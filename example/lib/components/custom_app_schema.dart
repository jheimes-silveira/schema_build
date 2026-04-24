import 'package:schema_build/schema_build.dart';
import 'action_card_component.dart';
import 'loading_button_component.dart';
import 'info_list_component.dart';
import 'stock_status_component.dart';

import 'dynamic_product_card_component.dart';
import 'input_component.dart';
import 'counter_component.dart';
import 'business_column_component.dart';

/// Um schema customizado para agrupar estes componentes.
class CustomAppSchema implements Schema {
  @override
  void components(SchemaManager schemaManager) {
    schemaManager.registerComponent(ActionCardComponent());
    schemaManager.registerComponent(LoadingButtonComponent());
    schemaManager.registerComponent(InfoListComponent());
    schemaManager.registerComponent(StockStatusComponent());
    schemaManager.registerComponent(DynamicProductCardComponent());
    schemaManager.registerComponent(InputComponent());
    schemaManager.registerComponent(CounterComponent());
    schemaManager.registerComponent(BusinessColumnComponent());
  }
}
