# Customers Microservice

A Node.js/Koa microservice for managing customer data.

## Database Migrations

This service uses Sequelize for database migrations. To run migrations:

```bash
# Navigate to the customers service directory
cd services/customers

# Install dependencies
npm install

# Run migrations
npm run migrate

# Undo the last migration
npm run migrate:undo

# Create a new migration
npx sequelize-cli migration:generate --name add-field-to-customers

# Run seeds
npm run seed
```

## Development

```bash
# Install dependencies
npm install

# Start the service
npm start
```

## API Endpoints

- `GET /` - List all customers
- `GET /:id` - Get a specific customer
- `POST /` - Create a customer
- `PUT /:id` - Update a customer
- `DELETE /:id` - Delete a customer
