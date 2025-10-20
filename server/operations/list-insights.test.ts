import { expect } from "jsr:@std/expect";
import { beforeAll, describe, it } from "jsr:@std/testing/bdd";
import type { Insight } from "$models/insight.ts";
import { withDB } from "../testing.ts";
import listInsights from "./list-insights.ts";

describe("listing insights in the database", () => {
  describe("nothing in the DB", () => {
    withDB((fixture) => {
      let result: Insight[];

      beforeAll(() => {
        result = listInsights(fixture);
      });

      it("returns empty result", () => {
        expect(result).toEqual([]);
      });
    });
  });

  describe("populated DB", () => {
    withDB((fixture) => {
      const insights: Insight[] = [
        { id: 1, brand: 0, createdAt: new Date(), text: "1" },
        { id: 2, brand: 0, createdAt: new Date(), text: "2" },
        { id: 3, brand: 1, createdAt: new Date(), text: "3" },
        { id: 4, brand: 4, createdAt: new Date(), text: "4" },
      ];

      let result: Insight[];

      beforeAll(() => {
        fixture.insights.insert(
          insights.map((it) => ({
            ...it,
            createdAt: it.createdAt.toISOString(),
          })),
        );
        result = listInsights(fixture);
      });

      it("returns non-empty result", () => {
        expect(result.length).toBeGreaterThan(0);
      });

      it("returns all insights in the DB", () => {
        expect(result).toEqual(insights);
      });
    });
  });
});
