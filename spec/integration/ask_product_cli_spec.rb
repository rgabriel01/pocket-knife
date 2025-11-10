# frozen_string_literal: true

require 'spec_helper'
require 'pocket_knife/cli'
require 'stringio'
require 'tmpdir'
require 'fileutils'
require_relative '../../lib/pocket_knife/storage/database'
require_relative '../../lib/pocket_knife/storage/product'

RSpec.describe 'Ask Product CLI Integration' do
  before do
    # Create a fresh test directory for each test
    @test_dir = Dir.mktmpdir('pocket-knife-ask-test')

    # Override the storage directory for testing (same pattern as database_spec.rb)
    allow(Dir).to receive(:home).and_return(@test_dir)
    PocketKnife::Storage::Database.instance_variable_set(:@storage_dir, nil)
    PocketKnife::Storage::Database.instance_variable_set(:@db_path, nil)
    PocketKnife::Storage::Database.reset_connection!

    # Stub exit to prevent test suite from terminating
    allow_any_instance_of(PocketKnife::CLI).to receive(:exit)

    # Set up API key for LLM
    ENV['GEMINI_API_KEY'] = 'test-api-key-for-integration-testing'

    # Create some test products
    PocketKnife::Storage::Product.create('Apple', 1.50)
    PocketKnife::Storage::Product.create('Banana', 0.75)
    PocketKnife::Storage::Product.create('Orange', 2.00)
    PocketKnife::Storage::Product.create('Watermelon', 8.99)
  end

  after do
    # Clean up
    PocketKnife::Storage::Database.reset_connection!
    ENV.delete('GEMINI_API_KEY')
    FileUtils.rm_rf(@test_dir) if @test_dir
  end

  describe 'successful queries' do
    before do
      # Mock process_product_query to return predictable responses
      allow_any_instance_of(PocketKnife::CLI).to receive(:process_product_query)
        .and_return('Mocked LLM response')
    end

    it 'processes product existence query' do
      expect { PocketKnife::CLI.run(['ask-product', 'Is there a product called banana?']) }
        .to output(/Mocked LLM response/).to_stdout
    end

    it 'processes list all products query' do
      expect { PocketKnife::CLI.run(['ask-product', 'Show me all products']) }
        .to output(/Mocked LLM response/).to_stdout
    end

    it 'processes price filter query' do
      expect { PocketKnife::CLI.run(['ask-product', 'Show me products under $5']) }
        .to output(/Mocked LLM response/).to_stdout
    end

    it 'processes price range query' do
      expect { PocketKnife::CLI.run(['ask-product', 'Products between $1 and $3']) }
        .to output(/Mocked LLM response/).to_stdout
    end

    it 'handles multi-word query arguments' do
      expect { PocketKnife::CLI.run(['ask-product', 'Show', 'me', 'all', 'products', 'under', '$10']) }
        .to output(/Mocked LLM response/).to_stdout
    end
  end

  describe 'validation errors' do
    it 'shows error when LLM is not available' do
      # Temporarily make LLM unavailable
      allow_any_instance_of(PocketKnife::CLI).to receive(:llm_available?).and_return(false)

      expect { PocketKnife::CLI.run(['ask-product', 'test query']) }
        .to output(/LLM features not available/).to_stderr
    end

    it 'shows error when Storage is not available' do
      # Temporarily make Storage unavailable
      allow(PocketKnife::Storage::Database).to receive(:storage_available?).and_return(false)

      expect { PocketKnife::CLI.run(['ask-product', 'test query']) }
        .to output(/Storage features not available/).to_stderr
    end

    it 'shows error when API key is not configured' do
      # Remove API key
      ENV.delete('GEMINI_API_KEY')

      # Stub llm_configured? to return false (no API key)
      allow_any_instance_of(PocketKnife::CLI).to receive(:llm_configured?).and_return(false)

      expect { PocketKnife::CLI.run(['ask-product', 'test query']) }
        .to output(/No API key configured/).to_stderr
    end

    it 'shows error when query is missing' do
      expect { PocketKnife::CLI.run(['ask-product']) }
        .to output(/Missing query/).to_stderr
    end

    it 'shows error when query is empty after trimming whitespace' do
      expect { PocketKnife::CLI.run(['ask-product', '   ', '  ']) }
        .to output(/Missing query/).to_stderr
    end
  end

  describe 'error handling' do
    it 'handles network errors gracefully' do
      # Mock network error during query processing
      allow_any_instance_of(PocketKnife::CLI).to receive(:process_product_query)
        .and_raise(StandardError.new('Connection refused'))

      expect { PocketKnife::CLI.run(['ask-product', 'test query']) }
        .to output(/Unexpected error occurred.*Connection refused/m).to_stderr
    end

    it 'handles API errors with helpful messages' do
      # Mock API error
      allow_any_instance_of(PocketKnife::CLI).to receive(:process_product_query)
        .and_raise(StandardError.new('Invalid API key'))

      expect { PocketKnife::CLI.run(['ask-product', 'test query']) }
        .to output(/Unexpected error occurred.*Invalid API key/m).to_stderr
    end

    it 'handles unexpected errors' do
      # Mock unexpected error
      allow_any_instance_of(PocketKnife::CLI).to receive(:process_product_query)
        .and_raise(RuntimeError.new('Unexpected error'))

      expect { PocketKnife::CLI.run(['ask-product', 'test query']) }
        .to output(/Unexpected error occurred.*Unexpected error/m).to_stderr
    end
  end

  describe 'integration with ProductQueryTool' do
    it 'successfully creates ProductQueryTool and processes query' do
      # Mock successful query processing
      allow_any_instance_of(PocketKnife::CLI).to receive(:process_product_query)
        .and_return('Found product: Banana at $0.75')

      expect { PocketKnife::CLI.run(['ask-product', 'Find banana']) }
        .to output(/Found product: Banana at \$0\.75/).to_stdout
    end

    it 'passes query correctly to process_product_query' do
      expected_query = 'Show me all products under $5'
      received_query = nil

      allow_any_instance_of(PocketKnife::CLI).to receive(:process_product_query) do |_instance, query|
        received_query = query
        'Mocked response'
      end

      PocketKnife::CLI.run(['ask-product', expected_query])

      expect(received_query).to eq(expected_query)
    end
  end
end
