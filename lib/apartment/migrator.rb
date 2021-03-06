=begin
  The migrator logic needs to be updated if we decide put logic of migration in apartment.
  Otherwise, should be deleted.

module Apartment

  module Migrator

    extend self

    # Migrate to latest
    def migrate(database)
      Database.process(database) do
        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
          ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
        end
      end
    end

    # Migrate up/down to a specific version
    def run(direction, database, version)
      Database.process(database){ ActiveRecord::Migrator.run(direction, ActiveRecord::Migrator.migrations_path, version) }
    end

    # rollback latest migration `step` number of times
    def rollback(database, step = 1)
      Database.process(database){ ActiveRecord::Migrator.rollback(ActiveRecord::Migrator.migrations_path, step) }
    end
  end

end
=end
