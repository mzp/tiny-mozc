# frozen_string_literal: true

require_relative 'mozc/version'
require_relative 'mozc/dictionary/system_dictionary'
require_relative 'mozc/converter/connector'
require_relative 'mozc/converter/lattice'

module Tiny
  module Mozc
    class Error < StandardError; end
  end
end
