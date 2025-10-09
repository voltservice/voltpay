import express from "express";
import { onRequest } from "firebase-functions/v2/https";
import "../config/globals";                 // sets region+maxInstances
import { EXCHANGE_RATE_API_KEY } from "../config/env";
import { cors } from "../config/cors";
import { getQuote } from "./routes/quotes";
import { health } from "./routes/health";

const app = express();




app.use(cors);
app.use(express.json());
app.get("/api/quotes", getQuote);
app.get("/api/health", health);

// Export one Express-backed function for all /api/** routes
export const api = onRequest({secrets: [EXCHANGE_RATE_API_KEY] }, (req, res) => app(req, res));
