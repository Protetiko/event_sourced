$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "event_sourced"

require "minitest/autorun"
require 'minitest/reporters'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true, slow_count:  5)]

class MiniTest::Test
  extend MiniTest::Spec::DSL
end
