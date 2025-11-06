# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'tmpdir'
require_relative '../../../lib/pocket_knife/storage/database'

RSpec.describe PocketKnife::Storage::Database do
  let(:test_dir) { Dir.mktmpdir('pocket-knife-test') }

  before do
    # Override the storage directory for testing
    allow(Dir).to receive(:home).and_return(test_dir)
    described_class.instance_variable_set(:@storage_dir, nil)
    described_class.instance_variable_set(:@db_path, nil)
    described_class.reset_connection!
  end

  after do
    described_class.reset_connection!
    FileUtils.rm_rf(test_dir)
  end

  describe '.storage_available?' do
    context 'when sqlite3 is available' do
      it 'returns true' do
        expect(described_class.storage_available?).to be true
      end
    end

    context 'when sqlite3 is not available' do
      it 'returns false' do
        allow(described_class).to receive(:require).with('sqlite3').and_raise(LoadError)
        expect(described_class.storage_available?).to be false
      end
    end
  end

  describe '.storage_dir' do
    it 'returns the .pocket-knife directory in home' do
      expect(described_class.storage_dir).to eq(File.join(test_dir, '.pocket-knife'))
    end
  end

  describe '.db_path' do
    it 'returns the products.db path in storage directory' do
      expected_path = File.join(test_dir, '.pocket-knife', 'products.db')
      expect(described_class.db_path).to eq(expected_path)
    end
  end

  describe '.connection' do
    it 'creates the storage directory if it does not exist' do
      expect(Dir.exist?(described_class.storage_dir)).to be false
      described_class.connection
      expect(Dir.exist?(described_class.storage_dir)).to be true
    end

    it 'creates the database file if it does not exist' do
      expect(File.exist?(described_class.db_path)).to be false
      described_class.connection
      expect(File.exist?(described_class.db_path)).to be true
    end

    it 'creates the products table on first connection' do
      db = described_class.connection
      tables = db.execute("SELECT name FROM sqlite_master WHERE type='table'")
      table_names = tables.map { |row| row['name'] }
      expect(table_names).to include('products')
    end

    it 'creates an index on the products name column' do
      db = described_class.connection
      indexes = db.execute("SELECT name FROM sqlite_master WHERE type='index'")
      index_names = indexes.map { |row| row['name'] }
      expect(index_names).to include('idx_products_name')
    end

    it 'returns results as hash' do
      db = described_class.connection
      expect(db.results_as_hash).to be true
    end

    it 'reuses the same connection on subsequent calls' do
      conn1 = described_class.connection
      conn2 = described_class.connection
      expect(conn1).to be(conn2)
    end
  end

  describe '.reset_connection!' do
    it 'closes the existing connection' do
      conn = described_class.connection
      expect(conn).to receive(:close)
      described_class.reset_connection!
    end

    it 'resets the connection instance variable' do
      described_class.connection
      described_class.reset_connection!
      expect(described_class.instance_variable_get(:@connection)).to be_nil
    end

    it 'allows creating a new connection after reset' do
      old_conn = described_class.connection
      described_class.reset_connection!
      new_conn = described_class.connection
      expect(new_conn).not_to be(old_conn)
    end
  end

  describe 'database schema' do
    let(:db) { described_class.connection }

    it 'creates products table with correct columns' do
      columns = db.execute('PRAGMA table_info(products)')
      column_names = columns.map { |col| col['name'] }

      expect(column_names).to include('id', 'name', 'price', 'created_at', 'updated_at')
    end

    it 'sets id as primary key with autoincrement' do
      columns = db.execute('PRAGMA table_info(products)')
      id_column = columns.find { |col| col['name'] == 'id' }

      expect(id_column['pk']).to eq(1)
      expect(id_column['type']).to eq('INTEGER')
    end

    it 'sets name as NOT NULL' do
      columns = db.execute('PRAGMA table_info(products)')
      name_column = columns.find { |col| col['name'] == 'name' }

      expect(name_column['notnull']).to eq(1)
    end

    it 'sets price as NOT NULL' do
      columns = db.execute('PRAGMA table_info(products)')
      price_column = columns.find { |col| col['name'] == 'price' }

      expect(price_column['notnull']).to eq(1)
    end

    it 'enforces unique constraint on name' do
      db.execute('INSERT INTO products (name, price) VALUES (?, ?)', ['Test', 10.0])

      expect do
        db.execute('INSERT INTO products (name, price) VALUES (?, ?)', ['Test', 20.0])
      end.to raise_error(SQLite3::ConstraintException)
    end

    it 'enforces non-negative price constraint' do
      expect do
        db.execute('INSERT INTO products (name, price) VALUES (?, ?)', ['Test', -10.0])
      end.to raise_error(SQLite3::ConstraintException)
    end
  end
end
