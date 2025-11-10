# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'
require_relative '../../../lib/pocket_knife/storage/database'
require_relative '../../../lib/pocket_knife/storage/product'

RSpec.describe PocketKnife::Storage::Product do
  let(:test_dir) { Dir.mktmpdir('pocket-knife-test') }

  before do
    # Override the storage directory for testing
    allow(Dir).to receive(:home).and_return(test_dir)
    PocketKnife::Storage::Database.instance_variable_set(:@storage_dir, nil)
    PocketKnife::Storage::Database.instance_variable_set(:@db_path, nil)
    PocketKnife::Storage::Database.reset_connection!
  end

  after do
    PocketKnife::Storage::Database.reset_connection!
    FileUtils.rm_rf(test_dir)
  end

  describe '.create' do
    context 'with valid inputs' do
      it 'creates a product with name and price' do
        product = described_class.create('Coffee', 12.99)

        expect(product).to be_a(described_class)
        expect(product.name).to eq('Coffee')
        expect(product.price).to eq(12.99)
      end

      it 'assigns an auto-incremented id' do
        product1 = described_class.create('Coffee', 12.99)
        product2 = described_class.create('Tea', 9.99)

        expect(product1.id).to eq(1)
        expect(product2.id).to eq(2)
      end

      it 'sets created_at timestamp' do
        product = described_class.create('Coffee', 12.99)

        expect(product.created_at).not_to be_nil
        expect(product.created_at).to be_a(String)
      end

      it 'sets updated_at timestamp' do
        product = described_class.create('Coffee', 12.99)

        expect(product.updated_at).not_to be_nil
        expect(product.updated_at).to be_a(String)
      end

      it 'handles decimal prices' do
        product = described_class.create('Coffee', 12.995)

        expect(product.price).to eq(12.995)
      end

      it 'handles integer prices' do
        product = described_class.create('Coffee', 10)

        expect(product.price).to eq(10.0)
      end

      it 'handles string prices' do
        product = described_class.create('Coffee', '12.99')

        expect(product.price).to eq(12.99)
      end

      it 'handles zero price' do
        product = described_class.create('Free Sample', 0)

        expect(product.price).to eq(0.0)
      end

      it 'handles product names with spaces' do
        product = described_class.create('Organic Coffee', 15.99)

        expect(product.name).to eq('Organic Coffee')
      end

      it 'handles product names with special characters' do
        product = described_class.create("Coffee & Tea's", 12.99)

        expect(product.name).to eq("Coffee & Tea's")
      end
    end

    context 'with invalid name' do
      it 'raises error for nil name' do
        expect do
          described_class.create(nil, 12.99)
        end.to raise_error(PocketKnife::InvalidInputError, 'Product name cannot be empty')
      end

      it 'raises error for empty name' do
        expect do
          described_class.create('', 12.99)
        end.to raise_error(PocketKnife::InvalidInputError, 'Product name cannot be empty')
      end

      it 'raises error for whitespace-only name' do
        expect do
          described_class.create('   ', 12.99)
        end.to raise_error(PocketKnife::InvalidInputError, 'Product name cannot be empty')
      end
    end

    context 'with invalid price' do
      it 'raises error for negative price' do
        expect do
          described_class.create('Coffee', -12.99)
        end.to raise_error(PocketKnife::InvalidInputError, 'Price must be a positive number')
      end

      it 'raises error for non-numeric string price' do
        expect do
          described_class.create('Coffee', 'abc')
        end.to raise_error(PocketKnife::InvalidInputError, 'Price must be a valid number')
      end

      it 'raises error for nil price' do
        expect do
          described_class.create('Coffee', nil)
        end.to raise_error(PocketKnife::InvalidInputError, 'Price must be a valid number')
      end
    end

    context 'with duplicate name' do
      it 'raises constraint exception' do
        described_class.create('Coffee', 12.99)

        expect do
          described_class.create('Coffee', 15.99)
        end.to raise_error(SQLite3::ConstraintException)
      end
    end
  end

  describe '.find_by_name' do
    before do
      described_class.create('Coffee', 12.99)
      described_class.create('Tea', 9.99)
    end

    context 'when product exists' do
      it 'returns the product' do
        product = described_class.find_by_name('Coffee')

        expect(product).to be_a(described_class)
        expect(product.name).to eq('Coffee')
        expect(product.price).to eq(12.99)
      end

      it 'returns the correct product by name' do
        product = described_class.find_by_name('Tea')

        expect(product.name).to eq('Tea')
        expect(product.price).to eq(9.99)
      end
    end

    context 'when product does not exist' do
      it 'returns nil' do
        product = described_class.find_by_name('Nonexistent')

        expect(product).to be_nil
      end
    end

    it 'is case-insensitive' do
      product = described_class.find_by_name('coffee')

      expect(product).not_to be_nil
      expect(product.name).to eq('Coffee')
    end
  end

  describe '.all' do
    context 'when no products exist' do
      it 'returns an empty array' do
        products = described_class.all

        expect(products).to eq([])
      end
    end

    context 'when products exist' do
      before do
        described_class.create('Coffee', 12.99)
        described_class.create('Tea', 9.99)
        described_class.create('Milk', 3.50)
      end

      it 'returns all products' do
        products = described_class.all

        expect(products.length).to eq(3)
      end

      it 'returns products as Product instances' do
        products = described_class.all

        expect(products).to all(be_a(described_class))
      end

      it 'returns products sorted by name alphabetically' do
        products = described_class.all

        expect(products.map(&:name)).to eq(%w[Coffee Milk Tea])
      end

      it 'includes all product attributes' do
        products = described_class.all
        product = products.first

        expect(product.id).not_to be_nil
        expect(product.name).not_to be_nil
        expect(product.price).not_to be_nil
        expect(product.created_at).not_to be_nil
        expect(product.updated_at).not_to be_nil
      end
    end
  end

  describe '.exists?' do
    before do
      described_class.create('Coffee', 12.99)
    end

    it 'returns true when product exists' do
      expect(described_class.exists?('Coffee')).to be true
    end

    it 'returns false when product does not exist' do
      expect(described_class.exists?('Tea')).to be false
    end

    it 'is case-insensitive' do
      expect(described_class.exists?('coffee')).to be true
    end
  end

  describe '#formatted_price' do
    it 'formats price with dollar sign and 2 decimal places' do
      product = described_class.create('Coffee', 12.99)

      expect(product.formatted_price).to eq('$12.99')
    end

    it 'formats whole number prices with 2 decimal places' do
      product = described_class.create('Coffee', 10)

      expect(product.formatted_price).to eq('$10.00')
    end

    it 'formats zero price correctly' do
      product = described_class.create('Free Sample', 0)

      expect(product.formatted_price).to eq('$0.00')
    end

    it 'rounds to 2 decimal places' do
      product = described_class.create('Coffee', 12.995)

      expect(product.formatted_price).to eq('$13.00')
    end
  end

  describe '.update_price' do
    before do
      described_class.create('Coffee', 12.99)
    end

    context 'when product exists' do
      it 'updates the product price' do
        updated_product = described_class.update_price('Coffee', 15.99)

        expect(updated_product.price).to eq(15.99)
        expect(updated_product.name).to eq('Coffee')
      end

      it 'returns the updated product instance' do
        updated_product = described_class.update_price('Coffee', 20.00)

        expect(updated_product).to be_a(described_class)
        expect(updated_product.price).to eq(20.00)
      end

      it 'is case-insensitive' do
        updated_product = described_class.update_price('coffee', 18.50)

        expect(updated_product.price).to eq(18.50)
      end

      it 'converts price to float' do
        updated_product = described_class.update_price('Coffee', '25.50')

        expect(updated_product.price).to eq(25.50)
        expect(updated_product.price).to be_a(Float)
      end
    end

    context 'when product does not exist' do
      it 'raises ProductNotFoundError' do
        expect do
          described_class.update_price('Nonexistent', 10.00)
        end.to raise_error(PocketKnife::ProductNotFoundError, "Product 'Nonexistent' not found")
      end
    end

    context 'with invalid price' do
      it 'raises error for negative price' do
        expect do
          described_class.update_price('Coffee', -5.00)
        end.to raise_error(PocketKnife::InvalidInputError, 'Price must be a positive number')
      end

      it 'raises error for non-numeric price' do
        expect do
          described_class.update_price('Coffee', 'abc')
        end.to raise_error(PocketKnife::InvalidInputError, 'Price must be a valid number')
      end

      it 'raises error for nil price' do
        expect do
          described_class.update_price('Coffee', nil)
        end.to raise_error(PocketKnife::InvalidInputError, 'Price must be a valid number')
      end
    end
  end

  describe '.delete' do
    before do
      described_class.create('Coffee', 12.99)
      described_class.create('Tea', 9.99)
    end

    context 'when product exists' do
      it 'deletes the product from database' do
        described_class.delete('Coffee')

        expect(described_class.find_by_name('Coffee')).to be_nil
      end

      it 'returns the deleted product instance' do
        deleted_product = described_class.delete('Coffee')

        expect(deleted_product).to be_a(described_class)
        expect(deleted_product.name).to eq('Coffee')
        expect(deleted_product.price).to eq(12.99)
      end

      it 'is case-insensitive' do
        deleted_product = described_class.delete('coffee')

        expect(deleted_product.name).to eq('Coffee')
        expect(described_class.find_by_name('Coffee')).to be_nil
      end

      it 'does not affect other products' do
        described_class.delete('Coffee')

        expect(described_class.find_by_name('Tea')).not_to be_nil
      end
    end

    context 'when product does not exist' do
      it 'raises ProductNotFoundError' do
        expect do
          described_class.delete('Nonexistent')
        end.to raise_error(PocketKnife::ProductNotFoundError, "Product 'Nonexistent' not found")
      end
    end
  end

  describe '#initialize' do
    it 'sets all attributes' do
      product = described_class.new(
        id: 1,
        name: 'Coffee',
        price: 12.99,
        created_at: '2024-01-01',
        updated_at: '2024-01-01'
      )

      expect(product.id).to eq(1)
      expect(product.name).to eq('Coffee')
      expect(product.price).to eq(12.99)
      expect(product.created_at).to eq('2024-01-01')
      expect(product.updated_at).to eq('2024-01-01')
    end

    it 'converts price to float' do
      product = described_class.new(
        id: 1,
        name: 'Coffee',
        price: '12.99',
        created_at: '2024-01-01',
        updated_at: '2024-01-01'
      )

      expect(product.price).to eq(12.99)
      expect(product.price).to be_a(Float)
    end
  end

  describe '.filter_by_max_price' do
    before do
      described_class.create('Apple', 1.50)
      described_class.create('Banana', 1.99)
      described_class.create('Orange', 2.99)
      described_class.create('Grape', 4.99)
      described_class.create('Mango', 3.50)
    end

    context 'with products under max price' do
      it 'returns products priced at or below max price' do
        products = described_class.filter_by_max_price(3.00)

        expect(products.length).to eq(3)
        expect(products.map(&:name)).to contain_exactly('Apple', 'Banana', 'Orange')
      end

      it 'includes products exactly at max price boundary' do
        products = described_class.filter_by_max_price(2.99)

        expect(products.map(&:name)).to include('Orange')
        expect(products.length).to eq(3)
      end

      it 'orders results by price ascending' do
        products = described_class.filter_by_max_price(5.00)

        prices = products.map(&:price)
        expect(prices).to eq(prices.sort)
      end

      it 'orders by name when prices are equal' do
        described_class.create('Zucchini', 1.50)
        products = described_class.filter_by_max_price(2.00)

        same_price_products = products.select { |p| (p.price - 1.50).abs < 0.01 }
        names = same_price_products.map(&:name)
        expect(names).to eq(%w[Apple Zucchini])
      end
    end

    context 'with no products under max price' do
      it 'returns empty array when max price is too low' do
        products = described_class.filter_by_max_price(0.50)

        expect(products).to eq([])
      end
    end

    context 'with empty database' do
      it 'returns empty array' do
        # Delete all products first
        described_class.all.each { |p| described_class.delete(p.name) }
        products = described_class.filter_by_max_price(10.00)

        expect(products).to eq([])
      end
    end

    context 'with various numeric types' do
      it 'accepts integer max_price' do
        products = described_class.filter_by_max_price(3)

        expect(products.length).to eq(3)
      end

      it 'accepts float max_price' do
        products = described_class.filter_by_max_price(3.0)

        expect(products.length).to eq(3)
      end

      it 'accepts string numeric max_price' do
        products = described_class.filter_by_max_price('3.0')

        expect(products.length).to eq(3)
      end
    end

    context 'with invalid max_price' do
      it 'raises error for negative max_price' do
        expect do
          described_class.filter_by_max_price(-5.0)
        end.to raise_error(PocketKnife::InvalidInputError, 'max_price must be non-negative')
      end

      it 'raises error for non-numeric max_price' do
        expect do
          described_class.filter_by_max_price('invalid')
        end.to raise_error(PocketKnife::InvalidInputError, 'max_price must be a numeric value')
      end

      it 'raises error for nil max_price' do
        expect do
          described_class.filter_by_max_price(nil)
        end.to raise_error(PocketKnife::InvalidInputError, 'max_price must be a numeric value')
      end
    end
  end

  describe '.filter_by_price_range' do
    before do
      described_class.create('Apple', 1.50)
      described_class.create('Banana', 1.99)
      described_class.create('Orange', 2.99)
      described_class.create('Grape', 4.99)
      described_class.create('Mango', 3.50)
    end

    context 'with products in range' do
      it 'returns products within price range' do
        products = described_class.filter_by_price_range(2.00, 4.00)

        expect(products.length).to eq(2)
        expect(products.map(&:name)).to contain_exactly('Orange', 'Mango')
      end

      it 'includes products at min boundary (inclusive)' do
        products = described_class.filter_by_price_range(1.99, 3.00)

        expect(products.map(&:name)).to include('Banana')
      end

      it 'includes products at max boundary (inclusive)' do
        products = described_class.filter_by_price_range(2.00, 2.99)

        expect(products.map(&:name)).to include('Orange')
      end

      it 'orders results by price ascending' do
        products = described_class.filter_by_price_range(1.00, 5.00)

        prices = products.map(&:price)
        expect(prices).to eq(prices.sort)
      end

      it 'orders by name when prices are equal' do
        described_class.create('Zucchini', 1.50)
        products = described_class.filter_by_price_range(1.00, 2.00)

        same_price_products = products.select { |p| (p.price - 1.50).abs < 0.01 }
        names = same_price_products.map(&:name)
        expect(names).to eq(%w[Apple Zucchini])
      end
    end

    context 'with no products in range' do
      it 'returns empty array when range is too high' do
        products = described_class.filter_by_price_range(10.00, 20.00)

        expect(products).to eq([])
      end

      it 'returns empty array when range is too low' do
        products = described_class.filter_by_price_range(0.10, 0.50)

        expect(products).to eq([])
      end
    end

    context 'with empty database' do
      it 'returns empty array' do
        # Delete all products first
        described_class.all.each { |p| described_class.delete(p.name) }
        products = described_class.filter_by_price_range(1.00, 10.00)

        expect(products).to eq([])
      end
    end

    context 'with various numeric types' do
      it 'accepts integer prices' do
        products = described_class.filter_by_price_range(2, 4)

        expect(products.length).to eq(2)
      end

      it 'accepts float prices' do
        products = described_class.filter_by_price_range(2.0, 4.0)

        expect(products.length).to eq(2)
      end

      it 'accepts string numeric prices' do
        products = described_class.filter_by_price_range('2.0', '4.0')

        expect(products.length).to eq(2)
      end
    end

    context 'with invalid inputs' do
      it 'raises error when min_price > max_price' do
        expect do
          described_class.filter_by_price_range(5.00, 2.00)
        end.to raise_error(PocketKnife::InvalidInputError, 'min_price cannot be greater than max_price')
      end

      it 'raises error for negative min_price' do
        expect do
          described_class.filter_by_price_range(-1.00, 5.00)
        end.to raise_error(PocketKnife::InvalidInputError, 'min_price must be non-negative')
      end

      it 'raises error for negative max_price' do
        expect do
          described_class.filter_by_price_range(1.00, -5.00)
        end.to raise_error(PocketKnife::InvalidInputError, 'max_price must be non-negative')
      end

      it 'raises error for non-numeric min_price' do
        expect do
          described_class.filter_by_price_range('invalid', 5.00)
        end.to raise_error(PocketKnife::InvalidInputError, 'min_price must be a numeric value')
      end

      it 'raises error for non-numeric max_price' do
        expect do
          described_class.filter_by_price_range(1.00, 'invalid')
        end.to raise_error(PocketKnife::InvalidInputError, 'max_price must be a numeric value')
      end

      it 'raises error for nil min_price' do
        expect do
          described_class.filter_by_price_range(nil, 5.00)
        end.to raise_error(PocketKnife::InvalidInputError, 'min_price must be a numeric value')
      end

      it 'raises error for nil max_price' do
        expect do
          described_class.filter_by_price_range(1.00, nil)
        end.to raise_error(PocketKnife::InvalidInputError, 'max_price must be a numeric value')
      end
    end
  end

  describe '.count' do
    context 'with products in database' do
      it 'returns correct count' do
        described_class.create('Apple', 1.50)
        described_class.create('Banana', 1.99)
        described_class.create('Orange', 2.99)

        expect(described_class.count).to eq(3)
      end

      it 'updates count after adding products' do
        expect(described_class.count).to eq(0)

        described_class.create('Apple', 1.50)
        expect(described_class.count).to eq(1)

        described_class.create('Banana', 1.99)
        expect(described_class.count).to eq(2)
      end

      it 'updates count after deleting products' do
        described_class.create('Apple', 1.50)
        described_class.create('Banana', 1.99)
        expect(described_class.count).to eq(2)

        described_class.delete('Apple')
        expect(described_class.count).to eq(1)
      end
    end

    context 'with empty database' do
      it 'returns 0' do
        expect(described_class.count).to eq(0)
      end
    end

    context 'return type' do
      it 'returns an integer' do
        described_class.create('Apple', 1.50)

        count = described_class.count
        expect(count).to be_a(Integer)
      end
    end
  end
end
