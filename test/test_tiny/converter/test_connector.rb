# frozen_string_literal: true

require 'test_helper'

module TestTiny
  module Dictionary
    class TestConverter < Minitest::Test
      def setup
        path = "#{File.dirname(__FILE__)}/connection.deflate"
        @connector = Tiny::Mozc::Converter::Connector.new(path)
      end

      def test_sanity
        assert File.exist?(@connector.path)
      end

      def test_get_cost
        # snip from mozc
        cost = @connector.get_cost(1919, 1918)
        assert_equal 415, cost
      end
    end
  end
end
