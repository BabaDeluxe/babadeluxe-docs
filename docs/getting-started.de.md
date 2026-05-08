# Warum BabaDeluxe — Ein anderer Ansatz für KI-gestütztes Coding

Die meisten KI-Coding-Tools legen die Kontextverwaltung komplett in deine Hände. Du fügst eine Datei ein, referenzierst eine Funktion, erklärst der KI manuell, was sie wissen muss. Für einfache Fragen funktioniert das. In einer echten Codebasis bricht dieses Modell schnell zusammen — wo die Antwort auf deine Frage von einem Typ abhängt, der drei Dateien weiter definiert ist, einem Muster aus vor zwei Wochen, und einer Einschränkung in einer Config-Datei, die du heute noch nicht geöffnet hast.

BabaDeluxe basiert auf einer anderen Idee: **Die KI sollte mit dem nötigen Kontext ins Gespräch kommen — nicht erst, nachdem du ihn manuell zusammengestellt hast.** Nicht alles auf einmal, sondern genau das, was gerade relevant ist.

## Wie Kontext hier wirklich funktioniert

Sobald du BabaDeluxe in VS Code öffnest, baut die Erweiterung im Hintergrund einen live BM25-Volltext-Index deiner Codebasis auf. BM25 ist derselbe Ranking-Algorithmus, den Suchmaschinen verwenden — er berücksichtigt Termhäufigkeit, Dokumentlänge und Relevanzbewertung. Kein Semantic Search, keine Embeddings, keine API-Calls ins Netz. Schnell, lokal, sprachunabhängig.

Wenn du eine Nachricht schreibst, extrahiert BabaDeluxe die Schlüsselbegriffe aus deiner Frage, durchsucht den Index und bewertet jede Datei in deinem Repo. Dieses Ergebnis wird dann mit zwei weiteren Signalen kombiniert:

- **Git-Aktualität** — Dateien, die du kürzlich committet oder geändert hast, werden höher gewichtet, weil sie wahrscheinlich Teil deiner aktuellen Arbeit sind
- **Zuletzt geöffnete Dateien** — Dateien, die du in der aktuellen Session im Editor hattest

Das Ergebnis ist eine priorisierte Auswahl an Dateien, die tatsächlich relevant sein könnten. Diese werden automatisch als Kontextvorschläge angezeigt. Du kannst sie annehmen, ablehnen oder die volle manuelle Kontrolle über BabaContext übernehmen.

## BabaContext — Wenn du es besser weißt als der Algorithmus

Auto-Kontext ist eine Zeitersparnis, kein Zwang. Du kannst jederzeit beliebige Dateien, Ordner oder Code-Ausschnitte manuell pinnen — und gepinnte Inhalte bleiben für die gesamte Konversation erhalten. Pins werden in Echtzeit zwischen der Extension und dem Webview synchronisiert.

Das ergibt einen Workflow, der sich anfühlt wie Pair Programming mit jemandem, der deinen Code vorher wirklich gelesen hat.

## Bring Your Own Key

BabaDeluxe leitet deine API-Calls nicht durch einen eigenen Backend-Server. Du verbindest deine eigenen Keys (OpenAI, Anthropic oder kompatible Endpoints), diese werden mit einem Live-Test-Call validiert, bevor sie gespeichert werden, und ab dann gehen Anfragen direkt von deiner Maschine zum Anbieter. Kein Abo-Modell, das entscheidet, welche Modelle du nutzen darfst.

Die Key-Validierung läuft client-seitig — wenn der Key nicht funktioniert, erfährst du es sofort.

## Das Interface lebt in einem Webview

Die Chat-UI (`babadeluxe-webview`) ist eine vollständige Vue 3-Anwendung, eingebettet in die VS Code Sidebar. Sie unterstützt:

- **Streaming-Antworten** mit Live-Markdown-Rendering — Code-Blöcke, Syntax-Highlighting, Mermaid-Diagramme und KaTeX-Formeln werden inkrementell gerendert, während Tokens ankommen
- **Gesprächsverlauf** lokal in IndexedDB gespeichert (Dexie.js) — kein Server, kein Sync-Account erforderlich
- **Fuzzy-Suche** über vergangene Gespräche mittels Damerau-Levenshtein-Distanz, vollständig client-seitig
- **Prompt-Bibliothek** zum Speichern und Wiederverwenden häufig genutzter Prompts

Derselbe Webview funktioniert auch standalone im Browser. In diesem Modus wechselt die Authentifizierung auf Supabase OAuth (GitHub-Login).

## Installation

1. Installiere die **BabaDeluxe**-Extension aus dem VS Code Marketplace (oder build aus dem Quellcode — siehe [CONTRIBUTING.md](./CONTRIBUTING.md))
2. Öffne das BabaDeluxe-Sidebar-Panel (Activity Bar Icon)
3. Gib deinen API-Key in den Einstellungen ein — er wird sofort validiert
4. Starte eine Konversation. Auto-Kontext-Vorschläge erscheinen basierend auf deinem Workspace.

Keine Projektkonfigurationsdatei, kein `.babarc`, kein Initialisierungsschritt.

## Was es nicht ist

BabaDeluxe ist kein Agent, der selbstständig Befehle ausführt, Dateien bearbeitet oder ein Terminal hat. Es ist eine kontextbewusste Chat-Oberfläche — das Werkzeug, mit dem du ein Problem durchdenkst, unbekannten Code verstehst oder eine Implementierung planst, bevor du sie schreibst. Die Änderungen machst du selbst in deinem Editor.

Wer verstehen will, wie es unter der Haube funktioniert, findet die Details in [ARCHITECTURE.md](./ARCHITECTURE.md).
