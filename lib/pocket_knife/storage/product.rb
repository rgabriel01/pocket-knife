# frozen_string_literal: true

require_relative 'database'

module PocketKnife
  module Storage
    # Product model for managing stored products
    class Product
      attr_reader :id, :name, :price, :created_at, :updated_at

      def initialize(id:, name:, price:, created_at:, updated_at:)
        @id = id
        @name = name
        @price = price.to_f
        @created_at = created_at
        @updated_at = updated_at
      end

      class << self
        def create(name, price)
          validate_name!(name)
          validate_price!(price)

          Database.connection.execute(
            'INSERT INTO products (name, price) VALUES (?, ?)',
            [name, price.to_f]
          )

          find_by_name(name)
        end

        def find_by_name(name)
          row = Database.connection.get_first_row(
            'SELECT * FROM products WHERE name = ? COLLATE NOCASE',
            [name]
          )

          return nil unless row

          new(
            id: row['id'],
            name: row['name'],
            price: row['price'],
            created_at: row['created_at'],
            updated_at: row['updated_at']
          )
        end

        def all
          rows = Database.connection.execute('SELECT * FROM products ORDER BY name ASC')
          rows.map do |row|
            new(
              id: row['id'],
              name: row['name'],
              price: row['price'],
              created_at: row['created_at'],
              updated_at: row['updated_at']
            )
          end
        end

        def exists?(name)
          !find_by_name(name).nil?
        end

        def update_price(name, new_price)
          validate_price!(new_price)

          product = find_by_name(name)
          raise ProductNotFoundError, "Product '#{name}' not found" if product.nil?

          Database.connection.execute(
            'UPDATE products SET price = ?, updated_at = CURRENT_TIMESTAMP WHERE name = ? COLLATE NOCASE',
            [new_price.to_f, name]
          )

          find_by_name(name)
        end

        def delete(name)
          product = find_by_name(name)
          raise ProductNotFoundError, "Product '#{name}' not found" if product.nil?

          Database.connection.execute(
            'DELETE FROM products WHERE name = ? COLLATE NOCASE',
            [name]
          )

          product
        end

        private

        def validate_name!(name)
          raise InvalidInputError, 'Product name cannot be empty' if name.nil? || name.strip.empty?
        end

        def validate_price!(price)
          price_f = Float(price)
          raise InvalidInputError, 'Price must be a positive number' if price_f.negative?
        rescue ArgumentError, TypeError
          raise InvalidInputError, 'Price must be a valid number'
        end
      end

      def formatted_price
        format('$%.2f', price)
      end
    end
  end
end
