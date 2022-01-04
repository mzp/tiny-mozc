# frozen_string_literal: true

require 'test_helper'

module TestTiny
  module Dictionary
    class TestLattice < Minitest::Test
      def setup
        @lattice = Tiny::Mozc::Converter::Lattice.new('はいしゃ')
        @lattice.insert 0, node('はいしゃ', '歯医者')
        @lattice.insert 0, node('は', '歯')
        @lattice.insert 1, node('いしゃ', '医者')
        @lattice.insert 0, node('は', '葉')
        @lattice.insert 1, node('い', '胃')
        @lattice.insert 2, node('しゃ', '車')
      end

      def test_begin_nodes
        assert_equal %w[は 葉 歯 歯医者], @lattice.begin_nodes(0).map(&:value)
        assert_equal %w[い 胃 医者], @lattice.begin_nodes(1).map(&:value)
        assert_equal %w[し 車], @lattice.begin_nodes(2).map(&:value)
        assert_equal %w[ゃ], @lattice.begin_nodes(3).map(&:value)
      end

      def test_end_nodes
        assert_equal %w[は 葉 歯], @lattice.end_nodes(1).map(&:value)
        assert_equal %w[い 胃], @lattice.end_nodes(2).map(&:value)
        assert_equal %w[し], @lattice.end_nodes(3).map(&:value)
        assert_equal %w[ゃ 車 医者 歯医者], @lattice.end_nodes(4).map(&:value)
      end

      def test_unknown_node
        assert_operator @lattice.begin_nodes(0).first.wcost, :>, 1000
        assert_operator @lattice.end_nodes(1).first.wcost, :>, 1000
      end

      def test_boundary
        assert_equal [@lattice.bos], @lattice.end_nodes(0)

        position = @lattice.key.size
        assert_equal [@lattice.eos], @lattice.begin_nodes(position)
      end

      def test_bos
        bos = @lattice.bos
        assert_nil bos.key
        assert_equal 'BOS', bos.value
        assert_equal 0, bos.wcost
        assert_equal 0, bos.cost
        assert_equal 0, bos.rid
      end

      def test_eos
        eos = @lattice.eos
        assert_nil eos.key
        assert_equal 'EOS', eos.value
        assert_equal 0, eos.wcost
        assert_equal 0, eos.cost
        assert_equal 0, eos.lid
      end

      private

      def node(key, value)
        { key: key, value: value, cost: 1, lid: 2, rid: 3 }
      end
    end
  end
end
