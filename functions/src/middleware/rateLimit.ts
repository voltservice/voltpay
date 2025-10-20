// C:\Users\Metal\voltpay\functions\src\lib\middleware\rateLimit.ts
import rateLimit from "express-rate-limit";
import { SECURITY } from "../config/globals";

export const globalLimiter = rateLimit({
  windowMs: SECURITY.rateLimit.windowMs,
  max: SECURITY.rateLimit.max,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many requests, slow down." }
});

export const authLimiter = rateLimit({
  windowMs: SECURITY.rateLimit.authWindowMs,
  max: SECURITY.rateLimit.authMax,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: "Too many auth attempts, try again later." }
});
