# Harness Memory (global)

Cross-project knowledge maintained by the harness maintainers.

## Known Gotchas
- TypeScript compatibility on Node 20: use `typescript@5.6.3` +
  `vue-tsc@2.1.10` + `@types/node`. Newer versions break the typecheck
  toolchain on Node 20 — pin these exact versions.
