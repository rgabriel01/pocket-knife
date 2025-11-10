# frozen_string_literal: true

module PocketKnife
  # Command-line interface for the Pocket Knife percentage calculator
  #
  # @example Run the CLI
  #   CLI.run(['calc', '100', '20'])
  #   # Outputs: 20.00
  # rubocop:disable Metrics/ClassLength
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

      # Early routing: handle 'ask-product' subcommand
      if @args[0] == 'ask-product'
        execute_ask_product
        return
      end

      # Early routing: handle 'store-product' subcommand
      if @args[0] == 'store-product'
        execute_store_product
        return
      end

      # Early routing: handle 'list-products' subcommand
      if @args[0] == 'list-products'
        execute_list_products
        return
      end

      # Early routing: handle 'get-product' subcommand
      if @args[0] == 'get-product'
        execute_get_product
        return
      end

      # Early routing: handle 'update-product' subcommand
      if @args[0] == 'update-product'
        execute_update_product
        return
      end

      # Early routing: handle 'delete-product' subcommand
      if @args[0] == 'delete-product'
        execute_delete_product
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

    # Execute the ask-product command for natural language product queries
    #
    # @return [void]
    def execute_ask_product
      # Validate RubyLLM availability
      unless llm_available?
        warn_with_fallback(
          'LLM features not available. Install with: bundle install --with llm',
          'For direct product commands, use: pocket-knife get-product <name>'
        )
        exit 1
      end

      # Validate Storage availability
      unless storage_available?
        warn_with_fallback(
          'Storage features not available. Install with: bundle install --with storage',
          'For calculator features, use: pocket-knife calc <amount> <percentage>'
        )
        exit 1
      end

      # Validate API key configuration
      unless llm_configured?
        warn_with_fallback(
          'No API key configured. Set GEMINI_API_KEY in .env file or environment variable.',
          'Get a free key at: https://makersuite.google.com/app/apikey',
          'For direct product commands, use: pocket-knife get-product <name>'
        )
        exit 1
      end

      # Extract query from arguments
      query = @args[1..].join(' ').strip

      if query.empty?
        warn_with_fallback(
          'Missing query. Usage: pocket-knife ask-product "your question about products"',
          'Examples:',
          '  pocket-knife ask-product "Is there a product called banana?"',
          '  pocket-knife ask-product "Show me products under $10"',
          'For direct product commands, use: pocket-knife list-products'
        )
        exit 1
      end

      # Process query with LLM and ProductQueryTool
      begin
        response = process_product_query(query)
        puts response
      rescue Errno::ECONNREFUSED, SocketError => e
        warn_with_fallback(
          'Network error: Unable to connect to Gemini API.',
          'Please check your internet connection and try again.',
          'For offline product access, use: pocket-knife list-products',
          "(Error: #{e.class})"
        )
        exit 1
      rescue StandardError => e
        warn_with_fallback(
          "Unexpected error occurred: #{e.message}",
          'For direct product commands, use: pocket-knife list-products'
        )
        exit 1
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
      response.content.strip
    end

    # Process natural language product query with LLM and ProductQueryTool
    #
    # @param query [String] The natural language query about products
    # @return [String] The formatted response from ProductQueryTool
    def process_product_query(query)
      require_relative 'llm_config'
      require_relative 'product_query_tool'

      # Configure RubyLLM
      LLMConfig.configure!

      # Create chat with ProductQueryTool using Gemini provider
      tool = ProductQueryTool.new
      chat = RubyLLM.chat(provider: :gemini, model: 'gemini-2.0-flash-exp').with_tools(tool)

      # Send query and get response
      response = chat.ask(query)
      response.content.strip
    end

    # Execute the store-product command    # Handle LLM API errors with specific messages
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
    # rubocop:disable Metrics/MethodLength
    def display_help
      puts <<~HELP
        Pocket Knife - Command-line percentage calculator & product storage

        Calculate percentages quickly without leaving your terminal.

        Usage:
          pocket-knife calc <amount> <percentage>
          pocket-knife ask "<natural language query>"
          pocket-knife ask-product "<query>"
          pocket-knife store-product "<name>" <price>
          pocket-knife list-products
          pocket-knife get-product "<name>"
          pocket-knife update-product "<name>" <new_price>
          pocket-knife delete-product "<name>"

        Commands:
          calc           - Calculate percentage with exact numbers
          ask            - Ask percentage questions in natural language (requires LLM setup)
          ask-product    - Query products with natural language (requires LLM + storage setup)
          store-product  - Store a product with name and price (requires storage setup)
          list-products  - List all stored products in a table (requires storage setup)
          get-product    - Get details of a specific product (requires storage setup)
          update-product - Update the price of an existing product (requires storage setup)
          delete-product - Delete a product from storage (requires storage setup)

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

        Ask Product Examples:
          pocket-knife ask-product "Is there a product called banana?"
          pocket-knife ask-product "Show me products under $10"
          pocket-knife ask-product "Products between $5 and $15"
          pocket-knife ask-product "List all products"

        Store Product Examples:
          pocket-knife store-product "Coffee" 12.99
          pocket-knife store-product "Banana" 200.00
          pocket-knife store-product "Milk" 3.50

        List Products Example:
          pocket-knife list-products
          # ID  Name      Price
          # --  ----      -----
          # 1   Coffee    $12.99
          # 2   Banana    $200.00
          # 3   Milk      $3.50

        Get Product Examples:
          pocket-knife get-product "Coffee"
          # Product: Coffee
          # Price: $12.99
          # ID: 1
          # Created: 2025-11-06 14:30:22

          pocket-knife get-product "MILK"
          # (case-insensitive lookup)

        Update Product Examples:
          pocket-knife update-product "Coffee" 15.99
          # ✓ Product price updated
          #   Product:   Coffee
          #   Old Price: $12.99
          #   New Price: $15.99

          pocket-knife update-product "BANANA" 180.00
          # (case-insensitive lookup)

        Delete Product Examples:
          pocket-knife delete-product "Coffee"
          # Delete product 'Coffee' ($12.99)?
          # Are you sure? (y/n): y
          # ✓ Product deleted successfully
          #   Name:  Coffee
          #   Price: $12.99

        Calc Arguments:
          amount      - Any numeric value (integer or decimal)
          percentage  - Whole number only (e.g., 15 for 15%)

        Store Product Arguments:
          name        - Product name (use quotes if it contains spaces)
          price       - Positive numeric value (integer or decimal)

        Update Product Arguments:
          name        - Existing product name (case-insensitive)
          new_price   - New price (positive numeric value)

        Delete Product Arguments:
          name        - Existing product name (case-insensitive)

        Options:
          --help, -h  - Show this help message

        Note: 'calc' percentages should be whole numbers without the % symbol.
              Results are displayed with exactly 2 decimal places.
              Delete operations require confirmation.

        LLM Setup (for 'ask' command):
          1. Install: bundle install --with llm
          2. Configure: Set GEMINI_API_KEY in .env file
          3. Get key: https://makersuite.google.com/app/apikey

        Storage Setup (for product commands):
          1. Install: bundle install --with storage
          2. Database location: ~/.pocket-knife/products.db
      HELP
    end
    # rubocop:enable Metrics/MethodLength

    def execute_store_product
      # Check if storage is available
      unless storage_available?
        handle_storage_unavailable
        exit 1
      end

      # Parse arguments: store-product "<name>" <price>
      name = @args[1]
      price = @args[2]

      # Validate arguments
      if name.nil? || name.strip.empty?
        warn_with_fallback(
          'Missing product name',
          'Usage: pocket-knife store-product "<name>" <price>',
          '',
          'Examples:',
          '  pocket-knife store-product "Coffee" 12.99',
          '  pocket-knife store-product "Milk" 3.50'
        )
        exit 1
      end

      if price.nil?
        warn_with_fallback(
          'Missing price argument',
          'Usage: pocket-knife store-product "<name>" <price>',
          '',
          'Examples:',
          '  pocket-knife store-product "Coffee" 12.99',
          '  pocket-knife store-product "Milk" 3.50'
        )
        exit 1
      end

      # Load storage classes
      require_relative 'storage/product'

      # Check if product already exists
      if PocketKnife::Storage::Product.exists?(name)
        warn_with_fallback(
          "Product \"#{name}\" already exists",
          'Use a different name or update the existing product.'
        )
        exit 1
      end

      # Create the product
      product = PocketKnife::Storage::Product.create(name, price)

      # Success output
      puts ''
      puts '✓ Product stored successfully'
      puts "  Name:  #{product.name}"
      puts "  Price: #{product.formatted_price}"
      puts "  ID:    #{product.id}"
      puts ''
    rescue InvalidInputError => e
      warn_with_fallback(e.message)
      exit 2
    rescue SQLite3::ConstraintException
      warn_with_fallback(
        "Product \"#{name}\" already exists",
        'Use a different name or update the existing product.'
      )
      exit 1
    rescue StandardError => e
      warn_with_fallback(
        'An unexpected error occurred while storing the product',
        "Details: #{e.message}"
      )
      exit 2
    end

    def execute_list_products
      # Check if storage is available
      unless storage_available?
        handle_storage_unavailable
        exit 1
      end

      # Load storage classes
      require_relative 'storage/product'

      # Retrieve all products
      products = PocketKnife::Storage::Product.all

      # Handle empty list
      if products.empty?
        puts 'No products stored yet.'
        return
      end

      # Display table header
      puts 'ID   Name                 Price'
      puts '--   ----                 -----'

      # Display each product
      products.each do |product|
        puts format(
          '%-4<id>d %-20<name>s %<price>s',
          id: product.id,
          name: product.name,
          price: product.formatted_price
        )
      end
    rescue StandardError => e
      warn_with_fallback(
        'An unexpected error occurred while listing products',
        "Details: #{e.message}"
      )
      exit 1
    end

    def execute_get_product
      # Check if storage is available
      unless storage_available?
        handle_storage_unavailable
        exit 1
      end

      # Parse arguments: get-product "<name>"
      name = @args[1]

      # Validate arguments
      if name.nil? || name.strip.empty?
        warn_with_fallback(
          'Product name required',
          'Usage: pocket-knife get-product "<name>"',
          '',
          'Examples:',
          '  pocket-knife get-product "Coffee"',
          '  pocket-knife get-product "Laptop"'
        )
        exit 1
      end

      # Load storage classes
      require_relative 'storage/product'

      # Find the product
      product = PocketKnife::Storage::Product.find_by_name(name)

      # Handle not found
      if product.nil?
        warn_with_fallback("Product '#{name}' not found")
        exit 1
      end

      # Display product details
      puts "Product: #{product.name}"
      puts "Price: #{product.formatted_price}"
      puts "ID: #{product.id}"
      puts "Created: #{product.created_at}"
    rescue StandardError => e
      warn_with_fallback(
        'An unexpected error occurred while retrieving the product',
        "Details: #{e.message}"
      )
      exit 1
    end

    def execute_update_product
      # Check if storage is available
      unless storage_available?
        handle_storage_unavailable
        exit 1
      end

      # Parse arguments: update-product "<name>" <new_price>
      name = @args[1]
      new_price = @args[2]

      # Validate arguments
      if name.nil? || name.strip.empty?
        warn_with_fallback(
          'Product name required',
          'Usage: pocket-knife update-product "<name>" <new_price>',
          '',
          'Examples:',
          '  pocket-knife update-product "Coffee" 15.99',
          '  pocket-knife update-product "Laptop" 899.00'
        )
        exit 1
      end

      if new_price.nil?
        warn_with_fallback(
          'New price required',
          'Usage: pocket-knife update-product "<name>" <new_price>',
          '',
          'Examples:',
          '  pocket-knife update-product "Coffee" 15.99',
          '  pocket-knife update-product "Laptop" 899.00'
        )
        exit 1
      end

      # Load storage classes
      require_relative 'storage/product'

      # Get old price first
      product = PocketKnife::Storage::Product.find_by_name(name)
      if product.nil?
        warn_with_fallback("Product '#{name}' not found")
        exit 1
      end

      old_price = product.formatted_price

      # Update price
      updated_product = PocketKnife::Storage::Product.update_price(name, new_price)

      # Display confirmation
      puts '✓ Product price updated'
      puts "  Product:   #{updated_product.name}"
      puts "  Old Price: #{old_price}"
      puts "  New Price: #{updated_product.formatted_price}"
    rescue ProductNotFoundError => e
      warn_with_fallback(e.message)
      exit 1
    rescue InvalidInputError => e
      warn_with_fallback(e.message)
      exit 2
    rescue StandardError => e
      warn_with_fallback(
        'An unexpected error occurred while updating the product',
        "Details: #{e.message}"
      )
      exit 2
    end

    def execute_delete_product
      # Check if storage is available
      unless storage_available?
        handle_storage_unavailable
        exit 1
      end

      # Parse arguments: delete-product "<name>"
      name = @args[1]

      # Validate arguments
      if name.nil? || name.strip.empty?
        warn_with_fallback(
          'Product name required',
          'Usage: pocket-knife delete-product "<name>"',
          '',
          'Examples:',
          '  pocket-knife delete-product "Coffee"',
          '  pocket-knife delete-product "Laptop"'
        )
        exit 1
      end

      # Load storage classes
      require_relative 'storage/product'

      # Find the product
      product = PocketKnife::Storage::Product.find_by_name(name)
      if product.nil?
        warn_with_fallback("Product '#{name}' not found")
        exit 1
      end

      # Ask for confirmation
      puts "Delete product '#{product.name}' (#{product.formatted_price})?"
      print 'Are you sure? (y/n): '
      response = $stdin.gets.chomp.downcase

      unless %w[y yes].include?(response)
        puts 'Deletion cancelled'
        exit 0
      end

      # Delete the product
      PocketKnife::Storage::Product.delete(name)

      # Display confirmation
      puts '✓ Product deleted successfully'
      puts "  Name:  #{product.name}"
      puts "  Price: #{product.formatted_price}"
    rescue ProductNotFoundError => e
      warn_with_fallback(e.message)
      exit 1
    rescue StandardError => e
      warn_with_fallback(
        'An unexpected error occurred while deleting the product',
        "Details: #{e.message}"
      )
      exit 1
    end

    def storage_available?
      require_relative 'storage/database'
      PocketKnife::Storage::Database.storage_available?
    rescue LoadError
      false
    end

    def handle_storage_unavailable
      warn_with_fallback(
        'Storage features are not available',
        'The sqlite3 gem is not installed.',
        '',
        'To enable storage features:',
        '  1. Run: bundle install --with storage',
        '  2. Try your command again',
        '',
        'For calculations without storage, use:',
        '  pocket-knife calc <amount> <percentage>'
      )
    end
  end
  # rubocop:enable Metrics/ClassLength
end
