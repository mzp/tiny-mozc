# frozen_string_literal: true

module Tiny
  module Mozc
    module Dictionary
      # システムに同梱されている品詞辞書を検索する。
      #
      # ## 辞書のフォーマット
      #
      # 読み仮名、左文脈ID、右文脈ID、出現コスト、単語がタブ区切りで格納されている。
      #
      # mozcではそれぞれkey, lid, rid, wcost, valueと呼ぶ。
      #
      # 例:
      #
      # ```
      # うつくしいにほんご        2460    1847    4848    美しい日本語
      # ```
      #
      # ### Mozcにおける実装
      #
      #  - 辞書は `dictionary00.txt` から `dictionary09.txt` に分割されている。
      #  - 各IDがどの品詞に対応するかは `id.def` に定義されている。
      #  - そのまま格納するのではなくコンパイルされれた上で Engine data(`mozc.dat`)に格納される。
      #
      # ## tiny-mozcでの制約
      #
      #   - triesによる検索でなく線形検索を行う。
      #
      # ## 参考リンク
      #
      #   - [Mecab辞書のフォーマット](https://taku910.github.io/mecab/dic.html)
      #   - [IPADIC(IPA辞書)とはなにものか？](https://parame.mwj.jp/blog/0209)
      #
      class SystemDictionary
        Entry = Struct.new(:reading, :lid, :rid, :cost, :surface)

        attr_reader :path

        def initialize(path)
          @path = path
        end

        # 入力文字列(key) の先頭にくる可能性のある単語を抽出する。
        def lookup_prefix(key)
          File.open(path) do |io|
            io.flat_map do |line|
              reading, lid, rid, cost, surface = line.strip.split("\t")

              if key.start_with?(reading)
                Entry.new(reading, lid.to_i, rid.to_i, cost.to_i, surface)
              else
                []
              end
            end
          end
        end
      end
    end
  end
end
