# frozen_string_literal: true

module PocketKnife
  # Configuration management for LLM integration
  #
  # Handles API key management and RubyLLM configuration.
  # Uses Google Gemini as the LLM provider.
  # Supports loading API keys from .env file.
  #
  # @example Check if LLM features are available
  #   LLMConfig.llm_available? # => true if ruby_llm gem is installed
  #
  # @example Check if API keys are configured
  #   LLMConfig.configured? # => true if Gemini API key is set
  #
  # @example Configure RubyLLM
  #   LLMConfig.configure! # Configures RubyLLM with Gemini API key
  class LLMConfig
    class << self
      # Check if the ruby_llm gem is available
      #
      # @return [Boolean] true if ruby_llm can be loaded
      def llm_available?
        require 'ruby_llm'
        load_dotenv
        true
      rescue LoadError
        false
      end

      # Load .env file if dotenv gem is available
      #
      # @return [void]
      def load_dotenv
        require 'dotenv'
        Dotenv.load
      rescue LoadError
        # Dotenv not available, skip
      end

      # Check if Gemini API key is configured
      #
      # @return [Boolean] true if Gemini API key is set
      def configured?
        !gemini_key.nil? && valid_api_key?(gemini_key)
      end

      # Configure RubyLLM with Gemini API key
      #
      # @return [void]
      # @raise [MissingAPIKeyError] if no API key is configured
      # @raise [InvalidAPIKeyError] if API key format is invalid
      def configure!
        return unless llm_available?

        raise MissingAPIKeyError, 'No API key configured. Set GEMINI_API_KEY' unless gemini_key

        unless valid_api_key?(gemini_key)
          raise InvalidAPIKeyError,
                'Invalid API key format. Remove quotes and ensure no extra spaces.'
        end

        RubyLLM.configure do |config|
          config.gemini_api_key = gemini_key
        end
      end

      private

      # Get Gemini API key from environment
      #
      # @return [String, nil] The API key or nil if not set
      def gemini_key
        key = ENV.fetch('GEMINI_API_KEY', nil)
        key&.strip&.empty? ? nil : key&.strip
      end

      # Validate API key format
      #
      # @param key [String] The API key to validate
      # @return [Boolean] true if key format is valid
      def valid_api_key?(key)
        return false if key.nil? || key.empty?
        return false if key.start_with?('"', "'") || key.end_with?('"', "'")
        return false if key.include?("\n") || key.include?("\r")

        # Gemini API keys are typically alphanumeric with dashes/underscores
        key.match?(/\A[A-Za-z0-9_-]+\z/)
      end
    end
  end

  # Raised when no API keys are configured for LLM features
  class MissingAPIKeyError < ConfigurationError; end

  # Raised when an API key format is invalid
  class InvalidAPIKeyError < ConfigurationError; end
end
