# frozen_string_literal: true

module PocketKnife
  # Pure calculation engine for percentage calculations
  #
  # @example Calculate 15% of 200
  #   request = CalculationRequest.new(percentage: 15, base: 200.0)
  #   result = Calculator.calculate(request)
  #   result.value           # => 30.0
  #   result.formatted_value # => "30.00"
  class Calculator
    # Calculate percentage of a number
    #
    # @param request [CalculationRequest] Validated calculation request
    # @return [CalculationResult] Result with formatted value
    # @raise [CalculationError] If request is invalid
    #
    # @example
    #   request = CalculationRequest.new(percentage: 20, base: 100.0)
    #   result = Calculator.calculate(request)
    #   puts result.to_s # => "20.00"
    def self.calculate(request)
      validate_request(request)
      value = compute_percentage(request.percentage, request.base)
      CalculationResult.new(value: value, request: request)
    end

    # Compute percentage of a base number
    #
    # @param percentage [Integer] Whole number percentage
    # @param base [Numeric] Base number
    # @return [Float] Calculated result
    private_class_method def self.compute_percentage(percentage, base)
      (percentage / 100.0) * base
    end

    # Validate that a request has valid inputs
    #
    # @param request [CalculationRequest] Request to validate
    # @raise [CalculationError] If request is invalid
    private_class_method def self.validate_request(request)
      raise CalculationError, 'Invalid request' unless request.valid?
    end
  end
end
