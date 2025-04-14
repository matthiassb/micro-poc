module.exports = {
  development: {
    username: process.env.DB_USER || 'microservices',
    password: process.env.DB_PASSWORD || 'microservices',
    database: process.env.DB_NAME || 'microservices_db',
    host: process.env.DB_HOST || 'postgres',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    schema: process.env.DB_SCHEMA || 'customers',
    dialectOptions: {
      prependSearchPath: true
    }
  },
  test: {
    username: process.env.DB_USER || 'microservices',
    password: process.env.DB_PASSWORD || 'microservices',
    database: `${process.env.DB_NAME || 'microservices_db'}_test`,
    host: process.env.DB_HOST || 'postgres',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    schema: process.env.DB_SCHEMA || 'customers',
    dialectOptions: {
      prependSearchPath: true
    }
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    schema: process.env.DB_SCHEMA || 'customers',
    dialectOptions: {
      prependSearchPath: true
    }
  }
};
