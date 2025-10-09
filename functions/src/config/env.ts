import { defineSecret, defineString } from "firebase-functions/params";

export const EXCHANGE_RATE_API_KEY = defineSecret("EXCHANGE_RATE_API_KEY");

// string params (optional)
export const ALLOWED_ORIGINS = defineString("ALLOWED_ORIGINS", {
  default: "https://metalbrain.net,https://www.metalbrain.net,http://localhost:5001,http://localhost:3000",
});

export const STRIPE_API_VERSION = defineString("STRIPE_API_VERSION", {
  default: "2022-11-15",
});