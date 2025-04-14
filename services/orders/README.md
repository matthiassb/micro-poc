# Orders Microservice

A Python/FastAPI microservice for managing order data.

## Database Migrations

This service uses SQLAlchemy with Alembic for database migrations. To run migrations:

```bash
# Navigate to the orders service directory
cd services/orders

# Install dependencies
pip install -r requirements.txt

# Run migrations
alembic upgrade head

# Rollback the last migration
alembic downgrade -1

# Create a new migration
alembic revision --autogenerate -m "add field to orders"
```

## Development

```bash
# Install dependencies
pip install -r requirements.txt

# Start the service
uvicorn app:app --reload
```

## API Endpoints

- `GET /` - List all orders
- `GET /{order_id}` - Get a specific order
- `POST /` - Create an order
- `PUT /{order_id}` - Update an order
- `DELETE /{order_id}` - Delete an order
