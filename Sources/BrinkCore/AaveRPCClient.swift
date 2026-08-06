import Foundation

public enum AaveRPCError: LocalizedError, Equatable {
    case invalidAddress
    case invalidResponse
    case rpc(String)
    case malformedResult

    public var errorDescription: String? {
        switch self {
        case .invalidAddress: return "Enter a valid 0x wallet address."
        case .invalidResponse: return "Monad RPC returned an invalid response."
        case .rpc(let message): return message
        case .malformedResult: return "Aave returned account data in an unexpected format."
        }
    }
}

public struct AaveRPCClient: Sendable {
    public var rpcURL: URL

    public init(rpcURL: URL = MonadAave.defaultRPCURL) {
        self.rpcURL = rpcURL
    }

    public func accountSnapshot(for address: String) async throws -> AccountSnapshot {
        guard address.isEthereumAddress else { throw AaveRPCError.invalidAddress }
        let parameter = String(address.dropFirst(2)).lowercased()
        let calldata = "0x\(MonadAave.getUserAccountDataSelector)\(String(repeating: "0", count: 24))\(parameter)"
        let request = RPCRequest(
            jsonrpc: "2.0",
            id: 1,
            method: "eth_call",
            params: [
                .object(["to": .string(MonadAave.pool), "data": .string(calldata)]),
                .string("latest"),
            ]
        )
        var urlRequest = URLRequest(url: rpcURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 15
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw AaveRPCError.invalidResponse
        }
        let envelope = try JSONDecoder().decode(RPCResponse.self, from: data)
        if let error = envelope.error { throw AaveRPCError.rpc(error.message) }
        guard let result = envelope.result else { throw AaveRPCError.invalidResponse }
        return try Self.decodeAccountData(result)
    }

    public static func decodeAccountData(_ hex: String, now: Date = Date()) throws -> AccountSnapshot {
        let body = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        guard body.count >= 64 * 6 else { throw AaveRPCError.malformedResult }
        let words = stride(from: 0, to: 64 * 6, by: 64).map { offset -> String in
            let start = body.index(body.startIndex, offsetBy: offset)
            let end = body.index(start, offsetBy: 64)
            return String(body[start..<end])
        }
        let collateral = try decimal(hex: words[0], scale: 8)
        let debt = try decimal(hex: words[1], scale: 8)
        let available = try decimal(hex: words[2], scale: 8)
        let liquidationThreshold = try decimal(hex: words[3], scale: 2)
        let ltv = try decimal(hex: words[4], scale: 2)
        let health: Decimal? = words[5].allSatisfy { $0 == "f" || $0 == "F" }
            ? nil
            : try decimal(hex: words[5], scale: 18)
        return AccountSnapshot(
            totalCollateralUSD: collateral,
            totalDebtUSD: debt,
            availableBorrowsUSD: available,
            liquidationThresholdPercent: liquidationThreshold,
            loanToValuePercent: ltv,
            healthFactor: health,
            fetchedAt: now
        )
    }

    private static func decimal(hex: String, scale: Int) throws -> Decimal {
        var value = Decimal.zero
        for character in hex {
            guard let nibble = character.hexDigitValue else { throw AaveRPCError.malformedResult }
            value *= 16
            value += Decimal(nibble)
        }
        return value / pow10(scale)
    }

    private static func pow10(_ exponent: Int) -> Decimal {
        (0..<exponent).reduce(Decimal(1)) { value, _ in value * 10 }
    }
}

private struct RPCRequest: Encodable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: [JSONValue]
}

private struct RPCResponse: Decodable {
    let result: String?
    let error: RPCFailure?
}

private struct RPCFailure: Decodable {
    let message: String
}

private enum JSONValue: Encodable {
    case string(String)
    case object([String: JSONValue])

    func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .object(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }
}
