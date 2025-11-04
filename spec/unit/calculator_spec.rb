# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PocketKnife::Calculator do
  describe '.calculate' do
    context 'with valid integer inputs' do
      it 'calculates percentage correctly' do
        request = PocketKnife::CalculationRequest.new(percentage: 20, base: 100)
        result = described_class.calculate(request)

        expect(result.value).to eq(20.0)
        expect(result.formatted_value).to eq('20.00')
      end

      it 'calculates 15% of 200' do
        request = PocketKnife::CalculationRequest.new(percentage: 15, base: 200)
        result = described_class.calculate(request)

        expect(result.value).to eq(30.0)
        expect(result.formatted_value).to eq('30.00')
      end

      it 'calculates 100% of 100' do
        request = PocketKnife::CalculationRequest.new(percentage: 100, base: 100)
        result = described_class.calculate(request)

        expect(result.value).to eq(100.0)
        expect(result.formatted_value).to eq('100.00')
      end
    end

    context 'with decimal base inputs' do
      it 'calculates percentage of decimal number' do
        request = PocketKnife::CalculationRequest.new(percentage: 10, base: 99.99)
        result = described_class.calculate(request)

        expect(result.value).to be_within(0.0001).of(9.999)
        expect(result.formatted_value).to eq('10.00')
      end

      it 'calculates 20% of 45.50' do
        request = PocketKnife::CalculationRequest.new(percentage: 20, base: 45.50)
        result = described_class.calculate(request)

        expect(result.value).to eq(9.1)
        expect(result.formatted_value).to eq('9.10')
      end
    end

    context 'with zero values' do
      it 'handles zero percentage' do
        request = PocketKnife::CalculationRequest.new(percentage: 0, base: 100)
        result = described_class.calculate(request)

        expect(result.value).to eq(0.0)
        expect(result.formatted_value).to eq('0.00')
      end

      it 'handles zero base' do
        request = PocketKnife::CalculationRequest.new(percentage: 50, base: 0)
        result = described_class.calculate(request)

        expect(result.value).to eq(0.0)
        expect(result.formatted_value).to eq('0.00')
      end

      it 'handles both zero' do
        request = PocketKnife::CalculationRequest.new(percentage: 0, base: 0)
        result = described_class.calculate(request)

        expect(result.value).to eq(0.0)
        expect(result.formatted_value).to eq('0.00')
      end
    end

    context 'with large numbers' do
      it 'calculates percentage of large numbers' do
        request = PocketKnife::CalculationRequest.new(percentage: 15, base: 1_000_000)
        result = described_class.calculate(request)

        expect(result.value).to eq(150_000.0)
        expect(result.formatted_value).to eq('150000.00')
      end

      it 'calculates small percentage of large number' do
        request = PocketKnife::CalculationRequest.new(percentage: 1, base: 999_999)
        result = described_class.calculate(request)

        expect(result.value).to be_within(0.01).of(9999.99)
        expect(result.formatted_value).to eq('9999.99')
      end
    end

    context 'with invalid request' do
      it 'raises CalculationError for invalid request' do
        request = PocketKnife::CalculationRequest.new(percentage: -5, base: 100)

        expect { described_class.calculate(request) }
          .to raise_error(PocketKnife::CalculationError, 'Invalid request')
      end

      it 'raises CalculationError for infinite base' do
        request = PocketKnife::CalculationRequest.new(percentage: 10, base: Float::INFINITY)

        expect { described_class.calculate(request) }
          .to raise_error(PocketKnife::CalculationError)
      end

      it 'raises CalculationError for NaN base' do
        request = PocketKnife::CalculationRequest.new(percentage: 10, base: Float::NAN)

        expect { described_class.calculate(request) }
          .to raise_error(PocketKnife::CalculationError)
      end
    end

    context 'return type validation' do
      it 'returns a CalculationResult instance' do
        request = PocketKnife::CalculationRequest.new(percentage: 15, base: 200)
        result = described_class.calculate(request)

        expect(result).to be_a(PocketKnife::CalculationResult)
      end

      it 'result contains the original request' do
        request = PocketKnife::CalculationRequest.new(percentage: 15, base: 200)
        result = described_class.calculate(request)

        expect(result.request).to eq(request)
      end

      it 'result has correctly formatted value' do
        request = PocketKnife::CalculationRequest.new(percentage: 15, base: 200)
        result = described_class.calculate(request)

        expect(result.formatted_value).to match(/^\d+\.\d{2}$/)
      end
    end
  end
end
