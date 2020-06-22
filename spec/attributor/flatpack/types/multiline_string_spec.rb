# frozen_string_literal: true

require 'spec_helper'

describe Attributor::Flatpack::MultilineString do
  subject(:type) { Attributor::Flatpack::MultilineString }

  context '.example' do
    it 'should return a valid String' do
      expect(type.example).to be_a(::String)
    end
  end

  context '.load' do
    let(:value) { nil }

    it 'returns nil for nil' do
      expect(type.load(nil)).to be(nil)
    end

    context 'for incoming String values' do
      it 'should not modify multiline strings with newlines' do
        value = "-----BEGIN EC PRIVATE KEY-----\nMIHcAgEBBEI\n3abcdefghijklmnop==\n-----END EC PRIVATE KEY-----"
        expected_value = "-----BEGIN EC PRIVATE KEY-----\nMIHcAgEBBEI\n3abcdefghijklmnop==\n-----END EC PRIVATE KEY-----"
        expect(type.load(value)).to eq(expected_value)
      end

      it 'should modify multiline strings with escaped newlines' do
        value = '-----BEGIN EC PRIVATE KEY-----\\nMIHcAgEBBEI\\n3abcdefghijklmnop==\\n-----END EC PRIVATE KEY-----'
        expected_value = "-----BEGIN EC PRIVATE KEY-----\nMIHcAgEBBEI\n3abcdefghijklmnop==\n-----END EC PRIVATE KEY-----"
        expect(type.load(value)).to eq(expected_value)
      end
    end

    context 'for values that cannot be handled as a string' do
      let(:value) { [1] }

      it 'raises standarderror' do
        expect do
          type.load(value)
        end.to raise_error(StandardError)
      end
    end
  end
end
