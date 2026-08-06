# Instructions for AI coding agents

Read [CONTRIBUTING.md](CONTRIBUTING.md) before changing code.

- Do not add or change a protocol, network, contract address, selector, ABI
  layout, decimal scale, or health threshold without an approved issue and a
  canonical source.
- Keep RPC and decoding logic in `BrinkCore`; keep AppKit, SwiftUI, and
  DynamicNotchKit integration in the app layer.
- Add deterministic tests for behavior changes. Tests must not require a funded
  wallet or live RPC access.
- Run `swift test` and the unsigned `xcodebuild` command from
  `CONTRIBUTING.md` before presenting a change as complete.
- Never include secrets, private RPC URLs, or unrelated wallet data in output,
  fixtures, screenshots, commits, issues, or pull requests.
