# Why BabaDeluxe — A Different Kind of AI Coding Assistant

Most AI coding tools put you in charge of context. You paste a file, you reference a function, you manually tell the AI what it needs to know. That works fine for simple questions. It breaks down fast when you're deep in a real codebase — where the answer to your question depends on a type defined three files away, a pattern established two weeks ago, and a constraint buried in a config file you haven't opened today.

BabaDeluxe was built around a different idea: **the AI should come to the conversation already knowing what's relevant.** Not everything — just the parts that actually matter for what you're asking right now.

## How Context Actually Works Here

When you open BabaDeluxe in VS Code, it quietly builds a live BM25 full-text index of your codebase in the background. BM25 is the same ranking algorithm used by search engines — it understands term frequency, document length, and relevance weighting. It's not semantic search (no embeddings, no API calls), but it's fast, local, and works on any language.

When you type a message, BabaDeluxe extracts the key terms from your question, runs them against the index, and scores every file in your repo. It then blends that score with two more signals:

- **Git recency** — files you've committed or changed recently score higher, because they're probably part of whatever you're actively working on
- **Recent opens** — files you've had open in the editor in the current session

The result is a ranked shortlist of files that are genuinely likely to be relevant. These get surfaced as context suggestions automatically. You can accept them, dismiss them, or take full manual control by pinning exactly what you want via BabaContext.

## BabaContext — When You Know Better Than the Algorithm

Auto-context is a time-saver, not a cage. You can pin any file, folder, or code selection manually — and pinned context stays across the entire conversation. Pins are synced between the extension and the webview in real time, so what you see in the sidebar is always accurate.

This gives you a workflow that feels like pair programming with someone who actually read your code before sitting down.

## Bring Your Own Key

BabaDeluxe doesn't proxy your API calls through its own backend. You connect your own keys (OpenAI, Anthropic, or any compatible endpoint), they get validated with a live test call before being stored, and from that point on requests go directly from your machine to the provider. There's no subscription tier deciding which models you're allowed to use.

Key validation happens client-side — if the key doesn't work, you find out immediately instead of mid-conversation.

## The Interface Lives in a Webview

The chat UI (`babadeluxe-webview`) is a full Vue 3 application embedded in VS Code's sidebar. It handles:

- **Streaming responses** with live Markdown rendering — code blocks, syntax highlighting, Mermaid diagrams, and KaTeX math all render incrementally as tokens arrive
- **Conversation history** stored locally in IndexedDB (Dexie.js) — no server, no sync account required
- **Fuzzy search** over your past conversations using Damerau-Levenshtein distance, entirely client-side
- **Prompt library** for saving and reusing prompts you rely on

The same webview also works standalone in a browser. In that mode, authentication switches to Supabase OAuth (GitHub login), so you can use BabaDeluxe outside of VS Code if you want.

## Installing

1. Install the **BabaDeluxe** extension from the VS Code marketplace (or build from source — see [CONTRIBUTING.md](./CONTRIBUTING.md))
2. Open the BabaDeluxe sidebar panel (Activity Bar icon)
3. Enter your API key in Settings — it will be validated immediately
4. Start a conversation. Auto-context suggestions will appear based on what's in your workspace.

That's it. No project config file, no `.babarc`, no workspace initialization step.

## What It's Not

BabaDeluxe is not an agent that runs commands, edits files autonomously, or has a terminal. It's a context-aware chat interface — the kind of tool you use to think through a problem, understand unfamiliar code, or draft an implementation before you write it. The edits happen in your editor, driven by you.

If you want to understand what's happening under the hood, read [ARCHITECTURE.md](./ARCHITECTURE.md).
