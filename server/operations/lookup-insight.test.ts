import { beforeAll, describe, it } from "jsr:@std/testing/bdd";
import { expect } from "jsr:@std/expect";
import { withDB } from "../testing.ts";
import type { Insight } from "$models/insight.ts";
import lookupInsight from "./lookup-insight.ts";

describe("listing insights in the database", () => {
  describe("specified insight not in the DB", () => {
    withDB((fixture) => {
      let result: Insight | undefined;

      beforeAll(() => {
        result = lookupInsight({ ...fixture, id: 0 });
      });

      it("returns nothing", () => {
        expect(result).toBeUndefined();
      });
    });
  });

  describe("insight is in the DB", () => {
    withDB((fixture) => {
      const insights: Insight[] = [
        { id: 1, brand: 0, createdAt: new Date(), text: "1" },
        { id: 2, brand: 0, createdAt: new Date(), text: "2" },
        { id: 3, brand: 1, createdAt: new Date(), text: "3" },
        { id: 4, brand: 4, createdAt: new Date(), text: "4" },
      ];

      let result: Insight | undefined;

      beforeAll(() => {
        fixture.insights.insert(
          insights.map((it) => ({
            ...it,
            createdAt: it.createdAt.toISOString(),
          })),
        );
        result = lookupInsight({ ...fixture, id: 3 });
      });

      it("returns the expected insight", () => {
        expect(result).toEqual(insights[2]);
      });
    });
  });
});
