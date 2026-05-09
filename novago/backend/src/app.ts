import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';

import { restaurantRouter } from './modules/restaurants/restaurant.routes';
import { menuRouter } from './modules/menus/menu.routes';
import { orderRouter } from './modules/orders/order.routes';
import { authRouter } from './modules/users/auth.routes';
import { paymentRouter } from './modules/payments/payment.routes';
import { riderRouter } from './modules/riders/rider.routes';
import { whatsappRouter } from './modules/whatsapp/whatsapp.routes';

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));
  app.use(morgan('dev'));

  const uploadsPath = path.join(process.cwd(), 'uploads');
  app.use('/uploads', express.static(uploadsPath));

  app.get('/health', (_req, res) => {
    res.json({ status: 'ok', service: 'novago-backend' });
  });

  app.use('/api/auth',        authRouter);
  app.use('/api/restaurants', restaurantRouter);
  app.use('/api/menus',       menuRouter);
  app.use('/api/orders',      orderRouter);
  app.use('/api/payments',    paymentRouter);
  app.use('/api/riders',      riderRouter);
  app.use('/api/whatsapp',    whatsappRouter);

  app.use((_req, res) => {
    res.status(404).json({ message: 'Not found' });
  });

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  });

  return app;
}
