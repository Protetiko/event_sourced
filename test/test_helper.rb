$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'event_sourced'

require 'minitest/autorun'
require 'minitest/hell'     # Enables parallel (multithreaded) execution for all tests.
require 'minitest/proveit'  # Make parallel execution even more devilish
require 'minitest/reporters'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true, slow_count: 5)]

Mongo::Logger.logger.level = ENV['MONGO_DEBUG_LEVEL'] || Logger::ERROR

require 'examples/inventory_item'

class MiniTest::Test
  extend MiniTest::Spec::DSL
end

Dir[File.join(__dir__, 'test_helpers', '*')].each {|file| require file }
