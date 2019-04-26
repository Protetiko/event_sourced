$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'event_sourced'

require 'minitest/autorun'
require 'minitest/hell' # Enables parallel (multithreaded) execution for all tests.
require 'minitest/reporters'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true, slow_count:  5)]

require 'examples/inventory_item'
#Dir[File.join(__dir__, 'examples', '*')].each { |file| require file }

class MiniTest::Test
  extend MiniTest::Spec::DSL
end
