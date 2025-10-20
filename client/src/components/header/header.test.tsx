import { describe, expect, it } from "vitest";
import { Header, HEADER_TEXT } from "./header.tsx";
import { render } from "@testing-library/react";

describe("header", () => {
  it("renders", () => {
    const { getByText } = render(<Header />);
    expect(getByText(HEADER_TEXT)).toBeTruthy();
  });
});
