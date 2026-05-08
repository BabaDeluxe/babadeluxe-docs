# Mermaid Diagram Theme

All Mermaid diagrams across BabaDeluxe repositories use a consistent **dark purple cyberpunk** theme. Copy the relevant `%%{init}%%` block below as the first line of any new diagram.

---

## Flowchart / Graph

Use for `graph TD`, `graph LR`, `flowchart TD`, `flowchart LR`.

````markdown
```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'background': '#13111a', 'primaryColor': '#2a1758', 'primaryTextColor': '#e2d9f3', 'primaryBorderColor': '#7c3aed', 'lineColor': '#7c3aed', 'secondaryColor': '#1a0f3a', 'tertiaryColor': '#0f1a2a', 'edgeLabelBackground': '#1a1030', 'clusterBkg': '#1a1030', 'clusterBorder': '#4c1d95', 'titleColor': '#e2d9f3', 'fontFamily': 'monospace'}}}%%
graph TD
    classDef primary  fill:#2a1758,stroke:#7c3aed,stroke-width:2px,color:#e2d9f3
    classDef secondary fill:#1a0f3a,stroke:#4c1d95,stroke-width:2px,color:#c4b5fd
    classDef accent   fill:#0f1a2a,stroke:#0891b2,stroke-width:2px,color:#67e8f9
    classDef storage  fill:#1a1a0a,stroke:#d97706,stroke-width:2px,color:#fcd34d
    classDef success  fill:#0f2a1a,stroke:#059669,stroke-width:2px,color:#6ee7b7
```
````

---

## Sequence Diagram

Use for `sequenceDiagram`.

````markdown
```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'background': '#13111a', 'primaryColor': '#2a1758', 'primaryTextColor': '#e2d9f3', 'primaryBorderColor': '#7c3aed', 'lineColor': '#7c3aed', 'secondaryColor': '#1a0f3a', 'tertiaryColor': '#0f1a2a', 'edgeLabelBackground': '#1a1030', 'actorBkg': '#2a1758', 'actorBorder': '#7c3aed', 'actorTextColor': '#e2d9f3', 'actorLineColor': '#7c3aed', 'signalColor': '#c4b5fd', 'signalTextColor': '#e2d9f3', 'labelBoxBkgColor': '#1a0f3a', 'labelBoxBorderColor': '#4c1d95', 'labelTextColor': '#c4b5fd', 'loopTextColor': '#e2d9f3', 'noteBkgColor': '#1a0f3a', 'noteTextColor': '#c4b5fd', 'noteBorderColor': '#4c1d95', 'activationBkgColor': '#4c1d95', 'activationBorderColor': '#7c3aed', 'sequenceNumberColor': '#e2d9f3', 'fontFamily': 'monospace'}}}%%
sequenceDiagram
```
````

`rect` block fills for scenario grouping:

```
rect rgb(26, 15, 58)   ← purple scenario
rect rgb(15, 26, 42)   ← navy/teal scenario
```

---

## Color Palette Reference

| Role | `classDef` name | Fill | Border | Text |
| :--- | :--- | :--- | :--- | :--- |
| Primary (Vue components, main nodes) | `primary` | `#2a1758` | `#7c3aed` | `#e2d9f3` |
| Secondary (backend, services) | `secondary` | `#1a0f3a` | `#4c1d95` | `#c4b5fd` |
| Accent (VS Code bridge, LLM, external) | `accent` | `#0f1a2a` | `#0891b2` | `#67e8f9` |
| Storage / infra (DB, queue, index) | `storage` | `#1a1a0a` | `#d97706` | `#fcd34d` |
| Output / success | `success` | `#0f2a1a` | `#059669` | `#6ee7b7` |
| Background | — | `#13111a` | — | — |
| Edges & sequence lines | — | — | `#7c3aed` | — |
| Font | — | — | — | `monospace` |

---

## Why `theme: base`?

Mermaid's built-in `dark` theme applies its own opinionated defaults on top of `themeVariables`, which causes conflicts with custom colors. Using `base` ensures `themeVariables` are applied cleanly with no interference.

---

## Adding a New Diagram

1. Pick the correct init block above (flowchart or sequence)
2. Assign `classDef` names from the palette table to your nodes
3. For `rect` blocks in sequence diagrams, use the purple/navy fills above
4. Do **not** invent new colors — if a new role is genuinely needed, add it to this file first
