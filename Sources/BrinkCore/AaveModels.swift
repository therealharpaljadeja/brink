import Foundation

public enum MonadAave {
    public static let chainID = 143
    public static let defaultRPCURL = URL(string: "https://rpc.monad.xyz")!
    public static let pool = "0x69a5F9AD4f96ebf0a0C792dD42a01cC5C0102fef"
    public static let getUserAccountDataSelector = "bf92857c"
}

public enum HealthTier: Int, Codable, Comparable, Sendable {
    case unavailable = -1
    case safe = 0
    case warning = 1
    case critical = 2

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
}

public struct AccountSnapshot: Equatable, Sendable {
    public let totalCollateralUSD: Decimal
    public let totalDebtUSD: Decimal
    public let availableBorrowsUSD: Decimal
    public let liquidationThresholdPercent: Decimal
    public let loanToValuePercent: Decimal
    public let healthFactor: Decimal?
    public let fetchedAt: Date

    public init(
        totalCollateralUSD: Decimal,
        totalDebtUSD: Decimal,
        availableBorrowsUSD: Decimal,
        liquidationThresholdPercent: Decimal,
        loanToValuePercent: Decimal,
        healthFactor: Decimal?,
        fetchedAt: Date = Date()
    ) {
        self.totalCollateralUSD = totalCollateralUSD
        self.totalDebtUSD = totalDebtUSD
        self.availableBorrowsUSD = availableBorrowsUSD
        self.liquidationThresholdPercent = liquidationThresholdPercent
        self.loanToValuePercent = loanToValuePercent
        self.healthFactor = healthFactor
        self.fetchedAt = fetchedAt
    }

    public var tier: HealthTier {
        guard let healthFactor else { return .safe }
        if healthFactor < Decimal(string: "1.10")! { return .critical }
        if healthFactor < Decimal(string: "1.50")! { return .warning }
        return .safe
    }
}

public struct WatchedWallet: Codable, Equatable, Identifiable, Sendable {
    public let address: String
    public var label: String

    public init(address: String, label: String = "") {
        self.address = address
        self.label = label
    }

    public var id: String { address.lowercased() }
    public var displayName: String {
        label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? address.shortAddress : label
    }
}

public extension String {
    var isEthereumAddress: Bool {
        guard hasPrefix("0x"), count == 42 else { return false }
        return dropFirst(2).allSatisfy(\.isHexDigit)
    }

    var shortAddress: String {
        guard count > 12 else { return self }
        return "\(prefix(6))…\(suffix(4))"
    }
}
