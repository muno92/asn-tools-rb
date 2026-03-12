# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Asn1 do
  describe 'reader' do
    describe 'sequence' do
      before do
        reader = Asn1::Reader.new File.read(fixture_path('pkcs7-signed-data.der'))
        @sequence = reader.read_sequence
      end

      it 'should has tag' do
        expect(@sequence.tag).to eq(Asn1::Tag::UniversalTag::SEQUENCE)
      end

      it 'should has length' do
        expect(@sequence.length).to eq(3405)
      end
    end

    it 'should read object identifier' do
      reader = Asn1::Reader.new File.read(fixture_path('pkcs7-signed-data.der'))
      sequence = reader.read_sequence
      content_type = sequence.read_object_identifier
      expect(content_type).to eq('1.2.840.113549.1.7.2')
    end
  end
end
