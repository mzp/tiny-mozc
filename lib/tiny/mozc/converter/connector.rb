# frozen_string_literal: true

require 'zlib'

module Tiny
  module Mozc
    module Converter
      # 品詞間の接続コストを取得する。
      #
      # 品詞IDx品詞IDの行列で表現されている。
      #
      # ## フォーマット
      #
      #  一行目は品詞の個数、それ以降は行列を左から順に書き下したものになる。
      #
      # ```
      # 2652
      # 0
      # 5765
      # 4872
      # 4805
      # 5607
      # ...
      # ```
      #
      # これは2652 x 2652の正方行列で以下の行列を表す。
      #
      # ```
      # matrix[0][0] = 0
      # matrix[0][1] = 5765
      # matrix[0][2] = 4872
      # matrix[0][3] = 4805
      # matrix[0][4] = 5607
      # ...
      # ```
      #
      # ### Mozcにおける実装
      #
      #  - zlibで圧縮されたのち、Engine data(`mozc.dat`)に格納される。
      #  - 一度計算したコストは、その変換処理中はキャッシュする。(重い処理なのか？)
      #
      # ## 関連リンク
      #
      #  - [Mozcの辞書を使ってMeCabでかな漢字変換する](https://qiita.com/yukinoi/items/14a07958727bef5f8e9c)
      #
      class Connector
        attr_reader :size, :data, :path

        def initialize(path)
          @path = path
          @size, *@data = Zlib::Inflate.inflate(File.read(path)).split("\n").map(&:to_i)
        end

        def get_cost(rid, lid)
          data[(rid * size) + lid]
        end
      end
    end
  end
end
