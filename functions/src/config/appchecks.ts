// src/config/appcheck.ts
import { onCall, onRequest, CallableRequest, HttpsFunction } from "firebase-functions/v2/https";
import type { Request, Response } from "express";

export function secureCall<T = any>(
  handler: (req: CallableRequest<T>) => any | Promise<any>
): HttpsFunction {
  return onCall({ enforceAppCheck: true }, handler);
}

export function secureHttp(handler: (req: Request, res: Response) => void | Promise<void>): HttpsFunction {
  return onRequest({}, handler);
}
