# frozen_string_literal: true

require 'ruby_llm'
require_relative 'calculator'
require_relative 'calculation_request'

module PocketKnife
  # RubyLLM Tool for calculating percentages using pocket-knife Calculator
  #
  # This tool exposes the Calculator logic to LLM models, allowing them to
  # answer natural language questions about percentage calculations.
  #
  # @example Tool usage by LLM
  #   tool = PercentageCalculatorTool.new
  #   result = tool.execute(base: 100, percentage: 20)
  #   result # => "20.00"
  class PercentageCalculatorTool < RubyLLM::Tool
    description 'Calculate what percentage of a number equals. ' \
                'For example, to find 20% of 100, use base=100 and percentage=20.'

    param :base,
          type: 'number',
          desc: 'The base amount to calculate from (e.g., 100)'

    param :percentage,
          type: 'number',
          desc: 'The percentage to calculate as a whole number (e.g., 20 for 20%)'

    # Execute the percentage calculation
    #
    # @param base [Numeric] The base amount
    # @param percentage [Integer] The percentage as a whole number
    # @return [String] The calculated result formatted to 2 decimal places
    #
    # @example Calculate 20% of 100
    #   execute(base: 100, percentage: 20) # => "20.00"
    def execute(base:, percentage:)
      # Convert to integer if percentage is a float (LLM might send 20.0)
      percentage_int = percentage.to_i

      request = CalculationRequest.new(percentage: percentage_int, base: base)
      result = Calculator.calculate(request)
      result.formatted_value
    rescue InvalidInputError, CalculationError => e
      "Error: #{e.message}"
    end
  end
end
