BASE_COMMAND = {
  aggregate_id: 'InventoryItem@4f6n3o2c3m43n2cjr2',
  meta_data: {
    user_id: 'the-user-id',
  },
  version: 1,
}

AGGREGATE_ID = 'InventoryItem@4f6n3o2c3m43n2cjr2'

CREATE_ITEM_COMMAND_MESSAGE = {
  aggregate_id: AGGREGATE_ID,
  command_type: 'create_inventory_item',
  data: {
    description: 'Fine wool blanket',
    count: 50,
    field_not_handled_by_service: 'this will not appear in commands or events'
  },
  meta_data: {
    user_id: 'the-user-id',
  },
  correlation_id: 'the-correlation-id',
  version: 1,
}

UPDATE_ITEM_COMMAND_MESSAGE = {
  aggregate_id: AGGREGATE_ID,
  command_type: 'update_inventory_item',
  data: {
    description: 'Very fine wool blanket',
  },
  meta_data: {
    user_id: 'the-user-id',
  },
  correlation_id: 'the-correlation-id',
  version: 1,
}

RESTOCK_ITEM_COMMAND_MESSAGE = {
  aggregate_id: AGGREGATE_ID,
  command_type: 'restock_inventory_item',
  data: {
    count: 200,
  },
  meta_data: {
    user_id: 'the-user-id',
  },
  correlation_id: 'the-correlation-id-2',
  version: 1,
}

WITHDRAW_ITEM_COMMAND_MESSAGE = {
  aggregate_id: AGGREGATE_ID,
  command_type: 'withdraw_inventory_item',
  data: {
    count: 2,
  },
  meta_data: {
    user_id: 'the-user-id',
  },
  correlation_id: 'the-correlation-id-2',
  version: 1,
}
