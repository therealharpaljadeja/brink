#if canImport(BrinkCore)
import BrinkCore
#endif
import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: PortfolioStore
    @State private var address = ""
    @State private var label = ""
    @State private var rpcURL = ""
    @State private var validationMessage: String?

    var body: some View {
        Form {
            Section {
                Label {
                    Text("Brink is experimental and unaudited. Use it with caution and do not rely on it as your only liquidation warning.")
                        .font(.callout)
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            Section("Watched wallets") {
                if store.wallets.isEmpty {
                    Text("Add a public wallet address to start monitoring Aave V3 on Monad.")
                        .foregroundStyle(.secondary)
                }
                ForEach(store.wallets) { wallet in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(wallet.displayName)
                            Text(wallet.address).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                        }
                        Spacer()
                        Circle().fill((store.snapshots[wallet.id]?.tier ?? .unavailable).color).frame(width: 8, height: 8)
                        Button(role: .destructive) { store.removeWallet(id: wallet.id) } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                }

                TextField("Wallet address (0x…)", text: $address)
                    .textFieldStyle(.roundedBorder)
                TextField("Label (optional)", text: $label)
                    .textFieldStyle(.roundedBorder)
                if let validationMessage {
                    Text(validationMessage).font(.caption).foregroundStyle(.red)
                }
                Button("Add Wallet") { addWallet() }
                    .disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section("Monad mainnet") {
                TextField("RPC URL", text: $rpcURL)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Text("Chain ID 143 · Aave V3")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Save RPC") { saveRPC() }
                }
            }

            Section {
                Text("Brink is read-only and never asks for a private key. Health data is best-effort, may be incorrect or delayed, and is not financial advice.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 520, height: 480)
        .onAppear { rpcURL = store.rpcURL.absoluteString }
    }

    private func addWallet() {
        guard store.addWallet(address: address, label: label) else {
            validationMessage = address.trimmingCharacters(in: .whitespacesAndNewlines).isEthereumAddress
                ? "That wallet is already being watched."
                : "Enter a valid 42-character 0x address."
            return
        }
        address = ""
        label = ""
        validationMessage = nil
    }

    private func saveRPC() {
        guard let url = URL(string: rpcURL), let scheme = url.scheme, ["http", "https"].contains(scheme) else {
            validationMessage = "Enter a valid HTTP or HTTPS RPC URL."
            return
        }
        store.rpcURL = url
        validationMessage = nil
        Task { await store.refresh() }
    }
}
