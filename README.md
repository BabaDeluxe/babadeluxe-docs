# babadeluxe-docs

<p align="left">
  <img src="https://img.shields.io/badge/license-EUPL%201.2-6a5acd?style=flat-rounded" alt="license">
  <img src="https://img.shields.io/topic/babadeluxe-badge" alt="babadeluxe">
</p>

> **Shared documentation for the BabaDeluxe ecosystem.** Used as a Git submodule in `babadeluxe-vscode` and `babadeluxe-webview`.

## Contents

| File | Audience | Description |
| :--- | :--- | :--- |
| [docs/getting-started.md](docs/getting-started.md) | Users | Why BabaDeluxe — product philosophy and getting started guide (EN) |
| [docs/getting-started.de.md](docs/getting-started.de.md) | Users | Deutschsprachige Version des Getting Started Guide |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Contributors | Full architecture overview: context pipeline, auth, webview bridge, submodule workflow |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | Contributors | Git workflow, branch strategy, commit conventions |
| [docs/ERROR_HANDLING_GUIDELINE.md](docs/ERROR_HANDLING_GUIDELINE.md) | Contributors | Error handling patterns and `neverthrow` usage |
| [docs/TESTING_GUIDELINE.md](docs/TESTING_GUIDELINE.md) | Contributors | Testing strategy, Vitest and Playwright conventions |
| [docs/TEST_CLASSIFICATION.md](docs/TEST_CLASSIFICATION.md) | Contributors | Test type classification reference |

## Using as a submodule

Both `babadeluxe-vscode` and `babadeluxe-webview` include this repo as a submodule at `babadeluxe-docs/`. After updating docs here, bump the pointer in the parent repos:

```bash
# In babadeluxe-vscode or babadeluxe-webview:
git submodule update --remote babadeluxe-docs
git add babadeluxe-docs
git commit -m "chore: :wrench: Updated babadeluxe-docs submodule"
git push
```

Or use `manage-git-submodules.ps1` in [babadeluxe-scripts](https://github.com/BabaDeluxe/babadeluxe-scripts) to update all parent repos at once.

## License

This project is licensed under the **European Union Public License 1.2 (EUPL-1.2)**. See [LICENSE](./LICENSE.md) for the full text.

---

**BabaDeluxe** — _Redefining the Future of Software Development._
