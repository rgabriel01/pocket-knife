# frozen_string_literal: true

require 'sqlite3'
require 'fileutils'

module PocketKnife
  module Storage
    # Database connection manager for SQLite storage
    class Database
      class << self
        def connection
          @connection ||= begin
            ensure_directory!
            ensure_database!
            SQLite3::Database.new(db_path).tap do |db|
              db.results_as_hash = true
            end
          end
        end

        def db_path
          @db_path ||= File.join(storage_dir, 'products.db')
        end

        def storage_dir
          @storage_dir ||= File.join(Dir.home, '.pocket-knife')
        end

        def storage_available?
          require 'sqlite3'
          true
        rescue LoadError
          false
        end

        def reset_connection!
          @connection&.close
          @connection = nil
        end

        private

        def ensure_directory!
          FileUtils.mkdir_p(storage_dir)
        end

        def ensure_database!
          return if File.exist?(db_path)

          # Create database and run migrations
          db = SQLite3::Database.new(db_path)
          run_migrations(db)
          db.close
        end

        def run_migrations(db)
          db.execute <<-SQL
            CREATE TABLE IF NOT EXISTS products (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE,
              price REAL NOT NULL CHECK(price >= 0),
              created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
              updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
            );
          SQL

          db.execute <<-SQL
            CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
          SQL
        end
      end
    end
  end
end
