# frozen_string_literal: true

module PocketKnife
  # Represents a calculation request with validated inputs
  #
  # @example Create a valid request
  #   request = CalculationRequest.new(percentage: 15, base: 200.0)
  #   request.valid? # => true
  #
  # @example Create an invalid request (negative percentage)
  #   request = CalculationRequest.new(percentage: -5, base: 100.0)
  #   request.valid? # => false
  class CalculationRequest
    attr_reader :percentage, :base, :operation

    # Initialize a new calculation request
    #
    # @param percentage [Integer] Whole number percentage (e.g., 15 for 15%)
    # @param base [Numeric] The base number to calculate percentage of
    # @param operation [Symbol] Type of calculation (default: :percent_of)
    def initialize(percentage:, base:, operation: :percent_of)
      @percentage = percentage
      @base = base
      @operation = operation
    end

    # Check if the request has valid inputs
    #
    # @return [Boolean] true if all inputs are valid
    def valid?
      percentage.is_a?(Integer) &&
        base.is_a?(Numeric) &&
        percentage >= 0 &&
        base.finite?
    end
  end
end
