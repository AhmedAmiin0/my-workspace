import { registerAs } from '@nestjs/config';

export default registerAs('database', () => ({
  postgres: {
    type: 'postgres',
    host: process.env.POSTGRES_HOST || 'postgres',
    port: parseInt(process.env.POSTGRES_PORT, 10) || 5432,
    username: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD || 'password',
    database: process.env.POSTGRES_DB || 'customer_app',
    url: process.env.DATABASE_URL,
    synchronize: true,
    logging: process.env.NODE_ENV === 'development',
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
  },
  mongodb: {
    uri: process.env.MONGODB_URI || 'mongodb://mongo:27017/customer_app',
    options: {},
  },
  redis: {
    host: process.env.REDIS_HOST || 'redis',
    port: parseInt(process.env.REDIS_PORT, 10) || 6379,
    url: process.env.REDIS_URL,
  },
}));
