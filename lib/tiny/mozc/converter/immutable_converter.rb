# frozen_string_literal: true

module Tiny
  module Mozc
    module Converter
      # 入力文字列から変換後の文字列を得る。
      #
      # 変換処理はLatticeを用いて以下の手順で行われる。
      #
      #  1. 入力文字列(`key`)から空のLatticeを生成する
      #  2. 辞書から候補となる品詞を抽出する
      #  3. 各ノードへ到達する最小コストを計算する
      #  4. 各ノードのコストを用いて変換候補を生成する
      #
      # コストの計算はビタビ(Viterbi)アルゴリズムとA*アルゴリズムを併用する。
      #
      # ## TinyMozcでの制限
      #
      #  - 第一候補のみを検索するのでビタビアルゴリズムだけを使う。
      #
      class ImmutableConverter
        attr_reader :dictionary, :connector

        def initialize(dictionary, connector)
          @dictionary = dictionary
          @connector = connector
        end

        def convert(key)
          lattice = Lattice.new(key)
          lookup lattice
          update_cost_by_viterbi lattice

          top_candidate lattice
        end

        private

        def lookup(lattice)
          key = lattice.key
          (0...key.size).each do |position|
            lookup_key = key[position..]
            @dictionary.lookup_prefix(lookup_key).each do |entry|
              lattice.insert(position, entry.to_h.transform_keys(reading: :key, surface: :value, cost: :wcost))
            end
          end
        end

        # rubocop:disable Metrics/AbcSize,  Metrics/MethodLength, Metrics/CyclomaticComplexity
        def update_cost_by_viterbi(lattice)
          (0..lattice.key.size).each do |i|
            lattice.begin_nodes(i).each do |right_node|
              best_cost = -1
              best_node = nil

              lattice.end_nodes(i).each do |left_node|
                cost = left_node.cost + connector.get_cost(left_node.rid, right_node.lid)
                if best_cost.negative? || cost < best_cost
                  best_node = left_node
                  best_cost = cost
                end
              end
              right_node.prev = best_node
              right_node.cost = best_cost + right_node.wcost
            end
          end

          node = lattice.eos
          until node.nil?
            prev_node = node.prev
            prev_node&.next = node
            node = prev_node
          end
        end
        # rubocop:enable Metrics/AbcSize,  Metrics/MethodLength, Metrics/CyclomaticComplexity

        def top_candidate(lattice)
          lattice.best_nodes.delete_if(&:invisible?).map(&:value)
        end
      end
    end
  end
end
