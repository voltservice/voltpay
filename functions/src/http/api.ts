// C:\Users\Metal\voltpay\functions\src\lib\http\api.ts
import express, { NextFunction, Request, Response } from "express";
import helmet from "helmet";
import compression from "compression";
import { corsMiddleware } from "../config/cors";
import { APP } from "../config/globals";
import { requestId } from "../middleware/requestId";
import { globalLimiter } from "../middleware/rateLimit";
import { requireAppCheck } from "../config/appCheck";
import { mountHealthRoutes } from "./routes/health";

export const apiApp = (() => {
  const app = express();

  app.set("trust proxy", 1); // behind Cloud LB


  // Security headers (helmet defaults are good; tweak as needed)
  app.use(helmet());
  // Gzip/deflate
  app.use(compression());

  // CORS policy
  app.use(corsMiddleware);

  // Request ID first so logs always carry it
  app.use(requestId);

  // Global rate limit (apply early)
  app.use(globalLimiter);

  // Body parsers
  app.use(express.json({ limit: "1mb" }));
  app.use(express.urlencoded({ extended: false }));

  // Optional request logging
  if (APP.logRequests) {
    app.use((req, _res, next) => {
      console.log(`[${req.id}] ${req.method} ${req.originalUrl}`);
      next();
    });
  }

  // App Check guard (place before mounting feature routers)
  app.use(requireAppCheck);

  // Mount feature routes
  const router = express.Router();

  // Health
  mountHealthRoutes(router);

  // Example: stricter limiter for sensitive endpoints
  // import { authLimiter } from "../middleware/rateLimit";
  // router.post("/auth/something", authLimiter, handler);

  app.use("/", router);

  // 404
  app.use((_req, res) => {
    res.status(404).json({ error: "Not Found" });
  });

  // Central error handler
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  app.use((err: any, req: Request, res: Response, _next: NextFunction) => {
    const status = Number(err?.status || 500);
    const msg =
      err?.message ||
      (status === 403 ? "Forbidden" : status === 401 ? "Unauthorized" : "Internal error");
    if (status >= 500) console.error(`[${req.id}]`, err);
    res.status(status).json({ error: msg, requestId: req.id });
  });

  return app;
})();
