class Init < ActiveRecord::Migration
  def self.up
    config   = Rails::Configuration.new
    host     = config.database_configuration[RAILS_ENV]["host"]
    database = config.database_configuration[RAILS_ENV]["database"]
    username = config.database_configuration[RAILS_ENV]["username"]
    password = config.database_configuration[RAILS_ENV]["password"]
    file_path = "#{RAILS_ROOT}/doc/model/material.sql"
    system("mysql -u#{username} --password=#{password} --database=#{database} < #{file_path}")
  end

  def self.down
  end
end
