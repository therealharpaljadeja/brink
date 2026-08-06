import AppKit
#if canImport(BrinkCore)
import BrinkCore
#endif
import SwiftUI

struct CompactHealthDot: View {
    @ObservedObject var store: PortfolioStore

    var body: some View {
        Circle()
            .fill(store.selectedTier.color)
            .frame(width: 9, height: 9)
            .shadow(color: store.selectedTier.color.opacity(0.65), radius: 4)
            .padding(.horizontal, 10)
            .accessibilityLabel("Aave health: \(store.selectedTier.label)")
    }
}

struct CompactHealthText: View {
    @ObservedObject var store: PortfolioStore

    var body: some View {
        Text(store.selectedSnapshot?.healthFactor.healthText ?? "—")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(store.selectedTier.color)
            .monospacedDigit()
            .padding(.horizontal, 9)
    }
}

struct ExpandedNotchView: View {
    @ObservedObject var store: PortfolioStore

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Circle()
                    .fill(store.selectedTier.color)
                    .frame(width: 10, height: 10)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Brink")
                        .font(.headline)
                    Text(store.selectedWallet?.displayName ?? "Add a wallet in Settings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if store.isRefreshing {
                    ProgressView().controlSize(.small)
                } else {
                    Button { Task { await store.refresh() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.plain)
                    .disabled(store.wallets.isEmpty)
                }
                Button {
                    NotificationCenter.default.post(name: .openBrinkSettings, object: nil)
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .buttonStyle(.plain)
                .help("Settings")
            }

            if store.wallets.isEmpty {
                EmptyPortfolioView()
            } else if let snapshot = store.selectedSnapshot {
                PortfolioSummary(snapshot: snapshot)
            } else if let wallet = store.selectedWallet, let error = store.errors[wallet.id] {
                VStack(spacing: 6) {
                    Image(systemName: "wifi.exclamationmark").foregroundStyle(.orange)
                    Text(error).font(.caption).multilineTextAlignment(.center).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 90)
            } else {
                ProgressView("Loading portfolio…")
                    .frame(maxWidth: .infinity, minHeight: 90)
            }

            if store.wallets.count > 1 {
                Picker("Wallet", selection: $store.selectedWalletID) {
                    ForEach(store.wallets) { wallet in
                        Text(wallet.displayName).tag(Optional(wallet.id))
                    }
                }
                .labelsHidden()
                .controlSize(.small)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .frame(width: 350)
    }
}

private struct EmptyPortfolioView: View {
    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: "wallet.pass").font(.title2).foregroundStyle(.secondary)
            Text("No wallet is being watched")
                .font(.subheadline.weight(.medium))
            Text("Add a public address to begin monitoring.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                NotificationCenter.default.post(name: .openBrinkSettings, object: nil)
            } label: {
                Label("Open Settings", systemImage: "gearshape")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }
}

private struct PortfolioSummary: View {
    let snapshot: AccountSnapshot

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("HEALTH FACTOR").font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                    Text(snapshot.healthFactor.healthText)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(snapshot.tier.color)
                        .monospacedDigit()
                }
                Spacer()
                Text(snapshot.tier.label.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(snapshot.tier.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(snapshot.tier.color.opacity(0.14), in: Capsule())
            }

            Divider().opacity(0.4)

            HStack(spacing: 0) {
                Metric(label: "Supplied", value: snapshot.totalCollateralUSD.usdText)
                Metric(label: "Borrowed", value: snapshot.totalDebtUSD.usdText)
                Metric(label: "Available", value: snapshot.availableBorrowsUSD.usdText)
            }

            HStack {
                Label("LTV \(snapshot.loanToValuePercent.percentText)", systemImage: "percent")
                Spacer()
                Text("Liq. threshold \(snapshot.liquidationThresholdPercent.percentText)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }
}

private struct Metric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.system(.subheadline, design: .rounded).weight(.semibold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension HealthTier {
    var color: Color {
        switch self {
        case .safe: return .green
        case .warning: return .orange
        case .critical: return .red
        case .unavailable: return .gray
        }
    }

    var label: String {
        switch self {
        case .safe: return "Healthy"
        case .warning: return "Watch"
        case .critical: return "At risk"
        case .unavailable: return "No data"
        }
    }
}

extension Optional where Wrapped == Decimal {
    var healthText: String {
        guard let self else { return "∞" }
        return self.formatted(.number.precision(.fractionLength(2)))
    }
}

extension Decimal {
    var healthText: String { Optional(self).healthText }
    var usdText: String { formatted(.currency(code: "USD").precision(.fractionLength(0...2))) }
    var percentText: String { "\(formatted(.number.precision(.fractionLength(0...2))))%" }
}
