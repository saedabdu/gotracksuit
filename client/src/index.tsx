import { createRoot } from "react-dom/client";
import { App } from "./routes/app.tsx";
import "./styles/index.ts";

createRoot(document.getElementById("root")!).render(<App />);
