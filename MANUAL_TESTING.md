# Manual testing

Run this checklist for changes to the notch, Settings, wallet switching,
persistence, polling, or displayed portfolio values. Use only public addresses
you are comfortable sending to the configured RPC provider.

## Before testing

```bash
swift test
xcodebuild -project Brink.xcodeproj -scheme Brink \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

Open `Brink.xcodeproj`, select **Brink** and **My Mac**, then run the app.

## 1. First launch

1. Start with no saved wallet.
2. Confirm a gray compact indicator appears beside the notch.
3. Hover over it and confirm the expanded view explains that no wallet is
   configured.
4. Select **Open Settings**.

Expected: the Settings window activates and appears above other normal windows
on the current desktop.

## 2. Address validation

Try adding:

- an empty value;
- an address without `0x`;
- a value shorter than 42 characters;
- a value containing a non-hexadecimal character;
- a valid 42-character public address;
- the same valid address a second time.

Expected: invalid and duplicate values are rejected with a useful message. A
valid address is stored and begins refreshing without restarting the app.

## 3. Portfolio comparison

Using an address you control, compare Brink with Aave's official interface at
approximately the same block. Check:

- total collateral;
- total debt;
- available borrowing;
- LTV;
- liquidation threshold;
- health factor.

Small display-rounding differences are acceptable. Scaling, tier, or material
value differences are release blockers.

For a wallet with no debt, confirm Brink displays an infinite health factor and
a healthy state rather than decoding Aave's maximum-uint sentinel as a number.

## 4. Multiple wallets

1. Add two wallets with different health factors.
2. Switch between them in the expanded notch.
3. Observe the compact dot and number after each selection.
4. Remove the selected wallet.

Expected: expanded and compact views always show the same selected wallet. The
selection falls back to a remaining wallet after removal. Background polling may
still use the riskiest wallet to choose its refresh cadence.

## 5. Persistence

1. Add wallets and optionally change the RPC URL.
2. Quit Brink from its menu-bar item.
3. Run Brink again.

Expected: wallets, labels, selection fallback, and RPC URL remain usable. No
private key, signing request, or transaction permission is requested.

## 6. Failure behavior

Set an unreachable HTTP(S) RPC URL and refresh.

Expected: Brink does not crash or replace the selected wallet with another one.
It presents an error/no-data state rather than a healthy numeric value. Restore
the default RPC URL and confirm a refresh recovers.

## 7. Displays and lifecycle

- On a MacBook with a notch, verify compact, hover-expand, and hover-collapse.
- On a display without a notch, verify DynamicNotchKit's floating presentation.
- Put the Mac to sleep and wake it, then confirm polling resumes.
- Open Settings repeatedly and confirm one retained window comes to the front.

Redact wallet addresses and portfolio amounts from screenshots attached to a
pull request unless the data is intentionally public and belongs to you.
