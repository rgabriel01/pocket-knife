# frozen_string_literal: true

module PocketKnife
  # Base error class for all Pocket Knife errors
  class PocketKnifeError < StandardError; end

  # Raised when user provides invalid input (exit code 2)
  #
  # @example
  #   raise InvalidInputError, "Amount must be a number"
  class InvalidInputError < PocketKnifeError; end

  # Raised when a calculation fails (exit code 1)
  #
  # @example
  #   raise CalculationError, "Invalid request"
  class CalculationError < PocketKnifeError; end

  # Raised when CLI usage is incorrect (exit code 1)
  #
  # @example
  #   raise CLIError, "Missing required argument"
  class CLIError < PocketKnifeError; end

  # Raised when configuration is invalid (exit code 1)
  #
  # @example
  #   raise ConfigurationError, "Invalid configuration file"
  class ConfigurationError < PocketKnifeError; end

  # Raised when a product is not found in storage (exit code 1)
  #
  # @example
  #   raise ProductNotFoundError, "Product 'Coffee' not found"
  class ProductNotFoundError < PocketKnifeError; end
end
