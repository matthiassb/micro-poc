require 'sequel'
require 'uri'
require_relative '../config/database'

module DB
  def self.connection
    @connection ||= begin
      conn = Sequel.connect(Config::Database.connection_params)
      
      # Create schema if using one
      if schema = Config::Database.connection_params[:search_path]
        conn.execute("CREATE SCHEMA IF NOT EXISTS #{schema}")
        conn.execute("SET search_path TO #{schema}")
      end
      
      conn
    end
  end
end

# Initialize connection on first use 