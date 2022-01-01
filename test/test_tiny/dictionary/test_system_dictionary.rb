# frozen_string_literal: true

require 'test_helper'

module TestTiny
  module Dictionary
    class TestSystemDictionary < Minitest::Test
      def setup
        path = "#{File.dirname(__FILE__)}/dictionary.txt"
        @dictionary = Tiny::Mozc::Dictionary::SystemDictionary.new(path)
      end

      def test_sanity
        assert File.exist?(@dictionary.path)
      end

      def test_lookup_prefix
        # もんだいてん    1938    2121    3000    問題点
        entry = @dictionary.lookup_prefix('もんだいてんが').max_by { |x| x.surface.length }
        refute_nil entry

        assert_equal 'もんだいてん', entry.reading
        assert_equal 1938, entry.lid
        assert_equal 2121, entry.rid
        assert_equal 3000, entry.cost
        assert_equal '問題点', entry.surface
      end

      def test_lookup_prefix_multihit
        entries = @dictionary.lookup_prefix 'き'
        assert_count 32, entries
      end
    end
  end
end
