# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PocketKnife::CalculationRequest do
  describe '#initialize' do
    it 'creates a request with percentage, base, and operation' do
      request = described_class.new(percentage: 15, base: 200.0)

      expect(request.percentage).to eq(15)
      expect(request.base).to eq(200.0)
      expect(request.operation).to eq(:percent_of)
    end

    it 'allows custom operation parameter' do
      request = described_class.new(percentage: 10, base: 50.0, operation: :custom)

      expect(request.operation).to eq(:custom)
    end
  end

  describe '#valid?' do
    context 'with valid inputs' do
      it 'returns true for valid integer percentage and numeric base' do
        request = described_class.new(percentage: 15, base: 200.0)

        expect(request.valid?).to be true
      end

      it 'returns true for zero percentage' do
        request = described_class.new(percentage: 0, base: 100.0)

        expect(request.valid?).to be true
      end

      it 'returns true for zero base' do
        request = described_class.new(percentage: 50, base: 0.0)

        expect(request.valid?).to be true
      end

      it 'returns true for integer base' do
        request = described_class.new(percentage: 10, base: 100)

        expect(request.valid?).to be true
      end
    end

    context 'with invalid inputs' do
      it 'returns false for negative percentage' do
        request = described_class.new(percentage: -5, base: 100.0)

        expect(request.valid?).to be false
      end

      it 'returns false for non-integer percentage (float)' do
        request = described_class.new(percentage: 15.5, base: 100.0)

        expect(request.valid?).to be false
      end

      it 'returns false for non-integer percentage (string)' do
        request = described_class.new(percentage: '15', base: 100.0)

        expect(request.valid?).to be false
      end

      it 'returns false for infinite base' do
        request = described_class.new(percentage: 15, base: Float::INFINITY)

        expect(request.valid?).to be false
      end

      it 'returns false for NaN base' do
        request = described_class.new(percentage: 15, base: Float::NAN)

        expect(request.valid?).to be false
      end

      it 'returns false for non-numeric base' do
        request = described_class.new(percentage: 15, base: '100')

        expect(request.valid?).to be false
      end
    end
  end
end
