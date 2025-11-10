# frozen_string_literal: true

require 'ruby_llm'
require_relative 'storage/product'
require_relative 'errors'

module PocketKnife
  # RubyLLM Tool for querying product database with natural language
  #
  # This tool exposes product query operations to LLM models, allowing them to
  # interpret natural language questions about products and execute appropriate
  # database queries.
  #
  # @example Tool usage by LLM
  #   tool = ProductQueryTool.new
  #   result = tool.find_product_by_name(name: "Banana")
  #   result # => "Product found: Banana - $1.99"
  class ProductQueryTool < RubyLLM::Tool
    description 'Query product database. Methods: find_product_by_name(name), list_all_products(), ' \
                'filter_products_by_max_price(max_price), filter_products_by_price_range(min_price, max_price)'

    # Execute: Find product by name
    #
    # @param name [String] Product name to search for
    # @return [String] Product details or not found message
    #
    # @example Find existing product
    #   find_product_by_name(name: "Banana") # => "Product found: Banana - $1.99"
    #
    # @example Product not found
    #   find_product_by_name(name: "Mango") # => "No product found with name 'Mango'"
    def find_product_by_name(name:)
      validate_string!(name, 'name')

      product = Storage::Product.find_by_name(name)

      if product
        "Product found: #{product.name} - #{format_price(product.price)}"
      else
        "No product found with name '#{name}'. " \
          "Use 'list all products' to see available products."
      end
    rescue InvalidInputError => e
      "Error: #{e.message}"
    rescue StandardError => e
      "Database error occurred. Please try again. (#{e.class})"
    end

    # Execute: List all products
    #
    # @return [String] Formatted list of all products or empty message
    #
    # @example With products
    #   list_all_products # => "All products (3 total)\n1. Apple - $1.50\n2. Banana - $1.99\n3. Orange - $2.99"
    #
    # @example No products
    #   list_all_products # => "No products stored yet..."
    def list_all_products
      products = Storage::Product.all

      if products.empty?
        'No products stored yet. Use "store-product" command to add products.'
      else
        format_product_list(products, "All products (#{products.length} total)")
      end
    rescue StandardError => e
      "Database error occurred. Please try again. (#{e.class})"
    end

    # Execute: Filter products by maximum price
    #
    # @param max_price [Numeric] Maximum price threshold
    # @return [String] Formatted list of matching products or no results message
    #
    # @example Find products under $3
    #   filter_products_by_max_price(max_price: 3.00)
    #   # => "Found 2 product(s) under $3.00\n1. Apple - $1.50\n2. Banana - $1.99"
    def filter_products_by_max_price(max_price:)
      validate_positive_number!(max_price, 'max_price')

      products = Storage::Product.filter_by_max_price(max_price)

      if products.empty?
        "No products found under #{format_price(max_price)}. " \
          "Try a higher price or use 'list all products' to see what's available."
      else
        format_product_list(
          products,
          "Found #{products.length} product(s) under #{format_price(max_price)}"
        )
      end
    rescue InvalidInputError => e
      "Error: #{e.message}"
    rescue StandardError => e
      "Database error occurred. Please try again. (#{e.class})"
    end

    # Execute: Filter products by price range
    #
    # @param min_price [Numeric] Minimum price (inclusive)
    # @param max_price [Numeric] Maximum price (inclusive)
    # @return [String] Formatted list of matching products or no results message
    #
    # @example Find products between $2 and $4
    #   filter_products_by_price_range(min_price: 2.00, max_price: 4.00)
    #   # => "Found 2 product(s) between $2.00 and $4.00\n1. Orange - $2.99\n2. Mango - $3.50"
    def filter_products_by_price_range(min_price:, max_price:)
      validate_positive_number!(min_price, 'min_price')
      validate_positive_number!(max_price, 'max_price')

      if min_price > max_price
        return "Error: Minimum price (#{format_price(min_price)}) cannot be greater than " \
               "maximum price (#{format_price(max_price)})."
      end

      products = Storage::Product.filter_by_price_range(min_price, max_price)

      if products.empty?
        "No products found between #{format_price(min_price)} and #{format_price(max_price)}. " \
          "Try expanding the range or use 'list all products' to see what's available."
      else
        format_product_list(
          products,
          "Found #{products.length} product(s) between #{format_price(min_price)} and #{format_price(max_price)}"
        )
      end
    rescue InvalidInputError => e
      "Error: #{e.message}"
    rescue StandardError => e
      "Database error occurred. Please try again. (#{e.class})"
    end

    private

    # Format a price with currency symbol
    #
    # @param price [Numeric] Price to format
    # @return [String] Formatted price (e.g., "$12.99")
    def format_price(price)
      format('$%.2f', price)
    end

    # Format a list of products as numbered list
    #
    # @param products [Array<Product>] Products to format
    # @param header [String] Header text
    # @return [String] Formatted list with header and numbered items
    def format_product_list(products, header)
      lines = [header]
      products.each_with_index do |product, index|
        lines << "#{index + 1}. #{product.name} - #{format_price(product.price)}"
      end
      lines.join("\n")
    end

    # Validate string parameter
    #
    # @param value [String] Value to validate
    # @param param_name [String] Parameter name for error messages
    # @raise [InvalidInputError] if value is not a non-empty string
    def validate_string!(value, param_name)
      return if value.is_a?(String) && !value.strip.empty?

      raise InvalidInputError, "#{param_name} must be a non-empty string"
    end

    # Validate positive number parameter
    #
    # @param value [Numeric] Value to validate
    # @param param_name [String] Parameter name for error messages
    # @return [Float] Validated numeric value
    # @raise [InvalidInputError] if value is not a positive number
    def validate_positive_number!(value, param_name)
      numeric_value = Float(value)
      raise InvalidInputError, "#{param_name} must be non-negative (got #{numeric_value})" if numeric_value.negative?

      numeric_value
    rescue ArgumentError, TypeError
      raise InvalidInputError, "#{param_name} must be a numeric value (got #{value.inspect})"
    end
  end
end
