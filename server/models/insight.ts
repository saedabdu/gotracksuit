import { z } from "zod";

export const Insight = z.object({
  id: z.number().int().min(0),
  brand: z.number().int().min(0),
  createdAt: z.date(),
  text: z.string(),
});

export type Insight = z.infer<typeof Insight>;
