# Accessibility Guideline

This document governs ARIA usage, keyboard navigation, focus management, and screen-reader semantics across the BabaDeluxe webview. Follow it before shipping any interactive component.

---

## ⛔ Absolute Prohibitions

**Read these first. These rules have ZERO exceptions.**

### 1. NEVER Put `aria-hidden="true"` on an Interactive Element

`aria-hidden="true"` removes an element — and its entire subtree — from the accessibility tree. Any `aria-label`, `aria-expanded`, or `aria-pressed` on a hidden element is silently discarded by assistive technology.

❌ **Wrong:**

```vue
<button aria-hidden="true" aria-label="Toggle panel" @click="toggle" />
```

✅ **Right:**

```vue
<button aria-label="Toggle panel" :aria-expanded="isOpen" @click="toggle" />
```

Only use `aria-hidden="true"` on **purely decorative** elements: icons, dividers, or illustrations that duplicate adjacent visible text.

---

### 2. NEVER Use a `<div @click>` as the Only Interaction Path

A `<div>` with only `@click` is invisible to keyboard users and screen readers.

❌ **Wrong:**

```vue
<div @click="handleSelect">{{ item.title }}</div>
```

✅ **Right:**

```vue
<div
  role="button"
  :tabindex="0"
  @click="handleSelect"
  @keydown.enter.prevent="handleSelect"
  @keydown.space.prevent="handleSelect"
>
  {{ item.title }}
</div>
```

Prefer a native `<button>` whenever possible — it gets keyboard support and role for free.

---

### 3. NEVER Use `:title` as the Accessible Name for a Button

`:title` is a tooltip. Most screen readers ignore it as an accessible name, and it never works on touch devices.

❌ **Wrong:**

```vue
<BaseButton :title="saveHint" icon="i-bi:check" />
```

✅ **Right:**

```vue
<BaseButton :aria-label="saveHint" icon="i-bi:check" />
```

---

### 4. NEVER Use `aria-label` on a Plain `<div>` Without a Role

`aria-label` is only meaningful on elements with an implicit or explicit ARIA role. On a plain `<div>` it is silently ignored.

❌ **Wrong:**

```vue
<div aria-label="Result count">{{ results.length }} results</div>
```

✅ **Right:**

```vue
<div role="status" aria-live="polite">{{ results.length }} results</div>
```

---

## 1. The Keyboard Contract

Every interactive element must fulfil this contract:

| Requirement | Implementation |
| :--- | :--- |
| Reachable via Tab | `tabindex="0"` or native focusable element |
| Activatable via Enter | `@keydown.enter.prevent="handler"` |
| Activatable via Space | `@keydown.space.prevent="handler"` (buttons / options) |
| Dismissable via Escape | `onKeyStroke('Escape', ...)` in modals / dropdowns |
| Visible focus ring | `:focus-visible` styles — never `outline: none` without a replacement |
| 44×44 px tap target | Padding-inclusive — verify on a 375 px viewport |

**Disabled elements:** Set `:tabindex="-1"` and `aria-disabled="true"` (not the HTML `disabled` attribute unless it is a native form control). This keeps the element reachable for AT announcement while blocking interaction.

---

## 2. ARIA Roles

Use semantic HTML first. Add ARIA only when native elements are unavailable.

### 2.1 Lists of Selectable Items

```vue
<div role="listbox" aria-label="Search results">
  <div
    v-for="(item, index) in items"
    role="option"
    :tabindex="0"
    :aria-selected="index === highlightedIndex"
    @click="select(item)"
    @keydown.enter.prevent="select(item)"
    @keydown.space.prevent="select(item)"
  >
    {{ item.label }}
  </div>
</div>
```

### 2.2 Dropdowns / Context Menus

The trigger button always announces its intent:

```vue
<button
  aria-haspopup="menu"
  :aria-expanded="isOpen"
  aria-label="Open options"
  @click="toggle"
>
```

| Dropdown style | Container role |
| :--- | :--- |
| Context / action menu | `role="menu"` |
| Select-style picker | `role="listbox"` |

### 2.3 Dialogs / Modals

```vue
<div
  role="dialog"
  aria-modal="true"
  :aria-labelledby="titleId"
  tabindex="-1"
  ref="modalRef"
>
  <h2 :id="titleId">…</h2>
```

- `titleId` must be **stable** — use Vue 3.5+ `useId()`. Never `Math.random()`.
- Move focus into the modal on open:

```ts
watch(
  () => props.isShown,
  async (shown) => {
    if (shown) {
      await nextTick()
      modalRef.value?.focus()
    }
  }
)
```

### 2.4 Live Regions

| Scenario | role / `aria-live` |
| :--- | :--- |
| Info / success toasts | `role="status"` + `aria-live="polite"` |
| **Error toasts** | `role="alert"` + `aria-live="assertive"` |
| Count / status updates | `role="status"` + `aria-live="polite"` |
| Loading spinners | `role="status"` + `aria-label="Loading"` |

```vue
<!-- BaseToast.vue -->
:role="type === 'error' ? 'alert' : 'status'"
:aria-live="type === 'error' ? 'assertive' : 'polite'"
```

### 2.5 Articles / Landmark Regions

`<article>` is a landmark. Give it a label so AT can distinguish messages:

```vue
<article :aria-label="role === 'user' ? 'Your message' : 'Assistant message'">
```

---

## 3. Focus Management

### 3.1 Modals

Move focus **into** the modal when it opens. Return focus to the trigger element when it closes. The modal container must have `tabindex="-1"` for programmatic focus to work.

### 3.2 Dropdowns

When a dropdown opens the trigger should reflect `aria-expanded="true"`. When it closes (Escape or selection), focus returns to the trigger.

### 3.3 Hover-Only UI

Actions revealed only on hover are invisible to keyboard users. Always pair hover reveal with focus-within reveal:

```vue
class="opacity-0 group-hover:opacity-100 group-focus-within:opacity-100"
```

---

## 4. Images and Icons

### 4.1 Icon-Only Buttons

Every icon-only button **must** have an `aria-label`. `data-testid` is not a substitute.

```vue
<BaseButton icon="i-bi:pencil-square" aria-label="Edit conversation title" />
```

### 4.2 Decorative Icons

Icons that duplicate adjacent visible text are decorative. Hide them from AT:

```vue
<i class="i-bi:check-circle" aria-hidden="true" />
<span>Saved</span>
```

### 4.3 Avatar Fallback Placeholders

When an image fails to load or is replaced by an icon, the wrapper must carry the accessible name:

```vue
<div role="img" aria-label="User avatar">
  <i class="i-bi:person-circle" />
</div>
```

---

## 5. Forms

- Every `<input>` must have an associated `<label>` via `for`/`id` or `aria-labelledby`.
- Use `useId()` (Vue 3.5+) to generate stable IDs — never `Math.random()`.
- Validation errors must be inline, next to the field, and linked via `aria-describedby`.
- Group related controls with `<fieldset>` + `<legend>`.

---

## 6. `data-testid` Conventions

`data-testid` values are consumed by Playwright and must be unique within a list.

| Pattern | Rule |
| :--- | :--- |
| Single element | Static string: `data-testid="submit-button"` |
| Items in a list | Keyed: `:data-testid="\`prompt-item-${prompt.id}\`"` |
| Nested within a list item | `:data-testid="\`prompt-delete-${prompt.id}\`"` |

❌ **Wrong — all items share the same testid, `.nth(0)` is fragile:**

```vue
<div v-for="prompt in prompts" data-testid="prompt-item">
```

✅ **Right:**

```vue
<div v-for="prompt in prompts" :data-testid="`prompt-item-${prompt.id}`">
```

---

## 7. The `ScrollToBottomButton` Component

`ScrollToBottomButton.vue` is a mobile-first fixed FAB that appears when the user has scrolled away from the bottom of a scrollable region and disappears once they are near the bottom.

### Usage

Pass the scrollable container element via `:scroll-el`. If omitted the component falls back to `window`.

```vue
<template>
  <div ref="listRef" class="overflow-y-auto h-full">
    <slot />
    <ScrollToBottomButton :scroll-el="listRef ?? undefined" />
  </div>
</template>

<script setup lang="ts">
import { useTemplateRef } from 'vue'
import ScrollToBottomButton from '@/components/ScrollToBottomButton.vue'

const listRef = useTemplateRef<HTMLElement>('listRef')
</script>
```

### Props

| Prop | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `scrollEl` | `HTMLElement \| null` | `null` | Scrollable container. Falls back to `window` when `null`. |
| `bottomOffsetPx` | `number` | `16` | Distance from the viewport bottom edge in px. Stacks with `safe-area-inset-bottom` automatically. |
| `rightOffsetPx` | `number` | `16` | Distance from the right edge in px. |
| `showAfterPx` | `number` | `120` | Scroll distance from the top required before the button appears. |
| `hideWithinPx` | `number` | `40` | Distance from the bottom at which the button hides. |

### Accessibility

- `aria-label="Scroll to bottom"` — announced by screen readers.
- `data-testid="scroll-to-bottom-button"` — Playwright selector.
- Minimum 44×44 px tap target enforced via inline `minWidth` / `minHeight`.
- `safe-area-inset-bottom` respected via `max(env(...), Npx)` so the button clears the iOS home indicator.
- Scroll is performed via an imperative `scrollTo({ behavior: 'smooth' })` on the target element — not relying on the global `scroll-behavior: smooth` CSS property, which can cause unwanted side effects in some scroll contexts.
- Appearance / disappearance uses a `<Transition>` with `opacity` + `translateY` so `prefers-reduced-motion` is handled by the global base CSS `transition-duration: 0.01ms` override.

---

## 8. Checklist

Before shipping an interactive component:

- [ ] No `aria-hidden="true"` on elements that can be clicked, focused, or activated.
- [ ] No `<div @click>` without `role`, `tabindex`, and `@keydown` handlers.
- [ ] Icon-only buttons have `aria-label` (not `:title`, not just `data-testid`).
- [ ] `aria-label` is only used on elements with a role.
- [ ] Modals have `tabindex="-1"` on the container and move focus on open.
- [ ] Modal `titleId` uses `useId()` — never `Math.random()`.
- [ ] Dropdowns have `aria-haspopup` on the trigger and `role="menu"` / `role="listbox"` on the panel.
- [ ] Error toasts use `role="alert"` + `aria-live="assertive"`.
- [ ] Spinners have `role="status"` + `aria-label`.
- [ ] Hover-revealed actions are also visible on `focus-within`.
- [ ] Avatar fallback icons have `role="img"` + `aria-label` on their wrapper.
- [ ] List item `data-testid` values are keyed to a unique ID.
- [ ] Tested with keyboard-only navigation (Tab, Enter, Space, Escape).
