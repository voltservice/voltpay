import corsFactory from "cors";
import { ALLOWED_ORIGINS } from "./env";

export const cors = corsFactory({
  origin: (origin, cb) => {
    if (!origin) return cb(null, true); // native clients
    const allowed = ALLOWED_ORIGINS.value().split(",").map(s => s.trim());
    cb(allowed.includes(origin) ? null : new Error("CORS blocked"), true);
  },
});