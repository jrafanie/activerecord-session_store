namespace 'db:sessions' do
  desc "Creates a sessions migration for use with ActiveRecord::SessionStore"
  task :create => [:environment, 'db:load_config'] do
    raise 'Task unavailable to this database (no migration support)' unless ActiveRecord::Base.connection.supports_migrations?
    Rails.application.load_generators
    require 'rails/generators/rails/session_migration/session_migration_generator'
    Rails::Generators::SessionMigrationGenerator.start [ ENV['MIGRATION'] || 'add_sessions_table' ]
  end

  desc "Clear the sessions table"
  task :clear => [:environment, 'db:load_config'] do
    ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{ActiveRecord::SessionStore::Session.table_name}"
  end

  desc "Trim old sessions from the table (default: > 30 days)"
  task :trim => [:environment, 'db:load_config'] do
    cutoff_period = (ENV['SESSION_DAYS_TRIM_THRESHOLD'] || 30).to_i.days.ago
    ActiveRecord::SessionStore::Session.
      where("updated_at < ?", cutoff_period).
      delete_all
  end
end
