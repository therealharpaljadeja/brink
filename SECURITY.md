# Security policy

Brink is experimental, unaudited, best-effort portfolio-monitoring software.
Use it with caution. Incorrect or delayed data can influence financial decisions
even though Brink never signs or submits transactions. Do not rely on Brink as
your only liquidation warning or as a substitute for checking Aave directly.

## Supported versions

Security and correctness fixes are applied to the latest code on the default
branch. Older builds may contain stale protocol addresses or assumptions and are
not supported.

## Reporting a vulnerability

Do not open a public issue, discussion, or pull request for a suspected
vulnerability.

Use GitHub private vulnerability reporting:

1. Open the repository's **Security** tab.
2. Select **Report a vulnerability**.
3. Include affected files, impact, prerequisites, and a minimal reproduction.

If private reporting is unavailable, contact a maintainer through a non-public
channel on their GitHub profile and request a secure reporting channel. Do not
send exploit details in the first message.

Remove wallet addresses, private RPC URLs, credentials, and personal information
from reports unless each item is essential and you have permission to share it.

## In scope

- Incorrect health-factor, collateral, debt, LTV, or threshold decoding.
- Address-validation or ABI-encoding flaws that query the wrong account.
- Stale or failed data presented as current and healthy.
- Wallet-address or RPC-credential exposure.
- Unsafe URL handling or unexpected network destinations.
- Supply-chain or code-signing issues in this repository.

General support questions, public-chain data, and feature requests are not
security reports.

We aim to acknowledge complete reports within three business days and provide a
status update within fourteen days. These are response targets, not guarantees.
