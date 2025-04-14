const serverless = require('serverless-http');
const Koa = require('koa');
const Router = require('@koa/router');
const db = require('./models');
const { Customer } = db;

const app = new Koa();
const router = new Router();

// Middleware for parsing JSON
app.use(async (ctx, next) => {
  if (ctx.request.is('application/json')) {
    ctx.request.body = await new Promise((resolve) => {
      let data = '';
      ctx.req.on('data', (chunk) => {
        data += chunk;
      });
      ctx.req.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          resolve({});
        }
      });
    });
  }
  await next();
});

// List all customers
router.get('/', async (ctx) => {
  try {
    const customers = await Customer.findAll();
    ctx.body = customers;
  } catch (error) {
    ctx.status = 500;
    ctx.body = { error: error.message };
  }
});

// Get a specific customer
router.get('/:id', async (ctx) => {
  try {
    const customer = await Customer.findByPk(ctx.params.id);
    if (customer) {
      ctx.body = customer;
    } else {
      ctx.status = 404;
      ctx.body = { error: 'Customer not found' };
    }
  } catch (error) {
    ctx.status = 500;
    ctx.body = { error: error.message };
  }
});

// Create a customer
router.post('/', async (ctx) => {
  try {
    console.log(ctx.request.body); // Log the request body for debugging
    const customer = await Customer.create(ctx.request.body);
    ctx.status = 201;
    ctx.body = customer;
  } catch (error) {
    ctx.status = 400;
    ctx.body = { error: error.errors[0].message };
  }
});

// Update a customer
router.put('/:id', async (ctx) => {
  try {
    const customer = await Customer.findByPk(ctx.params.id);
    if (customer) {
      await customer.update(ctx.request.body);
      ctx.body = customer;
    } else {
      ctx.status = 404;
      ctx.body = { error: 'Customer not found' };
    }
  } catch (error) {
    ctx.status = 400;
    ctx.body = { error: error.message };
  }
});

// Delete a customer
router.delete('/:id', async (ctx) => {
  try {
    const customer = await Customer.findByPk(ctx.params.id);
    if (customer) {
      await customer.destroy();
      ctx.body = { message: 'Customer deleted successfully' };
    } else {
      ctx.status = 404;
      ctx.body = { error: 'Customer not found' };
    }
  } catch (error) {
    ctx.status = 500;
    ctx.body = { error: error.message };
  }
});

app
  .use(router.routes())
  .use(router.allowedMethods());

// Export handler for serverless
module.exports.handler = serverless(app);
