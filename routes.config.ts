// Routes the radar watches.
//
// Chosen for VOLATILITY, not popularity. Corridor routes (workers flying home)
// barely move — people fly regardless of price, so the board sits still.
// Leisure routes swing 40%+ as airlines dump empty seats, which is where a
// "wait" or "book now" call is actually worth making.
//
// All of these are visa-free or visa-on-arrival for UAE residents.
export type RouteDef = { origin: string; destination: string; label: string; tag: string };

export const ROUTES: RouteDef[] = [
  // The classic Dubai long weekend — fares bounce between ~600 and ~1400 AED
  { origin: "DXB", destination: "TBS", label: "Dubai → Tbilisi", tag: "weekend" },
  { origin: "DXB", destination: "GYD", label: "Dubai → Baku", tag: "weekend" },
  { origin: "DXB", destination: "KTM", label: "Dubai → Kathmandu", tag: "weekend" },
  // Beach runs — highly seasonal, big swings
  { origin: "DXB", destination: "ZNZ", label: "Dubai → Zanzibar", tag: "beach" },
  { origin: "DXB", destination: "HKT", label: "Dubai → Phuket", tag: "beach" },
  // City breaks — dense competition, frequent fare wars
  { origin: "DXB", destination: "IST", label: "Dubai → Istanbul", tag: "city" },
  { origin: "DXB", destination: "TAS", label: "Dubai → Tashkent", tag: "city" },
];

// Cities used for the "where can I go?" discovery board.
export const DISCOVERY_ORIGINS = ["DXB", "SHJ", "AUH"];

export function defaultMonth(): string {
  const d = new Date();
  d.setDate(1);
  d.setMonth(d.getMonth() + 1);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}
