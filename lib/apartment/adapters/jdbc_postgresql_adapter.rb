=begin

!!!WARNING!!!
This file has not been updated to work with multiple database servers.
!!!WARNING!!!


require 'apartment/adapters/postgresql_adapter'

module Apartment
  module Database

    def self.jdbc_postgresql_adapter(config)
      Apartment.use_schemas ?
          Adapters::JDBCPostgresqlSchemaAdapter.new(config) :
          Adapters::JDBCPostgresqlAdapter.new(config)
    end
  end

  module Adapters

    # Default adapter when not using Postgresql Schemas
    class JDBCPostgresqlAdapter < PostgresqlAdapter

    protected

      def create_database(database)
        # There is a bug in activerecord-jdbcpostgresql-adapter (1.2.5) that will cause
        # an exception if no options are passed into the create_database call.
        Apartment.connection.create_database(environmentify(database), { :thisisahack => '' })

      rescue *rescuable_exceptions
        raise DatabaseExists, "The database #{environmentify(database)} already exists."
      end

      #   Return a new config that is multi-tenanted
      #
      def multi_tenantify(database)
        @config.clone.tap do |config|
          config[:url] = "#{config[:url].gsub(/(\S+)\/.+$/, '\1')}/#{environmentify(database)}"
        end
      end

    private

      def rescue_from
        ActiveRecord::JDBCError
      end
    end

    # Separate Adapter for Postgresql when using schemas
    class JDBCPostgresqlSchemaAdapter < PostgresqlSchemaAdapter

      #   Set schema search path to new schema
      #
      def connect_to_new(database = nil)
        return reset if database.nil?
        raise ActiveRecord::StatementInvalid.new unless Apartment.connection.all_schemas.include? database.to_s

        @current_database = database.to_s
        Apartment.connection.schema_search_path = full_search_path

      rescue ActiveRecord::StatementInvalid, ActiveRecord::JDBCError
        raise SchemaNotFound, "One of the following schema(s) is invalid: #{full_search_path}"
      end

    private

      def rescue_from
        ActiveRecord::JDBCError
      end
    end
  end
end

=end