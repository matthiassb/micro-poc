require 'uri'

module Config
  class Database
    def self.connection_params
      if ENV['DATABASE_URL']
        parse_database_url(ENV['DATABASE_URL'])
      else
        {
          adapter: 'postgres',
          host: ENV['DB_HOST'] || 'postgres',
          port: ENV['DB_PORT'] || 5432,
          database: ENV['DB_NAME'] || 'microservices_db',
          user: ENV['DB_USER'] || 'microservices',
          password: ENV['DB_PASSWORD'] || 'microservices',
          search_path: ENV['DB_SCHEMA'] || 'locations'
        }
      end
    end
    
    private
    
    def self.parse_database_url(url)
      uri = URI.parse(url)
      {
        adapter: 'postgres',
        host: uri.host,
        port: uri.port || 5432,
        database: uri.path.sub('/', ''),
        user: uri.user,
        password: uri.password,
        search_path: URI.decode_www_form(uri.query || '').to_h['schema'] || 'locations'
      }
    end
  end
end 