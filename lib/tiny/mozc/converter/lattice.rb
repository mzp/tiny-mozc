# frozen_string_literal: true

module Tiny
  module Mozc
    module Converter
      # 入力文書に対するすべての変換候補を保持するクラス。
      #
      # 日本語変換は、BOS(begin of sentence)とEOS(end of sentence)をつなぐ経路のうち、
      # 単語の出現コストと品詞の接続コストが最も低いものを見つける作業なので、
      # そのために必要な情報を保持する。
      #
      # ## ノードの構造
      #
      # 各ノードは入力文字列(`key`)の部分文字列に対応する。
      #
      # 各ノードは品詞情報をもつ。
      #
      #  - `key`: 入力文字列(読み)
      #  - `value`: 変換後の文字列
      #  - `lid`: 左接続ID
      #  - `rid`: 右接続ID
      #
      # 関連するノードへのポインタを持つので、複数のリストを合成したような構造になっている。
      #
      #  - `bnext`: 開始位置を共有する次のノード
      #  - `enext`: 終了位置を共有する次のノード
      #  - `prev`, `next`: 最小コストで移動できる前後のノード
      #
      # Mozcの `node.h` のコメントから構造を表した図を引用する。
      #
      # ```
      # key:         | 0 | 1 | 2 | 3 | 4 | 5 | 6 | ... | N |
      # begin_nodes: | 0 | 1 | 2 | 3 | 4 | 5 | 6 | ... | N | (in lattice)
      #               |   |   :   :   :   :   :         :
      #               |   :
      #               |   :          (nullptr)
      #               |   :           ^
      #               |   :           :
      #               v   :           |
      #              +-----------------+
      #              | Node1(len4)     |
      #              +-----------------+
      #          bnext|   :           ^
      #               v   :           |enext
      #              +-----------------+
      #              | Node2(len4)     | (nullptr)
      #              +-----------------+  ^
      #          bnext|   :           ^   :
      #               |   :           |   :
      #               v   :           :   |enext
      #              +---------------------+
      #              | Node3(len5)         |
      #              +---------------------+ (nullptr)
      #          bnext|   :           :   ^   ^
      #               |   :           :   |   :
      #               v   :           :   :   |enext
      #              +-------------------------+
      #              | Node4(len6)             |
      #              +-------------------------+
      #          bnext|   :           :   :   ^
      #               :   :           :   :   |
      #               v   :           :   :   :
      #         (nullptr) |           :   :   :
      #                   v           :   |enext
      #                  +-----------------+  :
      #                  | Node5(len4)     |  :
      #                  +-----------------+  :
      #              bnext|           :   ^   :
      #                   v           :   |enext
      #                  +-----------------+  :
      #                  | Node6(len4)     |  :
      #                  +-----------------+  :
      #              bnext|           :   ^   :
      #                   |           :   |   :
      #                   v           :   :   |enext
      #                  +---------------------+
      #                  | Node7(len5)         |
      #                  +---------------------+
      #              bnext|           :   :   ^
      #                   v           :   :   |enext
      #                  +---------------------+
      #                  | Node8(len5)         |
      #                  +---------------------+
      #              bnext|           :   :   ^
      #                   :           :   :   |
      #                   v           :   :   |
      #              (nullptr)        :   :   |
      #                               :   :   |
      #               :   :   :   :   :   |   |         :
      # end_nodes:   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | ... | N |  (in lattice)
      # ```
      #
      # 処理を簡単にするために幾つかの番兵をもつ。
      #
      #  - 文の先頭・末尾: BOS, EOSという単一のノード
      #  - 各入力文字: コストが非常に大きくて長さが1のノード。keyとvalueが同一なので無変換に対応する。
      #
      # 半順序集合で構築される束(lattice)とは関係ないはず。
      #
      # ## Mozcにおける実装
      #
      #  - `std::string` をそのまま用いているので、`key`が日本語の場合 `begin_nodes` / `end_nodes` は歯抜けになる。
      #  - 一度作ったLatticeは解放せず、フィールドをクリアして再利用する。
      #
      class Lattice
        Node = Struct.new(:key, :value, :lid, :rid, :cost, :wcost, :bnext, :enext, :next, :prev, keyword_init: true) do
          def to_array(field)
            result = []
            node = self
            until node.nil?
              result << node
              node = node[field]
            end
            result
          end

          def insert(node, field)
            node[field] = self[field]
            self[field] = node
          end

          def invisible?
            key.nil?
          end
        end

        attr_reader :key, :bos, :eos

        def initialize(key)
          @key = key
          @bos = Node.new(key: nil, value: 'BOS', wcost: 0, cost: 0, lid: 0, rid: 0)
          @eos = Node.new(key: nil, value: 'EOS', wcost: 0, cost: 0, lid: 0, rid: 0)

          @begin_nodes = key.chars.map(&method(:unknown)) + [eos]
          @end_nodes = [bos] + @begin_nodes.dup
        end

        def insert(position, fields)
          node = Node.new(fields)
          @begin_nodes[position].insert node, :bnext
          @end_nodes[position + node.key.size].insert node, :enext
        end

        def begin_nodes(position)
          @begin_nodes[position].to_array(:bnext)
        end

        def end_nodes(position)
          @end_nodes[position].to_array(:enext)
        end

        def best_nodes
          bos.to_array(:next)
        end

        private

        UNKNOWN_COST = 32_767

        # サ変接の名詞( `id.def` 参照)
        UNKNOWN_ID = 1837

        def unknown(key)
          Node.new(key: key, value: key, wcost: UNKNOWN_COST, lid: UNKNOWN_ID, rid: UNKNOWN_ID)
        end
      end
    end
  end
end
