import Combine
import Foundation

@MainActor
public final class PortfolioStore: ObservableObject {
    @Published public private(set) var wallets: [WatchedWallet]
    @Published public private(set) var snapshots: [String: AccountSnapshot] = [:]
    @Published public private(set) var errors: [String: String] = [:]
    @Published public var selectedWalletID: String?
    @Published public private(set) var isRefreshing = false
    @Published public private(set) var lastRefresh: Date?

    public var rpcURL: URL {
        didSet { defaults.set(rpcURL.absoluteString, forKey: Keys.rpcURL) }
    }

    private let defaults: UserDefaults
    private var pollingTask: Task<Void, Never>?

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Keys.wallets),
           let saved = try? JSONDecoder().decode([WatchedWallet].self, from: data) {
            wallets = saved
        } else {
            wallets = []
        }
        rpcURL = defaults.string(forKey: Keys.rpcURL).flatMap(URL.init(string:)) ?? MonadAave.defaultRPCURL
        selectedWalletID = wallets.first?.id
    }

    deinit { pollingTask?.cancel() }

    public var selectedWallet: WatchedWallet? {
        wallets.first { $0.id == selectedWalletID } ?? wallets.first
    }

    public var selectedSnapshot: AccountSnapshot? {
        selectedWallet.flatMap { snapshots[$0.id] }
    }

    public var selectedTier: HealthTier {
        guard selectedWallet != nil else { return .unavailable }
        return selectedSnapshot?.tier ?? .unavailable
    }

    public var worstTier: HealthTier {
        guard !wallets.isEmpty else { return .unavailable }
        return wallets.map { snapshots[$0.id]?.tier ?? .unavailable }.max() ?? .unavailable
    }

    public var worstHealthFactor: Decimal? {
        wallets.compactMap { snapshots[$0.id]?.healthFactor }.min()
    }

    @discardableResult
    public func addWallet(address: String, label: String = "") -> Bool {
        let clean = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.isEthereumAddress, !wallets.contains(where: { $0.id == clean.lowercased() }) else { return false }
        let wallet = WatchedWallet(address: clean, label: label)
        wallets.append(wallet)
        selectedWalletID = wallet.id
        persistWallets()
        Task { await refresh() }
        return true
    }

    public func removeWallet(id: String) {
        wallets.removeAll { $0.id == id }
        snapshots[id] = nil
        errors[id] = nil
        if selectedWalletID == id { selectedWalletID = wallets.first?.id }
        persistWallets()
    }

    public func startPolling() {
        guard pollingTask == nil else { return }
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refresh()
                let tier = self?.worstTier ?? .unavailable
                let seconds: UInt64 = tier == .critical ? 15 : (tier == .warning ? 30 : 60)
                try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
            }
        }
    }

    public func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    public func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        let client = AaveRPCClient(rpcURL: rpcURL)
        for wallet in wallets {
            do {
                snapshots[wallet.id] = try await client.accountSnapshot(for: wallet.address)
                errors[wallet.id] = nil
            } catch {
                errors[wallet.id] = error.localizedDescription
            }
        }
        lastRefresh = Date()
    }

    private func persistWallets() {
        defaults.set(try? JSONEncoder().encode(wallets), forKey: Keys.wallets)
    }

    private enum Keys {
        static let wallets = "brink.wallets.v1"
        static let rpcURL = "brink.rpcURL.v1"
    }
}
