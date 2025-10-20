import { describe, expect, it } from "vitest";
import { cx } from "./cx.ts";

describe("cx", () => {
  it("joins strings", () => {
    expect(cx("foo", "bar")).toEqual("foo bar");
  });
  it("omits falsey values", () => {
    expect(cx("foo", undefined, "baz")).toEqual("foo baz");
  });
});
