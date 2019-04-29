require 'test_helper.rb'

class ItemBase
  Factory = Class.new(EventSourced::Factory)

  def self.inherited(base)
    Factory.register(base.name, base)
  end

  def initialize(data); end
end

class Item1 < ItemBase; end
class Item2 < ItemBase; end
class Item3 < ItemBase; end
class Item4 < ItemBase; end

class FactoryTest < MiniTest::Test
  def test_correctness_of_factory_registry
    registry = ItemBase::Factory.registry

    refute_empty registry
    assert_equal 4, registry.size
    assert_equal Item1, registry['Item1']
    assert_equal Item2, registry['Item2']
    assert_equal Item3, registry['Item3']
    assert_equal Item4, registry['Item4']
  end

  def test_raises_exception_when_not_found
    assert_raises EventSourced::Factory::UndefinedFactoryTemplate do
      ItemBase::Factory.for!('UnknownItem')
    end

    assert_raises EventSourced::Factory::UndefinedFactoryTemplate do
      ItemBase::Factory.build!('UnknownItem', {})
    end
  end

  def test_returns_nil_when_not_found
    assert_nil ItemBase::Factory.for('UnknownItem')
    assert_nil ItemBase::Factory.build('UnknownItem', {})
  end

  def test_it_returns_expected_object_class
    assert_equal Item1, ItemBase::Factory.for('Item1')
    assert_equal Item2, ItemBase::Factory.for('Item2')
    assert_equal Item3, ItemBase::Factory.for('Item3')
    assert_equal Item4, ItemBase::Factory.for('Item4')
  end

  def test_it_returns_instance_of_class
    assert_instance_of Item1, ItemBase::Factory.build('Item1')
    assert_instance_of Item2, ItemBase::Factory.build('Item2', {})
    assert_instance_of Item3, ItemBase::Factory.build('Item3', { field: 'string' })
    assert_instance_of Item4, ItemBase::Factory.build('Item4')
  end
end
