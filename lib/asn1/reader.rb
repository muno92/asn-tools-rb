# frozen_string_literal: true

module Asn1
  class Reader
    attr_reader :tag, :length

    def initialize(bytes)
      @bytes = bytes
      @cursor = 0
    end

    def read_sequence
      read_next_object
    end

    def read_header
      @tag = read_byte
      @length = read_length
    end

    private

    attr_accessor :cursor

    def read_byte
      byte = @bytes.getbyte(@cursor)
      @cursor += 1
      byte
    end

    def read_next_object
      reader = self.class.new(@bytes[@cursor..])
      reader.read_header

      reader
    end

    def read_length
      first_length_byte = read_byte

      return first_length_byte if length_is_short_form(first_length_byte)

      length_bytes_count = first_length_byte & 0x7F
      length = 0
      length_bytes_count.times do
        length = (length << 8) | read_byte
      end

      length
    end

    def length_is_short_form(first_length_byte)
      first_length_byte & 0x80 == 0
    end
  end
end
