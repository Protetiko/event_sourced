# EventSourced.configure do |config|
#   config.aggregate_roots = Order
#   config.command_handlers = [OrderCommandHandler]
#   config.logger = Logger.new
# end

# 1. AR and Repo knows about ES
InventoryItem.configure do |config|
  config.event_store = EventSourced::EventStores::MemoryEventStore.new
end

InventoryItem.repository # InventoryItem::Repository.new(event_store)

#! CommandHandler needs to know about InventoryItem.repository and does not

# 2. Repository knows about ES

event_store = EventSourced::EventStores::MemoryEventStore.new
EventSourced[Order].repository = InventoryItem::Repository.new(event_store)
InventoryItemRepository = EventSourced[Order].repository
InventoryItem.repository # EventSourced[Order].repository


#? Should CommandHandler be AR agnostic?

# class InventoryCommandHandler < EventSourced::CommandHandler
#   on CreateInventoryItem do |command|
#     item = InventoryItem.create(command.aggregate_id)
#     item.apply InventoryItemCreated.new(command.to_h)
#     item.restock(command.count)
#     item.save
#   end
#
#   on RestockInventoryItem do |command|
#     item = InventoryItem.load(command.aggregate_id)
#     item.apply InventoryItemRestocked.new(command.to_h)
#     item.save
#   end
#
#   on WithdrawInventoryItem do |command|
#     InventoryItem.load_and_yield(command.aggregate_id) do |item|
#       item.apply InventoryItemRestocked.new(command.to_h)
#     end
#   end
