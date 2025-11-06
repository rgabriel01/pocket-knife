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
end
