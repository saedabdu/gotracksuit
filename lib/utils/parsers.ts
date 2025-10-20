import { z } from "zod";

const UInt16 = z
  .number()
  .int()
  .min(0)
  .max(Math.pow(2, 16) - 1);

export const Port = z.coerce.number().pipe(UInt16);
