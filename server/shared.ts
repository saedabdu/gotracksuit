import type { Database } from "@db/sqlite";

export type HasDBClient = {
  db: Database;
};
