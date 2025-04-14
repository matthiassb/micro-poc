# Locations Microservice

A Ruby/Sinatra microservice for managing location data.

## Database Migrations

This service uses ActiveRecord for database migrations. To run migrations:

```bash
# Navigate to the locations service directory
cd services/locations

# Run migrations
bundle exec rake db:migrate

# Rollback the last migration
bundle exec rake db:rollback

# Create a new migration
bundle exec rake db:create_migration NAME=add_field_to_locations
```

## Development

```bash
# Install dependencies
bundle install

# Start the service
ruby app.rb
```

## API Endpoints

- `GET /health` - Health check
- `GET /` - List all locations
- `GET /:id` - Get a specific location
- `POST /` - Create a location
- `PUT /:id` - Update a location
- `DELETE /:id` - Delete a location
