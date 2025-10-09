/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


// functions/src/index.ts
import { onRequest } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions";

// ✅ set defaults FIRST
setGlobalOptions({
  region: "europe-west2",
  maxInstances: 10,
  enforceAppCheck: true,
});

// ✅ then import your functions
export { api } from "./http/api";
export { refreshFX } from "./schedule/refreshFX";

// New import for getQuote and EXCHANGE_RATE_API_KEY
import { getQuote } from "./http/routes/quotes";
import { EXCHANGE_RATE_API_KEY } from "./config/env";

export const testQuote = onRequest(
  { secrets: [EXCHANGE_RATE_API_KEY] },
  async (req, res) => {
    console.log("testQuote called");
    await getQuote(req, res);
  }
);
