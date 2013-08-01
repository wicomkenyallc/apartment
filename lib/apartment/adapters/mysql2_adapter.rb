module Apartment

  module Database

    def self.mysql2_adapter(config)
        Adapters::Mysql2Adapter.new(config)
    end
  end

  module Adapters

    class Mysql2Adapter < AbstractAdapter

      def process_excluded_models
        Apartment.excluded_models.each do |excluded_model|
          puts "[EXCLUDED] Build connection for #{excluded_model}" if @@debug
          excluded_model.constantize.build_connection
        end
      end

    protected

      #   Connect to new database
      #   Abstract adapter will catch generic ActiveRecord error
      #   Catch specific adapter errors here
      #
      #   @param {Hash} database_config, 
      #         complete info of a database, :database, :host, ...
      #   ---------------------------------------
      def connect_to_new(database_config)

        # Step1: using establish_connection to retrive/start a connection to the db server.
        Apartment.establish_connection database_config

        # Step2: use "USE" to connect to the desired database.
        unless database_config[:target_database].nil? # the only situation that :target_database is nil that database_config is the dummy default config.
          Apartment.connection.execute "USE #{database_config[:target_database]}"
        end

      rescue Mysql2::Error, ActiveRecord::StatementInvalid
        Apartment::Database.reset
        raise DatabaseNotFound, "Cannot find database #{database_config[:target_database]}"
      end
      
      # return {string}, name of the current database
      def current_database_name
        # In the release of rails 3.2.14 rc2, 
        # ActiveRecord::Base.connection.current_database becomes a private method.
        # Apartment.connection.current_database # 3.2.13
      
        # 3.2.14 # Running MySql command directly to retrive the current used db name.
        Apartment.connection.select_value 'SELECT DATABASE() as db'
      end

    end
  end
end
