const serverless = require('serverless-http');
const Koa = require('koa'); // or any supported framework
const Router = require('@koa/router');

const app = new Koa();
const router = new Router();


// /customers
router.get('/', (ctx, next) => {
  ctx.body = { message: 'Hello World - From Customers (NodeJS)' };
});

app
  .use(router.routes())
  .use(router.allowedMethods());

// this is it!
module.exports.handler = serverless(app);