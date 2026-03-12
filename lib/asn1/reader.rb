# frozen_string_literal: true

module Asn1
  class Reader
    attr_reader :tag, :length
    private attr_accessor :bytes, :cursor, :header_length

    def initialize(bytes)
      @bytes = bytes
      @cursor = 0
      @header_length = 0
    end

    def eoc?
      @cursor == total_length
    end

    def total_length
      @header_length + @length
    end

    def read_sequence
      read_next_object
    end

    def read_object_identifier
      object_identifier = read_next_object

      sub_identifiers = []
      sub_identifier = 0

      object_identifier.enumerate_content_bytes.each_with_index do |byte, index|
        if index == 0
          sub_identifiers << (byte / 40)
          sub_identifiers << (byte % 40)
          next
        end

        sub_identifier = (sub_identifier << 7) | (byte & 0x7F)

        is_end_of_sub_identifier = byte & 0x80
        if is_end_of_sub_identifier == 0
          sub_identifiers << sub_identifier
          sub_identifier = 0
        end
      end

      sub_identifiers.join('.')
    end

    def read_header
      @tag = read_byte
      @length = read_length
      @header_length = @cursor
    end

    def enumerate_content_bytes
      Enumerator.new do |y|
        until eoc?
          y << read_byte
        end
      end
    end

    private

    def read_byte
      byte = @bytes.getbyte(@cursor)
      @cursor += 1
      byte
    end

    def read_next_object
      reader = self.class.new(@bytes[@cursor..])
      reader.read_header
      skip_parsed_bytes(reader)

      reader
    end

    def skip_parsed_bytes(parsed_reader)
      @cursor += parsed_reader.total_length
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
