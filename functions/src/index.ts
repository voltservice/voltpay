// C:\Users\Metal\voltpay\functions\src\lib\index.ts
import * as admin from "firebase-admin";
import { onRequest } from "firebase-functions/v2/https";
import { onCall } from "firebase-functions/v2/https";
import { APP } from "./config/globals";
import { apiApp } from "./http/api";

// Initialize Admin SDK exactly once
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Export your HTTP API (Express) as a single function endpoint
export const api = onRequest(
  {
    region: APP.region,
    cors: false
  },
  apiApp
);

export const echo = onCall(
  {
    region: APP.region,
    // Enforce App Check automatically for callable
    enforceAppCheck: true
  },
  (req) => {
    return { data: req.data, appId: req.app?.appId || null };
  }
);

/**
 * Example: add more exports here later without touching the core.
 *
 * import { onCall } from "firebase-functions/v2/https";
 * export const echo = onCall({ region: APP.region }, (req) => ({ data: req.data }));
 *
 * import { onSchedule } from "firebase-functions/v2/scheduler";
 * export const nightly = onSchedule({ schedule: "0 2 * * *", region: APP.region }, () => {...});
 */
