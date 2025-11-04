# frozen_string_literal: true

module PocketKnife
  # Represents the result of a calculation with formatted output
  #
  # @example Create a result
  #   result = CalculationResult.new(value: 30.0, request: request)
  #   result.formatted_value # => "30.00"
  #   result.to_s            # => "30.00"
  class CalculationResult
    attr_reader :value, :formatted_value, :request

    # Initialize a new calculation result
    #
    # @param value [Float] Raw calculation result
    # @param request [CalculationRequest] Original request that produced this result
    def initialize(value:, request:)
      @value = value
      @request = request
      @formatted_value = format_value(value)
    end

    # Return the formatted value as a string
    #
    # @return [String] Formatted value with exactly 2 decimal places
    def to_s
      formatted_value
    end

    private

    # Format a numeric value to exactly 2 decimal places
    #
    # @param val [Numeric] Value to format
    # @return [String] Formatted string (e.g., "30.00")
    def format_value(val)
      format('%.2f', val)
    end
  end
end
