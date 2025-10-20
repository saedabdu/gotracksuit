import type { Insight } from "$models/insight.ts";
import type { HasDBClient } from "../shared.ts";
import type * as insightsTable from "$tables/insights.ts";

type Input = HasDBClient;

export default (input: Input): Insight[] => {
  console.log("Listing insights");

  const rows = input.db.sql<insightsTable.Row>`SELECT * FROM insights`;

  const result: Insight[] = rows.map((row) => ({
    ...row,
    createdAt: new Date(row.createdAt),
  }));

  console.log("Retrieved insights successfully: ", result);
  return result;
};
