# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'
require_relative '../../lib/pocket_knife/storage/database'
require_relative '../../lib/pocket_knife/storage/product'

RSpec.describe 'Storage CLI Integration' do
  let(:test_dir) { Dir.mktmpdir('pocket-knife-test') }

  before do
    allow(Dir).to receive(:home).and_return(test_dir)
    PocketKnife::Storage::Database.instance_variable_set(:@storage_dir, nil)
    PocketKnife::Storage::Database.instance_variable_set(:@db_path, nil)
    PocketKnife::Storage::Database.reset_connection!
  end

  after do
    PocketKnife::Storage::Database.reset_connection!
    FileUtils.rm_rf(test_dir)
  end

  describe 'store-product command' do
    it 'stores a product successfully' do
      expect do
        PocketKnife::CLI.run(['store-product', 'Coffee', '12.99'])
      end.to output(/✓ Product stored successfully/).to_stdout

      product = PocketKnife::Storage::Product.find_by_name('Coffee')
      expect(product).not_to be_nil
      expect(product.price).to eq(12.99)
    end

    it 'creates database and storage directory on first use' do
      storage_dir = File.join(test_dir, '.pocket-knife')
      db_path = File.join(storage_dir, 'products.db')

      expect(File.exist?(storage_dir)).to be false
      expect(File.exist?(db_path)).to be false

      PocketKnife::CLI.run(['store-product', 'Coffee', '12.99'])

      expect(File.exist?(storage_dir)).to be true
      expect(File.exist?(db_path)).to be true
    end

    it 'handles duplicate product names gracefully' do
      PocketKnife::CLI.run(['store-product', 'Coffee', '12.99'])

      expect do
        PocketKnife::CLI.run(['store-product', 'Coffee', '15.99'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }

      product = PocketKnife::Storage::Product.find_by_name('Coffee')
      expect(product.price).to eq(12.99) # Original price preserved
    end

    it 'validates price is positive' do
      expect do
        PocketKnife::CLI.run(['store-product', 'Coffee', '-12.99'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(2) }
    end

    it 'validates price is numeric' do
      expect do
        PocketKnife::CLI.run(%w[store-product Coffee abc])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(2) }
    end

    it 'requires product name argument' do
      expect do
        PocketKnife::CLI.run(['store-product'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'requires price argument' do
      expect do
        PocketKnife::CLI.run(%w[store-product Coffee])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'persists products across multiple calls' do
      PocketKnife::CLI.run(['store-product', 'Coffee', '12.99'])
      PocketKnife::CLI.run(['store-product', 'Tea', '9.99'])

      products = PocketKnife::Storage::Product.all
      expect(products.length).to eq(2)
      expect(products.map(&:name)).to contain_exactly('Coffee', 'Tea')
    end
  end

  describe 'list-products command' do
    it 'shows empty message when no products stored' do
      expect do
        PocketKnife::CLI.run(['list-products'])
      end.to output("No products stored yet.\n").to_stdout
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'displays products in table format with single product' do
      PocketKnife::CLI.run(['store-product', 'Laptop', '999.99'])

      output = capture_output { PocketKnife::CLI.run(['list-products']) }

      expect(output).to include('ID')
      expect(output).to include('Name')
      expect(output).to include('Price')
      expect(output).to include('--')
      expect(output).to include('----')
      expect(output).to include('-----')
      expect(output).to include('Laptop')
      expect(output).to include('$999.99')
    end
    # rubocop:enable RSpec/MultipleExpectations

    # rubocop:disable RSpec/MultipleExpectations
    it 'displays multiple products in correct order' do
      PocketKnife::CLI.run(['store-product', 'Coffee', '12.99'])
      PocketKnife::CLI.run(['store-product', 'Tea', '9.99'])
      PocketKnife::CLI.run(['store-product', 'Milk', '3.50'])

      output = capture_output { PocketKnife::CLI.run(['list-products']) }

      expect(output).to include('Coffee')
      expect(output).to include('$12.99')
      expect(output).to include('Tea')
      expect(output).to include('$9.99')
      expect(output).to include('Milk')
      expect(output).to include('$3.50')

      # Verify table structure
      lines = output.split("\n")
      expect(lines[0]).to match(/ID\s+Name\s+Price/)
      expect(lines[1]).to match(/--\s+----\s+-----/)
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'formats table columns correctly' do
      PocketKnife::CLI.run(['store-product', 'A', '1.00'])

      output = capture_output { PocketKnife::CLI.run(['list-products']) }

      # Check that ID, Name, and Price are present
      expect(output).to match(/\d+\s+A\s+\$1\.00/)
    end
  end

  describe 'get-product command' do
    it 'displays product details when found' do
      PocketKnife::CLI.run(['store-product', 'Laptop', '999.99'])

      output = capture_output { PocketKnife::CLI.run(%w[get-product Laptop]) }

      expect(output).to include('Product: Laptop')
      expect(output).to include('Price: $999.99')
      expect(output).to include('ID:')
      expect(output).to include('Created:')
    end

    it 'handles case-insensitive product lookup' do
      PocketKnife::CLI.run(['store-product', 'Laptop', '999.99'])

      output = capture_output { PocketKnife::CLI.run(%w[get-product LAPTOP]) }

      expect(output).to include('Product: Laptop')
      expect(output).to include('Price: $999.99')
    end

    it 'exits with code 1 when product not found' do
      expect do
        PocketKnife::CLI.run(%w[get-product NonExistent])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'requires product name argument' do
      expect do
        PocketKnife::CLI.run(['get-product'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'handles empty product name' do
      expect do
        PocketKnife::CLI.run(['get-product', ''])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  describe 'update-product command' do
    before do
      PocketKnife::CLI.run(['store-product', 'Coffee', '12.99'])
    end

    it 'updates product price successfully' do
      output = capture_output { PocketKnife::CLI.run(['update-product', 'Coffee', '15.99']) }

      expect(output).to include('✓ Product price updated')
      expect(output).to include('Product:   Coffee')
      expect(output).to include('Old Price: $12.99')
      expect(output).to include('New Price: $15.99')

      product = PocketKnife::Storage::Product.find_by_name('Coffee')
      expect(product.price).to eq(15.99)
    end

    it 'handles case-insensitive product lookup' do
      output = capture_output { PocketKnife::CLI.run(['update-product', 'COFFEE', '18.50']) }

      expect(output).to include('Product:   Coffee')
      expect(output).to include('New Price: $18.50')
    end

    it 'exits with code 1 when product not found' do
      expect do
        PocketKnife::CLI.run(['update-product', 'NonExistent', '10.00'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'exits with code 2 for invalid price' do
      expect do
        PocketKnife::CLI.run(['update-product', 'Coffee', '-5.00'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(2) }
    end

    it 'exits with code 2 for non-numeric price' do
      expect do
        PocketKnife::CLI.run(%w[update-product Coffee abc])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(2) }
    end

    it 'requires product name argument' do
      expect do
        PocketKnife::CLI.run(['update-product'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'requires new price argument' do
      expect do
        PocketKnife::CLI.run(%w[update-product Coffee])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  describe 'delete-product command' do
    before do
      PocketKnife::CLI.run(['store-product', 'Coffee', '12.99'])
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'deletes product successfully with confirmation' do
      # Simulate user confirming deletion
      allow($stdin).to receive(:gets).and_return("y\n")

      output = capture_output { PocketKnife::CLI.run(%w[delete-product Coffee]) }

      expect(output).to include("Delete product 'Coffee' ($12.99)?")
      expect(output).to include('Are you sure? (y/n):')
      expect(output).to include('✓ Product deleted successfully')
      expect(output).to include('Name:  Coffee')
      expect(output).to include('Price: $12.99')

      product = PocketKnife::Storage::Product.find_by_name('Coffee')
      expect(product).to be_nil
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'handles case-insensitive product lookup' do
      allow($stdin).to receive(:gets).and_return("y\n")

      output = capture_output { PocketKnife::CLI.run(%w[delete-product COFFEE]) }

      expect(output).to include("Delete product 'Coffee'")
      expect(PocketKnife::Storage::Product.find_by_name('Coffee')).to be_nil
    end

    it 'cancels deletion when user says no' do
      allow($stdin).to receive(:gets).and_return("n\n")

      output = capture_output { PocketKnife::CLI.run(%w[delete-product Coffee]) }

      expect(output).to include('Deletion cancelled')

      product = PocketKnife::Storage::Product.find_by_name('Coffee')
      expect(product).not_to be_nil
    end

    it 'cancels deletion when user enters anything other than y/yes' do
      allow($stdin).to receive(:gets).and_return("maybe\n")

      output = capture_output { PocketKnife::CLI.run(%w[delete-product Coffee]) }

      expect(output).to include('Deletion cancelled')

      product = PocketKnife::Storage::Product.find_by_name('Coffee')
      expect(product).not_to be_nil
    end

    it 'exits with code 1 when product not found' do
      expect do
        PocketKnife::CLI.run(%w[delete-product NonExistent])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end

    it 'requires product name argument' do
      expect do
        PocketKnife::CLI.run(['delete-product'])
      end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
    end
  end

  # Helper method to capture stdout
  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
