# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'
require_relative '../../lib/pocket_knife/product_query_tool'
require_relative '../../lib/pocket_knife/storage/database'
require_relative '../../lib/pocket_knife/storage/product'

RSpec.describe PocketKnife::ProductQueryTool do
  let(:tool) { described_class.new }
  let(:test_dir) { Dir.mktmpdir('pocket-knife-test') }

  before do
    # Override the storage directory for testing
    allow(Dir).to receive(:home).and_return(test_dir)
    PocketKnife::Storage::Database.instance_variable_set(:@storage_dir, nil)
    PocketKnife::Storage::Database.instance_variable_set(:@db_path, nil)
    PocketKnife::Storage::Database.reset_connection!

    # Create test products
    PocketKnife::Storage::Product.create('Apple', 1.50)
    PocketKnife::Storage::Product.create('Banana', 1.99)
    PocketKnife::Storage::Product.create('Orange', 2.99)
    PocketKnife::Storage::Product.create('Grape', 4.99)
    PocketKnife::Storage::Product.create('Mango', 3.50)
  end

  after do
    PocketKnife::Storage::Database.reset_connection!
    FileUtils.rm_rf(test_dir)
  end

  describe 'tool definition' do
    it 'inherits from RubyLLM::Tool' do
      expect(described_class.superclass).to eq(RubyLLM::Tool)
    end

    it 'has a description' do
      expect(described_class.description).to include('Query product database')
    end
  end

  describe '#find_product_by_name' do
    context 'when product exists' do
      it 'returns product details with formatted price' do
        result = tool.find_product_by_name(name: 'Banana')

        expect(result).to eq('Product found: Banana - $1.99')
      end

      it 'is case-insensitive' do
        result = tool.find_product_by_name(name: 'banana')

        expect(result).to include('Banana')
        expect(result).to include('$1.99')
      end

      it 'formats price with 2 decimal places' do
        result = tool.find_product_by_name(name: 'Apple')

        expect(result).to include('$1.50')
      end
    end

    context 'when product does not exist' do
      it 'returns not found message' do
        result = tool.find_product_by_name(name: 'Pineapple')

        expect(result).to include("No product found with name 'Pineapple'")
      end

      it 'suggests using list all products' do
        result = tool.find_product_by_name(name: 'Pineapple')

        expect(result).to include('list all products')
      end
    end

    context 'with invalid input' do
      it 'returns error for empty string' do
        result = tool.find_product_by_name(name: '')

        expect(result).to include('Error')
        expect(result).to include('name must be a non-empty string')
      end

      it 'returns error for whitespace-only string' do
        result = tool.find_product_by_name(name: '   ')

        expect(result).to include('Error')
        expect(result).to include('name must be a non-empty string')
      end

      it 'returns error for non-string input' do
        result = tool.find_product_by_name(name: 123)

        expect(result).to include('Error')
        expect(result).to include('name must be a non-empty string')
      end
    end

    context 'with database error' do
      it 'handles StandardError gracefully' do
        allow(PocketKnife::Storage::Product).to receive(:find_by_name).and_raise(StandardError.new('DB error'))

        result = tool.find_product_by_name(name: 'Apple')

        expect(result).to include('Database error occurred')
      end
    end
  end

  describe '#list_all_products' do
    context 'with products in database' do
      it 'returns formatted list with count' do
        result = tool.list_all_products

        expect(result).to include('All products (5 total)')
      end

      it 'includes all product names' do
        result = tool.list_all_products

        expect(result).to include('Apple')
        expect(result).to include('Banana')
        expect(result).to include('Orange')
        expect(result).to include('Grape')
        expect(result).to include('Mango')
      end

      it 'includes formatted prices' do
        result = tool.list_all_products

        expect(result).to include('$1.50')
        expect(result).to include('$1.99')
        expect(result).to include('$2.99')
      end

      it 'numbers the list' do
        result = tool.list_all_products

        expect(result).to match(/1\..*Apple/)
        expect(result).to match(/2\..*Banana/)
      end

      it 'lists products in alphabetical order' do
        result = tool.list_all_products
        lines = result.split("\n")

        # Skip header, get product names
        product_lines = lines[1..]
        expect(product_lines[0]).to include('Apple')
        expect(product_lines[1]).to include('Banana')
      end
    end

    context 'with no products' do
      it 'returns empty message' do
        # Delete all products
        PocketKnife::Storage::Product.all.each { |p| PocketKnife::Storage::Product.delete(p.name) }

        result = tool.list_all_products

        expect(result).to include('No products stored yet')
      end

      it 'suggests using store-product command' do
        PocketKnife::Storage::Product.all.each { |p| PocketKnife::Storage::Product.delete(p.name) }

        result = tool.list_all_products

        expect(result).to include('store-product')
      end
    end

    context 'with database error' do
      it 'handles StandardError gracefully' do
        allow(PocketKnife::Storage::Product).to receive(:all).and_raise(StandardError.new('DB error'))

        result = tool.list_all_products

        expect(result).to include('Database error occurred')
      end
    end
  end

  describe '#filter_products_by_max_price' do
    context 'with products under max price' do
      it 'returns products priced at or below max' do
        result = tool.filter_products_by_max_price(max_price: 3.00)

        expect(result).to include('Found 3 product(s) under $3.00')
        expect(result).to include('Apple')
        expect(result).to include('Banana')
        expect(result).to include('Orange')
      end

      it 'excludes products above max price' do
        result = tool.filter_products_by_max_price(max_price: 3.00)

        expect(result).not_to include('Grape')
        expect(result).not_to include('Mango')
      end

      it 'includes products exactly at max price' do
        result = tool.filter_products_by_max_price(max_price: 2.99)

        expect(result).to include('Orange')
      end

      it 'numbers the results' do
        result = tool.filter_products_by_max_price(max_price: 3.00)

        expect(result).to match(/1\./)
        expect(result).to match(/2\./)
        expect(result).to match(/3\./)
      end

      it 'formats prices correctly' do
        result = tool.filter_products_by_max_price(max_price: 2.00)

        expect(result).to include('$1.50')
        expect(result).to include('$1.99')
      end
    end

    context 'with no products under max price' do
      it 'returns no results message' do
        result = tool.filter_products_by_max_price(max_price: 1.00)

        expect(result).to include('No products found under $1.00')
      end

      it 'suggests trying higher price' do
        result = tool.filter_products_by_max_price(max_price: 0.50)

        expect(result).to include('Try a higher price')
      end

      it 'suggests list all products' do
        result = tool.filter_products_by_max_price(max_price: 0.50)

        expect(result).to include('list all products')
      end
    end

    context 'with various numeric types' do
      it 'accepts integer' do
        result = tool.filter_products_by_max_price(max_price: 3)

        expect(result).to include('Found 3 product(s)')
      end

      it 'accepts float' do
        result = tool.filter_products_by_max_price(max_price: 3.0)

        expect(result).to include('Found 3 product(s)')
      end

      it 'accepts string numeric' do
        result = tool.filter_products_by_max_price(max_price: '3.0')

        expect(result).to include('Found 3 product(s)')
      end
    end

    context 'with invalid input' do
      it 'returns error for negative price' do
        result = tool.filter_products_by_max_price(max_price: -5.0)

        expect(result).to include('Error')
        expect(result).to include('max_price must be non-negative')
      end

      it 'returns error for non-numeric value' do
        result = tool.filter_products_by_max_price(max_price: 'invalid')

        expect(result).to include('Error')
        expect(result).to include('max_price must be a numeric value')
      end

      it 'returns error for nil' do
        result = tool.filter_products_by_max_price(max_price: nil)

        expect(result).to include('Error')
        expect(result).to include('max_price must be a numeric value')
      end
    end

    context 'with database error' do
      it 'handles StandardError gracefully' do
        allow(PocketKnife::Storage::Product).to receive(:filter_by_max_price).and_raise(StandardError.new('DB error'))

        result = tool.filter_products_by_max_price(max_price: 5.00)

        expect(result).to include('Database error occurred')
      end
    end
  end

  describe '#filter_products_by_price_range' do
    context 'with products in range' do
      it 'returns products within price range' do
        result = tool.filter_products_by_price_range(min_price: 2.00, max_price: 4.00)

        expect(result).to include('Found 2 product(s) between $2.00 and $4.00')
        expect(result).to include('Orange')
        expect(result).to include('Mango')
        expect(result).not_to include('Apple')
        expect(result).not_to include('Grape')
      end

      it 'includes products at min boundary' do
        result = tool.filter_products_by_price_range(min_price: 1.99, max_price: 3.00)

        expect(result).to include('Banana')
      end

      it 'includes products at max boundary' do
        result = tool.filter_products_by_price_range(min_price: 2.00, max_price: 2.99)

        expect(result).to include('Orange')
      end

      it 'numbers the results' do
        result = tool.filter_products_by_price_range(min_price: 1.00, max_price: 3.00)

        expect(result).to match(/1\./)
        expect(result).to match(/2\./)
      end
    end

    context 'with no products in range' do
      it 'returns no results message' do
        result = tool.filter_products_by_price_range(min_price: 10.00, max_price: 20.00)

        expect(result).to include('No products found between $10.00 and $20.00')
      end

      it 'suggests expanding range' do
        result = tool.filter_products_by_price_range(min_price: 10.00, max_price: 20.00)

        expect(result).to include('Try expanding the range')
      end
    end

    context 'with invalid range' do
      it 'returns error when min > max' do
        result = tool.filter_products_by_price_range(min_price: 5.00, max_price: 2.00)

        expect(result).to include('Error')
        expect(result).to include('Minimum price ($5.00) cannot be greater than maximum price ($2.00)')
      end
    end

    context 'with invalid inputs' do
      it 'returns error for negative min_price' do
        result = tool.filter_products_by_price_range(min_price: -1.00, max_price: 5.00)

        expect(result).to include('Error')
        expect(result).to include('min_price must be non-negative')
      end

      it 'returns error for negative max_price' do
        result = tool.filter_products_by_price_range(min_price: 1.00, max_price: -5.00)

        expect(result).to include('Error')
        expect(result).to include('max_price must be non-negative')
      end

      it 'returns error for non-numeric min_price' do
        result = tool.filter_products_by_price_range(min_price: 'invalid', max_price: 5.00)

        expect(result).to include('Error')
        expect(result).to include('min_price must be a numeric value')
      end

      it 'returns error for non-numeric max_price' do
        result = tool.filter_products_by_price_range(min_price: 1.00, max_price: 'invalid')

        expect(result).to include('Error')
        expect(result).to include('max_price must be a numeric value')
      end
    end

    context 'with various numeric types' do
      it 'accepts integers' do
        result = tool.filter_products_by_price_range(min_price: 2, max_price: 4)

        expect(result).to include('Found 2 product(s)')
      end

      it 'accepts floats' do
        result = tool.filter_products_by_price_range(min_price: 2.0, max_price: 4.0)

        expect(result).to include('Found 2 product(s)')
      end

      it 'accepts string numerics' do
        result = tool.filter_products_by_price_range(min_price: '2.0', max_price: '4.0')

        expect(result).to include('Found 2 product(s)')
      end
    end

    context 'with database error' do
      it 'handles StandardError gracefully' do
        allow(PocketKnife::Storage::Product).to receive(:filter_by_price_range).and_raise(StandardError.new('DB error'))

        result = tool.filter_products_by_price_range(min_price: 1.00, max_price: 5.00)

        expect(result).to include('Database error occurred')
      end
    end
  end
end
