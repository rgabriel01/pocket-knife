# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/pocket_knife/percentage_calculator_tool'

RSpec.describe PocketKnife::PercentageCalculatorTool do
  let(:tool) { described_class.new }

  describe 'tool definition' do
    it 'inherits from RubyLLM::Tool' do
      expect(described_class.superclass).to eq(RubyLLM::Tool)
    end

    it 'has a description' do
      expect(described_class.description).to include('Calculate what percentage')
    end

    it 'defines base parameter' do
      params = described_class.parameters
      base_param = params[:base]
      expect(base_param).not_to be_nil
      expect(base_param.type).to eq('number')
      expect(base_param.description).to include('base amount')
    end

    it 'defines percentage parameter' do
      params = described_class.parameters
      percentage_param = params[:percentage]
      expect(percentage_param).not_to be_nil
      expect(percentage_param.type).to eq('number')
      expect(percentage_param.description).to include('percentage')
    end
  end

  describe '#execute' do
    context 'with valid inputs' do
      it 'calculates 20% of 100' do
        result = tool.execute(base: 100, percentage: 20)
        expect(result).to eq('20.00')
      end

      it 'calculates 15% of 200' do
        result = tool.execute(base: 200, percentage: 15)
        expect(result).to eq('30.00')
      end

      it 'calculates with decimal base' do
        result = tool.execute(base: 45.50, percentage: 20)
        expect(result).to eq('9.10')
      end

      it 'handles zero percentage' do
        result = tool.execute(base: 100, percentage: 0)
        expect(result).to eq('0.00')
      end

      it 'handles zero base' do
        result = tool.execute(base: 0, percentage: 20)
        expect(result).to eq('0.00')
      end

      it 'handles float percentage by converting to integer' do
        result = tool.execute(base: 100, percentage: 20.5)
        expect(result).to eq('20.00') # 20.5.to_i = 20
      end

      it 'returns formatted value with 2 decimal places' do
        result = tool.execute(base: 100, percentage: 33)
        expect(result).to eq('33.00')
      end
    end

    context 'with Calculator integration' do
      it 'creates CalculationRequest with correct parameters' do
        expect(PocketKnife::CalculationRequest).to receive(:new)
          .with(percentage: 20, base: 100)
          .and_call_original

        tool.execute(base: 100, percentage: 20)
      end

      it 'calls Calculator.calculate' do
        expect(PocketKnife::Calculator).to receive(:calculate).and_call_original
        tool.execute(base: 100, percentage: 20)
      end

      it 'returns formatted_value from CalculationResult' do
        result_double = double('CalculationResult', formatted_value: '42.00')
        allow(PocketKnife::Calculator).to receive(:calculate).and_return(result_double)

        result = tool.execute(base: 100, percentage: 42)
        expect(result).to eq('42.00')
      end
    end

    context 'error handling' do
      it 'handles InvalidInputError gracefully' do
        allow(PocketKnife::Calculator).to receive(:calculate)
          .and_raise(PocketKnife::InvalidInputError, 'Invalid percentage')

        result = tool.execute(base: 100, percentage: -5)
        expect(result).to start_with('Error:')
        expect(result).to include('Invalid percentage')
      end

      it 'handles CalculationError gracefully' do
        allow(PocketKnife::Calculator).to receive(:calculate)
          .and_raise(PocketKnife::CalculationError, 'Calculation failed')

        result = tool.execute(base: Float::NAN, percentage: 20)
        expect(result).to start_with('Error:')
        expect(result).to include('Calculation failed')
      end

      it 'returns error message instead of raising exception' do
        allow(PocketKnife::Calculator).to receive(:calculate)
          .and_raise(PocketKnife::InvalidInputError, 'Test error')

        expect { tool.execute(base: 100, percentage: 20) }.not_to raise_error
      end
    end

    context 'with edge cases' do
      it 'handles large numbers' do
        result = tool.execute(base: 1_000_000, percentage: 5)
        expect(result).to eq('50000.00')
      end

      it 'handles small percentages' do
        result = tool.execute(base: 1000, percentage: 1)
        expect(result).to eq('10.00')
      end

      it 'handles 100 percentage' do
        result = tool.execute(base: 250, percentage: 100)
        expect(result).to eq('250.00')
      end
    end
  end
end
