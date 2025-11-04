# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PocketKnife::CalculationResult do
  let(:request) { PocketKnife::CalculationRequest.new(percentage: 15, base: 200.0) }

  describe '#initialize' do
    it 'creates a result with value and request' do
      result = described_class.new(value: 30.0, request: request)

      expect(result.value).to eq(30.0)
      expect(result.request).to eq(request)
    end

    it 'automatically formats the value' do
      result = described_class.new(value: 30.0, request: request)

      expect(result.formatted_value).to eq('30.00')
    end
  end

  describe '#formatted_value' do
    it 'formats whole numbers with 2 decimal places' do
      result = described_class.new(value: 30.0, request: request)

      expect(result.formatted_value).to eq('30.00')
    end

    it 'formats zero with 2 decimal places' do
      result = described_class.new(value: 0.0, request: request)

      expect(result.formatted_value).to eq('0.00')
    end

    it 'formats numbers with 1 decimal place to 2 decimal places' do
      result = described_class.new(value: 30.5, request: request)

      expect(result.formatted_value).to eq('30.50')
    end

    it 'rounds numbers with more than 2 decimal places' do
      result = described_class.new(value: 30.123456, request: request)

      expect(result.formatted_value).to eq('30.12')
    end

    it 'rounds up when appropriate' do
      result = described_class.new(value: 30.999, request: request)

      expect(result.formatted_value).to eq('31.00')
    end

    it 'formats negative numbers correctly' do
      result = described_class.new(value: -20.0, request: request)

      expect(result.formatted_value).to eq('-20.00')
    end

    it 'formats large numbers correctly' do
      result = described_class.new(value: 150_000.0, request: request)

      expect(result.formatted_value).to eq('150000.00')
    end
  end

  describe '#to_s' do
    it 'returns the formatted_value' do
      result = described_class.new(value: 30.0, request: request)

      expect(result.to_s).to eq('30.00')
      expect(result.to_s).to eq(result.formatted_value)
    end
  end
end
