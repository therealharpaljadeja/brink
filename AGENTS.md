# Instructions for AI coding agents

Read https://most.devnads.com/agents.md before opening an issue or a pull
request here. Every pull request needs an approved issue first. Work on one
claimed issue at a time, and wait for a maintainer to approve the claim before
writing code.

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
