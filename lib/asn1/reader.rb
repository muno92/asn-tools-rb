# frozen_string_literal: true

module Asn1
  class Reader
    def initialize(bytes)
      @bytes = bytes
    end

    def read_sequence
      Reader.new(@bytes)
    end
  end
end
