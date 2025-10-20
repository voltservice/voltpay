// C:\Users\Metal\voltpay\functions\src\lib\middleware\requestId.ts
import type { NextFunction, Request, Response } from "express";
import { randomUUID } from "node:crypto";

declare module "express-serve-static-core" {
  interface Request {
    id?: string;
  }
}

export function requestId(req: Request, _res: Response, next: NextFunction) {
  req.id =
    (req.headers["x-request-id"] as string | undefined) ||
    (req.headers["x-cf-ray"] as string | undefined) ||
    randomUUID();
  next();
}
