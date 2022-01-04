# frozen_string_literal: true

require 'test_helper'

module TestTiny
  module Converter
    class MockDictionary
      def initialize
        @entries = [
          Tiny::Mozc::Dictionary::SystemDictionary::Entry.new('ろっぽんぎ', 1, 1, 10, '六本木'),
          Tiny::Mozc::Dictionary::SystemDictionary::Entry.new('ひるず', 2, 2, 10, 'ヒルズ'),
          Tiny::Mozc::Dictionary::SystemDictionary::Entry.new('ろっぽ', 3, 3, 20, '六本')
        ]
      end

      def lookup_prefix(key)
        @entries.filter { |entry| key.start_with?(entry.reading) }
      end
    end

    class MockConnector
      def get_cost(rid, lid)
        case [rid, lid]
        when [0, 1], [1, 2], [2, 0]
          0
        else
          100
        end
      end
    end

    class TestImmutableConverter < Minitest::Test
      def setup
        @dictionary = MockDictionary.new
        @connector = MockConnector.new
        @converter = Tiny::Mozc::Converter::ImmutableConverter.new(@dictionary, @connector)
      end

      def test_convert
        assert_equal %w[六本木], @converter.convert('ろっぽんぎ')
        assert_equal %w[六本木 ヒルズ], @converter.convert('ろっぽんぎひるず')
      end
    end
  end
end
