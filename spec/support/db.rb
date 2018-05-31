require "logger"

RSpec.configure do |c|
  c.before :suite do
    Sequel.extension :migration
    Sequel::Migrator.run DB, "db/migrations"
    DB[:expenses].truncate

    FileUtils.mkdir_p "log"
    DB.loggers << Logger.new("log/sequel.log")
  end

  c.around :example, :db do |example|
    DB.log_info "Starting example: #{example.metadata[:full_description]}"

    DB.transaction(rollback: :always){example.run}

    DB.log_info "Ending example: #{example.metadata[:full_description]}"
  end
end
