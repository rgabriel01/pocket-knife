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
      # Handle help flags first
      if @args.include?('--help') || @args.include?('-h')
        display_help
        exit 0
      end

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

    # Display help text
    #
    # @return [void]
    def display_help
      puts <<~HELP
        Pocket Knife - Command-line percentage calculator

        Calculate percentages quickly without leaving your terminal.

        Usage: pocket-knife calc <amount> <percentage>

        Examples:
          pocket-knife calc 200 15
          # => 30.00

          pocket-knife calc 99.99 10
          # => 10.00

          pocket-knife calc 45.50 20
          # => 9.10

        Arguments:
          amount      - Any numeric value (integer or decimal)
          percentage  - Whole number only (e.g., 15 for 15%)

        Options:
          --help, -h  - Show this help message

        Note: Percentage should be provided as a whole number without the % symbol.
              Results are displayed with exactly 2 decimal places.
      HELP
    end
  end
end
