# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'tiny/mozc'

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!

def assert_count(expected, actual)
  assert_equal expected, actual.size, "Expect #{expected} elements, but actual is #{actual.size} (#{actual.inspect})"
end
