# Micro POC

A container-based microservices proof of concept using Kong API Gateway, with services written in multiple languages (Node.js, Ruby, Python).

## Architecture

- **API Gateway**: Kong for routing and API management
- **Services**:
  - `customers` (Node.js): Customer management service
  - `locations` (Ruby/Sinatra): Location management service
  - `orders` (Python): Order processing service
- **Database**: PostgreSQL for data persistence

## Prerequisites

- Docker and Docker Compose

## Local Development Setup

1. Clone the repository
2. Start the services:
   ```sh
   docker compose up --build --watch
   ```
   This will start:
   - Kong API Gateway (port 8000)
   - PostgreSQL database
   - All microservices
   
   Note: When changes are made in the appropriate folders, migrations will automatically run and services will be auto-built and auto-restarted thanks to the `--watch` flag.

### Available Endpoints

All services are accessible through Kong at `http://localhost:8000`:

- Customers Service:
  ```sh
  curl -i -X GET http://localhost:8000/customers
  ```
- Locations Service:
  ```sh
  curl -i -X GET http://localhost:8000/locations
  ```
- Orders Service:
  ```sh
  curl -i -X GET http://localhost:8000/orders
  ```

```sh
curl --location '127.0.0.1:8000/locations' \
--data-raw '{"firstName":"matthias","lastName":"brooks", "email": "matthias.brooks@live.com"}' |  jq 

{
  "id": 1,
  "firstName": "matthias",
  "lastName": "brooks",
  "email": "matthias.brooks@live.com",
  "updatedAt": "2025-04-14T10:51:56.861Z",
  "createdAt": "2025-04-14T10:51:56.861Z",
  "phone": null
}
```

### Adding a New Service

1. Create a new directory under `services/` with your service code and a Dockerfile
   ```
   services/
   └── your-service/
       ├── Dockerfile
       └── [service files]
   ```

2. Add the service to `docker-compose.yml`:
   ```yaml
   services:
     your-service:
       build: ./services/your-service
       volumes:
         - ./services/your-service:/app
   ```

3. Configure the route in `resources/kong/kong.yml`:
   ```yaml
   services:
     - name: your-service
       url: http://your-service:port
       routes:
         - name: your-service-route
           paths:
             - /your-service
   ```

4. Restart the services:
   ```sh
   docker compose down
   docker compose up --build --watch
   ```

## Database Migrations

Each microservice has its own database migration system:

### Locations Service (Ruby/Sinatra with ActiveRecord)

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

### Customers Service (Node.js with Sequelize)

```bash
# Navigate to the customers service directory
cd services/customers

# Run migrations
npm run migrate

# Undo the last migration
npm run migrate:undo

# Create a new migration
npx sequelize-cli migration:generate --name add-field-to-customers
```

### Orders Service (Python with SQLAlchemy/Alembic)

```bash
# Navigate to the orders service directory
cd services/orders

# Run migrations
alembic upgrade head

# Rollback the last migration
alembic downgrade -1

# Create a new migration
alembic revision --autogenerate -m "add field to orders"
```

## Project Structure

```
.
├── resources/
│   └── kong/              # Kong API Gateway configuration
└── services/
    ├── customers/         # Node.js service with Sequelize migrations
    │   └── db/
    │       └── migrations/  # Database migrations
    ├── locations/         # Ruby/Sinatra service with ActiveRecord migrations
    │   └── db/
    │       └── migrate/     # Database migrations
    └── orders/            # Python service with Alembic migrations
        └── db/
            └── migrations/  # Database migrations
```
