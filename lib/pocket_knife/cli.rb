# frozen_string_literal: true

module PocketKnife
  # Command-line interface for the Pocket Knife percentage calculator
  #
  # @example Run the CLI
  #   CLI.run(['calc', '100', '20'])
  #   # Outputs: 20.00
  class CLI
    # Run the CLI with provided arguments
    #
    # @param args [Array<String>] Command-line arguments (typically ARGV)
    # @return [void]
    def self.run(args)
      new(args).execute
    end

    # Initialize CLI with arguments
    #
    # @param args [Array<String>] Command-line arguments
    def initialize(args)
      @args = args
      @percentage = nil
      @base = nil
    end

    # Execute the CLI command
    #
    # @return [void]
    def execute
      # Early routing: handle help flags
      if @args.include?('--help') || @args.include?('-h')
        display_help
        exit 0
      end

      # Early routing: handle 'ask' subcommand
      if @args[0] == 'ask'
        execute_ask
        return
      end

      # Existing calc command flow (unchanged)
      parse_arguments
      validate_inputs
      result = calculate
      output(result)
    end

    private

    # Parse command-line arguments
    #
    # @raise [CLIError] If subcommand is missing or invalid
    # @raise [CLIError] If wrong number of arguments
    def parse_arguments
      # Check for calc subcommand
      subcommand = @args[0]
      raise CLIError, 'Missing subcommand. Use: pocket-knife calc <amount> <percentage>' if subcommand.nil?

      unless subcommand == 'calc'
        raise CLIError,
              "Unknown subcommand '#{subcommand}'. Use: pocket-knife calc <amount> <percentage>"
      end

      # Extract arguments
      @base_str = @args[1]
      @percentage_str = @args[2]

      # Check argument count
      if @base_str.nil? || @percentage_str.nil?
        raise CLIError, 'Missing arguments. Usage: pocket-knife calc <amount> <percentage>'
      end

      return unless @args.length > 3

      raise CLIError, 'Too many arguments. Usage: pocket-knife calc <amount> <percentage>'
    end

    # Validate and convert input strings to numbers
    #
    # @raise [InvalidInputError] If inputs cannot be parsed or are invalid
    def validate_inputs
      # Check for % symbol in percentage
      if @percentage_str.include?('%')
        raise InvalidInputError, 'Invalid percentage. Please provide a whole number without the % symbol.'
      end

      # Parse percentage (must be integer)
      @percentage = Integer(@percentage_str)
    rescue ArgumentError
      raise InvalidInputError, 'Invalid percentage. Please provide a whole number.'
    else
      # Validate percentage is non-negative
      raise InvalidInputError, 'Percentage cannot be negative' if @percentage.negative?

      # Parse base amount (can be float)
      begin
        @base = Float(@base_str)
      rescue ArgumentError
        raise InvalidInputError, 'Invalid amount. Please provide a numeric value.'
      end

      # Validate base is finite
      raise CalculationError, 'Amount must be a finite number' unless @base.finite?
    end

    # Perform the calculation
    #
    # @return [CalculationResult] The calculation result
    def calculate
      request = CalculationRequest.new(percentage: @percentage, base: @base)
      Calculator.calculate(request)
    end

    # Output the result to STDOUT
    #
    # @param result [CalculationResult] The result to output
    # @return [void]
    def output(result)
      puts result
    end

    # Execute the ask subcommand for natural language queries
    #
    # @return [void]
    # @raise [CLIError] If RubyLLM gem is not installed
    # @raise [CLIError] If no API key is configured
    def execute_ask
      # Validate RubyLLM availability
      unless llm_available?
        warn_with_fallback(
          'LLM features not available. Install with: bundle install --with llm',
          'For direct calculations, use: pocket-knife calc <amount> <percentage>'
        )
        exit 1
      end

      # Validate API key configuration
      unless llm_configured?
        warn_with_fallback(
          'No API key configured. Set GEMINI_API_KEY in .env file or environment variable.',
          'Get a free key at: https://makersuite.google.com/app/apikey',
          'For direct calculations, use: pocket-knife calc <amount> <percentage>'
        )
        exit 1
      end

      # Extract query from arguments
      query = @args[1..].join(' ').strip

      if query.empty?
        warn_with_fallback(
          'Missing query. Usage: pocket-knife ask "What is 20% of 100?"',
          'For direct calculations, use: pocket-knife calc <amount> <percentage>'
        )
        exit 1
      end

      # Process query with LLM
      begin
        response = process_llm_query(query)
        puts response
      rescue Errno::ECONNREFUSED, SocketError => e
        warn_with_fallback(
          'Network error: Unable to connect to Gemini API.',
          'Please check your internet connection and try again.',
          'For offline calculations, use: pocket-knife calc <amount> <percentage>',
          "(Error: #{e.class})"
        )
        exit 2
      # rubocop:disable Lint/ShadowedException
      rescue Timeout::Error, Net::ReadTimeout => e
        # rubocop:enable Lint/ShadowedException
        warn_with_fallback(
          'Request timeout: The API took too long to respond.',
          'Please try again later.',
          'For immediate results, use: pocket-knife calc <amount> <percentage>',
          "(Error: #{e.class})"
        )
        exit 2
      rescue StandardError => e
        handle_llm_api_error(e)
      end
    end

    # Check if LLM features are available
    #
    # @return [Boolean]
    def llm_available?
      require_relative 'llm_config'
      LLMConfig.llm_available?
    rescue LoadError
      false
    end

    # Check if LLM is configured with API key
    #
    # @return [Boolean]
    def llm_configured?
      require_relative 'llm_config'
      LLMConfig.configured?
    rescue LoadError
      false
    end

    # Process natural language query with LLM
    #
    # @param query [String] The natural language query
    # @return [String] The LLM response
    def process_llm_query(query)
      require_relative 'llm_config'
      require_relative 'percentage_calculator_tool'

      # Configure RubyLLM
      LLMConfig.configure!

      # Create chat with tool using Gemini provider
      tool = PercentageCalculatorTool.new
      chat = RubyLLM.chat(provider: :gemini, model: 'gemini-2.0-flash-exp').with_tools(tool)

      # Send query and get response
      response = chat.ask(query)
      response.content.text.strip
    end

    # Handle LLM API errors with specific messages
    #
    # @param error [StandardError] The error to handle
    # @return [void]
    def handle_llm_api_error(error)
      error_message = error.message.downcase

      if error_message.include?('api key') || error_message.include?('authentication') ||
         error_message.include?('unauthorized')
        warn_with_fallback(
          'Authentication failed: Invalid or expired API key.',
          'Please verify your GEMINI_API_KEY is correct.',
          'Get a new key at: https://makersuite.google.com/app/apikey',
          'For direct calculations, use: pocket-knife calc <amount> <percentage>'
        )
        exit 1
      elsif error_message.include?('rate limit') || error_message.include?('quota') ||
            error_message.include?('resource exhausted')
        warn_with_fallback(
          'Rate limit exceeded: Too many requests to Gemini API.',
          'Please wait a moment and try again, or upgrade your API plan.',
          'For immediate results, use: pocket-knife calc <amount> <percentage>'
        )
        exit 2
      elsif error_message.include?('model') || error_message.include?('unknown')
        warn_with_fallback(
          'Configuration error: Invalid model or provider settings.',
          'Please check your RubyLLM configuration.',
          'For direct calculations, use: pocket-knife calc <amount> <percentage>',
          "(Error: #{error.class}: #{error.message})"
        )
        exit 1
      else
        warn_with_fallback(
          "LLM error: #{error.message}",
          'An unexpected error occurred while processing your request.',
          'For direct calculations, use: pocket-knife calc <amount> <percentage>'
        )
        exit 2
      end
    end

    # Display error message with fallback suggestion to STDERR
    #
    # @param messages [Array<String>] Error messages to display
    # @return [void]
    def warn_with_fallback(*messages)
      warn "\nError: #{messages.first}"
      messages[1..].each { |msg| warn "  #{msg}" }
    end

    # Display help text
    #
    # @return [void]
    def display_help
      puts <<~HELP
        Pocket Knife - Command-line percentage calculator

        Calculate percentages quickly without leaving your terminal.

        Usage:
          pocket-knife calc <amount> <percentage>
          pocket-knife ask "<natural language query>"

        Commands:
          calc        - Calculate percentage with exact numbers
          ask         - Ask percentage questions in natural language (requires LLM setup)

        Calc Examples:
          pocket-knife calc 200 15
          # => 30.00

          pocket-knife calc 99.99 10
          # => 10.00

          pocket-knife calc 45.50 20
          # => 9.10

        Ask Examples:
          pocket-knife ask "What is 20% of 100?"
          pocket-knife ask "Calculate 15 percent of 200"
          pocket-knife ask "How much is a 20% tip on $45.50?"

        Calc Arguments:
          amount      - Any numeric value (integer or decimal)
          percentage  - Whole number only (e.g., 15 for 15%)

        Options:
          --help, -h  - Show this help message

        Note: 'calc' percentages should be whole numbers without the % symbol.
              Results are displayed with exactly 2 decimal places.

        LLM Setup (for 'ask' command):
          1. Install: bundle install --with llm
          2. Configure: Set GEMINI_API_KEY in .env file
          3. Get key: https://makersuite.google.com/app/apikey
      HELP
    end
  end
end
