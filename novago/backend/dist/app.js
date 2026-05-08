"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = createApp;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const morgan_1 = __importDefault(require("morgan"));
const path_1 = __importDefault(require("path"));
const restaurant_routes_1 = require("./modules/restaurants/restaurant.routes");
const menu_routes_1 = require("./modules/menus/menu.routes");
const order_routes_1 = require("./modules/orders/order.routes");
const auth_routes_1 = require("./modules/users/auth.routes");
const payment_routes_1 = require("./modules/payments/payment.routes");
const rider_routes_1 = require("./modules/riders/rider.routes");
function createApp() {
    const app = (0, express_1.default)();
    app.use((0, helmet_1.default)());
    app.use((0, cors_1.default)());
    app.use(express_1.default.json());
    app.use(express_1.default.urlencoded({ extended: true }));
    app.use((0, morgan_1.default)('dev'));
    // Serve static files from uploads directory
    // Handle both compiled (dist) and dev (src) directory structures
    const uploadsPath = path_1.default.join(process.cwd(), 'uploads');
    app.use('/uploads', express_1.default.static(uploadsPath));
    app.get('/health', (_req, res) => {
        res.json({ status: 'ok', service: 'novago-backend' });
    });
    app.use('/api/auth', auth_routes_1.authRouter);
    app.use('/api/restaurants', restaurant_routes_1.restaurantRouter);
    app.use('/api/menus', menu_routes_1.menuRouter);
    app.use('/api/orders', order_routes_1.orderRouter);
    app.use('/api/payments', payment_routes_1.paymentRouter);
    app.use('/api/riders', rider_routes_1.riderRouter);
    // 404 handler
    app.use((_req, res) => {
        res.status(404).json({ message: 'Not found' });
    });
    // Basic error handler
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    app.use((err, _req, res, _next) => {
        console.error(err);
        res.status(500).json({ message: 'Internal server error' });
    });
    return app;
}
