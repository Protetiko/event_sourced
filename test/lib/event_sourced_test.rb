require 'test_helper'

class EventSourcedTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::EventSourced::VERSION
  end
end
