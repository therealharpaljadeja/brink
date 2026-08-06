# Brink

> [!WARNING]
> Brink is experimental software and has not undergone an independent security
> audit. Use it with caution. It provides best-effort portfolio-risk information
> and is not financial advice, an oracle, or a substitute for checking Aave
> directly. Bugs, network failures, stale RPC data, application sleep, and
> protocol changes can produce incorrect information or delay or prevent an
> update. Do not rely on Brink as your only liquidation warning.

Brink is an open-source, read-only macOS notch app for monitoring Aave V3
positions on Monad mainnet. Add one or more public wallet addresses and keep the
selected account's health factor visible without opening a browser.

[Contributing](CONTRIBUTING.md) · [Support](SUPPORT.md) ·
[Security](SECURITY.md) · [Code of Conduct](CODE_OF_CONDUCT.md) ·
[MIT License](LICENSE)

## Demo

[▶ Watch Brink in action (MP4)](video/brink.mp4)

## What Brink does

- Watches public wallet addresses without requesting a private key.
- Reads aggregate Aave V3 account data directly from Monad JSON-RPC.
- Keeps a compact health dot and factor beside the MacBook notch.
- Expands on hover to show collateral, debt, available borrowing, LTV, and the
  liquidation threshold.
- Polls more frequently when risk increases.
- Uses DynamicNotchKit's floating presentation on Macs without a notch.

| Indicator | Health factor | Meaning |
| --- | ---: | --- |
| Green | 1.50 or higher, or no debt | Healthy |
| Orange | 1.10–1.49 | Watch closely |
| Red | Below 1.10 | At risk |
| Gray | No current data | Check the wallet or RPC connection |

Brink never signs or submits a transaction.

## Quick start

Requirements:

- macOS 14 or newer
- Xcode 16 or newer
- Git

Clone the repository and open the native app project:

```bash
git clone https://github.com/therealharpaljadeja/brink.git
cd brink
open Brink.xcodeproj
```

Select the **Brink** scheme and **My Mac**, then press Run (⌘R). Do not open
`Package.swift` for normal app development; Xcode will display the package
aggregate instead of the macOS app target.

Use the heart icon in the menu bar or the gear in the expanded notch to open
Settings and add a `0x` wallet address. Addresses and the optional RPC override
are stored locally in UserDefaults.

Command-line development is also supported:

```bash
swift test
swift run Brink
```

Before opening a pull request, run both validation paths:

```bash
swift test
xcodebuild -project Brink.xcodeproj -scheme Brink \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for focused workflows, review
expectations, and protocol-integration requirements.

## Repository

```text
Brink.xcodeproj/        Native macOS application target and shared scheme
Sources/
├── Brink/              SwiftUI/AppKit app shell and DynamicNotchKit views
└── BrinkCore/          Aave models, RPC decoding, persistence, and polling
Tests/BrinkCoreTests/   Deterministic unit tests with no live-network requirement
Package.swift           SwiftPM development and test harness
video/brink.mp4         Product demo
.github/                CI, dependency updates, issue forms, and PR template
```

The core layer has no dependency on DynamicNotchKit. The app target owns the
notch and Settings windows; `BrinkCore` owns address validation, JSON-RPC,
account-data decoding, health tiers, persistence, and polling.

## Data source and privacy

Brink calls Aave V3 Pool `getUserAccountData(address)` over Monad JSON-RPC. The
defaults are Monad chain ID 143, `https://rpc.monad.xyz`, and Aave V3 Pool
`0x69a5F9AD4f96ebf0a0C792dD42a01cC5C0102fef`.

Watched wallet addresses are public blockchain identifiers, but they can still
be sensitive. Brink stores them locally and sends them to the configured RPC
provider during refresh. Do not include someone else's address in screenshots,
logs, fixtures, or bug reports without permission.

## Contributing

Contributions are welcome across Swift, accessibility, design, documentation,
testing, and carefully reviewed protocol support. Start with
[CONTRIBUTING.md](CONTRIBUTING.md) and use the structured issue forms for bugs,
features, or protocol integrations.

Do not report vulnerabilities publicly. Follow [SECURITY.md](SECURITY.md) and
use GitHub private vulnerability reporting.

## License

[MIT](LICENSE)
