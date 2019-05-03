AGGREGATE_ID = 'InventoryItem@4f6n3o2c3m43n2cjr2'

BASE_COMMAND = {
  aggregate_id: AGGREGATE_ID,
  aggregate_type: 'InventoryItem',
  meta_data: {
    user_id: 'the-user-id',
  },
  version: 1,
}

CREATE_ITEM_COMMAND_MESSAGE = BASE_COMMAND.merge(
  type: 'create_inventory_item',
  data: {
    description: 'Fine wool blanket',
    count: 50,
    field_not_handled_by_service: 'this will not appear in commands or events'
  },
  correlation_id: 'the-correlation-id-1',
)

UPDATE_ITEM_COMMAND_MESSAGE = BASE_COMMAND.merge(
  type: 'update_inventory_item',
  data: {
    description: 'Very fine wool blanket',
  },
  correlation_id: 'the-correlation-id-2',
)

RESTOCK_ITEM_COMMAND_MESSAGE = BASE_COMMAND.merge(
  type: 'restock_inventory_item',
  data: {
    count: 200,
  },
  correlation_id: 'the-correlation-id-3',
)

WITHDRAW_ITEM_COMMAND_MESSAGE = BASE_COMMAND.merge(
  type: 'withdraw_inventory_item',
  data: {
    count: 2,
  },
  correlation_id: 'the-correlation-id-4',
)

INVENTORY_ITEM_CREATED = BASE_COMMAND.merge(
  command_id:     'd6da1b4b-9d7c-4b84-941f-1bbb595403a3',
  type:           'InventoryItemCreated',
  timestamp:      '2019-04-21T12:53:09+02:00',
  correlation_id: 'the-correlation-id',
  causation_id:   'd6da1b4b-9d7c-4b84-941f-1bbb595403a3',
  data: {
    description: 'Fine wool blanket'
  },
)
