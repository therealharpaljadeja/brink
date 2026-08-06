# Contributing to Brink

Thanks for helping make Brink safer, clearer, and more useful. Contributions
are welcome across Swift, macOS accessibility, design, documentation, testing,
and protocol research.

Brink is experimental and has not undergone an independent security audit. It
presents liquidation-risk information, and a small decoding, scaling, or
threshold mistake can mislead users. Favor focused pull requests, cited
constants, deterministic tests, and explicit failure behavior.

## Before you start

- Read the architecture and privacy notes in [README.md](README.md).
- Search existing issues before opening a new one.
- Use [SECURITY.md](SECURITY.md) for vulnerabilities instead of a public issue.
- Never include private keys, seed phrases, private RPC URLs, authentication
  headers, or another person's wallet activity in code, fixtures, logs, or
  screenshots.
- Open an issue before starting a new network, protocol, contract, or data-source
  integration. Agree on authoritative addresses, units, failure behavior, and
  test evidence before implementation.

Small documentation corrections and focused test improvements may go straight
to a pull request. Larger behavioral or UI changes benefit from an issue first.

## Development setup

Requirements:

- macOS 14 or newer
- Xcode 16 or newer
- Git

```bash
git clone https://github.com/therealharpaljadeja/brink.git
cd brink
open Brink.xcodeproj
```

Select the **Brink** scheme and **My Mac**. Xcode resolves DynamicNotchKit with
Swift Package Manager. The app is a menu-bar accessory, so a normal document
window does not appear when it starts.

For core development:

```bash
swift test
swift run Brink
```

## Project layout

```text
Sources/Brink/       App lifecycle, notch presentation, SwiftUI, and Settings
Sources/BrinkCore/   RPC, ABI decoding, models, persistence, and polling
Tests/               Deterministic unit tests for BrinkCore
Brink.xcodeproj/     Native app target and shared Brink scheme
```

Keep protocol and network logic in `BrinkCore`. Keep DynamicNotchKit and AppKit
dependencies in the app layer. New logic should be testable without presenting
a window or contacting a live RPC endpoint.

## Validation

Run the core test suite:

```bash
swift test
```

Then compile the real macOS app target without requiring a signing identity:

```bash
xcodebuild -project Brink.xcodeproj -scheme Brink \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

For user-visible changes, also follow [MANUAL_TESTING.md](MANUAL_TESTING.md).

## Protocol and RPC changes

Contract integrations affect the meaning of the number Brink shows. A proposal
must identify:

1. The protocol version and network.
2. The canonical, primary source for every chain and contract address.
3. Function signatures, selectors, return layout, decimals, and sentinel values.
4. Behavior for no debt, empty portfolios, reverts, timeouts, malformed data,
   rate limits, and stale snapshots.
5. Sanitized fixtures and deterministic decoder tests.
6. How users can independently verify displayed values.
7. Privacy implications of any RPC, API, analytics, or indexing service.

Never update contract addresses or ABI assumptions from memory. Cite a canonical
address book, verified deployment, protocol documentation, or on-chain evidence
in the issue and source comment.

## Pull requests

- Keep each pull request focused on one problem.
- Link the relevant issue with `Closes #123` when one exists.
- Explain user-visible behavior and risk impact.
- Add or update tests for decoding, scaling, thresholds, persistence, or polling
  behavior.
- Include before-and-after screenshots for visible changes. Redact wallet data.
- Update documentation when setup or behavior changes.
- Run both required validation commands, or explain why a check could not run.
- Do not commit `.build`, DerivedData, user Xcode data, credentials, or private
  configuration.

Maintainers may ask for a smaller change set or stronger protocol evidence
before reviewing implementation details.

## Community

Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). General
setup and architecture questions belong in GitHub Discussions when enabled;
reproducible bugs and scoped proposals belong in Issues.
