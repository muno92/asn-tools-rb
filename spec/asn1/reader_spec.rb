# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Asn1 do
  describe 'reader' do
    it 'should read sequence' do
      reader = Asn1::Reader.new File.read(fixture_path('pkcs7-signed-data.der'))
      expect(reader.read_sequence).not_to be nil
    end
  end
end
