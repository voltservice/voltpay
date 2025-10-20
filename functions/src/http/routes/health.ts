// C:\Users\Metal\voltpay\functions\src\lib\http\routes\health.ts
import { Router } from "express";
import { APP } from "../../config/globals";

export function mountHealthRoutes(r: Router) {
  r.get("/health", (_req, res) => {
    res.status(200).json({
      ok: true,
      service: APP.name,
      env: APP.env,
      time: new Date().toISOString()
    });
  });

  r.get("/ping", (_req, res) => {
    res.type("text").send("pong");
  });
}
