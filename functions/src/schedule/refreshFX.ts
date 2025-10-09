import { onSchedule } from "firebase-functions/v2/scheduler";
import "../config/globals";

export const refreshFX = onSchedule(
  { schedule: "every 8 hours", timeZone: "Etc/UTC" },
  async () => {
    // warm cache / prefetch pairs if you add caching later
    console.log("refreshFX tick");
  }
);
