import type { Request, Response } from "express";
import { EXCHANGE_RATE_API_KEY } from "../../config/env";

export async function getQuote(req: Request, res: Response) {
  const source = String(req.query.source ?? "USD").toUpperCase();
  const target = String(req.query.target ?? "EUR").toUpperCase();
  const amount = Number(req.query.amount ?? 1000);
  const method = String(req.query.method ?? "wire");

  const key = EXCHANGE_RATE_API_KEY.value();
  if (!key) return res.status(500).json({ error: "missing_api_key" });

  const r = await fetch(`https://v6.exchangerate-api.com/v6/${key}/pair/${source}/${target}`);
  if (!r.ok) return res.status(502).json({ error: "provider", status: r.status, statusText: r.statusText });
  const data: any = await r.json();
  if (data?.result !== "success" || typeof data?.conversion_rate !== "number") {
    return res.status(502).json({ error: "bad_provider_payload" });
  }
  const rate: number = data.conversion_rate;
  
  if (rate <= 0) return res.status(502).json({ error: "invalid_rate" });

  // Fees based on method
  const methodFee = method === "wire" ? 6.11 : method === "debitCard" ? 12.35 : method === "creditCard" ? 61.65 : 0.0;
  const ourFee = 3.76;
  const totalFees = methodFee + ourFee;
  const recipientAmount = (amount - totalFees) * rate;

  res.set("Cache-Control", "private, max-age=30");
  res.json({
    sourceCurrency: source,
    targetCurrency: target,
    sourceAmount: amount,
    rate,
    recipientAmount: Number(recipientAmount.toFixed(2)),
    fees: [
      { label: "Payment method fee", amount: methodFee, code: "payment_method_fee" },
      { label: "Our fee", amount: ourFee, code: "our_fee" }
    ],
    guaranteeSeconds: 11 * 60 * 60,
    arrivalSeconds: method === "wire" ? 4 * 60 * 60 : 2 * 60 * 60
  });
  return;
}