import XCTest
@testable import BrinkCore

final class AaveCoreTests: XCTestCase {
    func testAddressValidation() {
        XCTAssertTrue("0xf37e2333d09b3d7168bc75b3c3283ff0da31bdd2".isEthereumAddress)
        XCTAssertTrue("0x69a5F9AD4f96ebf0a0C792dD42a01cC5C0102fef".isEthereumAddress)
        XCTAssertFalse("0x1234".isEthereumAddress)
        XCTAssertFalse("f37e2333d09b3d7168bc75b3c3283ff0da31bdd2".isEthereumAddress)
        XCTAssertFalse("0xg37e2333d09b3d7168bc75b3c3283ff0da31bdd2".isEthereumAddress)
    }

    func testAccountDataDecodingAndScaling() throws {
        let result = "0x" + [
            word(123_456_789_000), // $1,234.56789 collateral
            word(50_000_000_000),  // $500 debt
            word(42_000_000_000),  // $420 available
            word(8_250),           // 82.5% liquidation threshold
            word(7_500),           // 75% LTV
            word(1_420_000_000_000_000_000),
        ].joined()

        let snapshot = try AaveRPCClient.decodeAccountData(result)
        XCTAssertEqual(snapshot.totalCollateralUSD, Decimal(string: "1234.56789"))
        XCTAssertEqual(snapshot.totalDebtUSD, Decimal(500))
        XCTAssertEqual(snapshot.availableBorrowsUSD, Decimal(420))
        XCTAssertEqual(snapshot.liquidationThresholdPercent, Decimal(string: "82.5"))
        XCTAssertEqual(snapshot.loanToValuePercent, Decimal(75))
        XCTAssertEqual(snapshot.healthFactor, Decimal(string: "1.42"))
        XCTAssertEqual(snapshot.tier, .warning)
    }

    func testMaxHealthFactorMeansNoDebt() throws {
        let result = "0x" + [word(100_000_000), word(0), word(75_000_000), word(8_000), word(7_500), String(repeating: "f", count: 64)].joined()
        let snapshot = try AaveRPCClient.decodeAccountData(result)
        XCTAssertNil(snapshot.healthFactor)
        XCTAssertEqual(snapshot.tier, .safe)
    }

    func testHealthTiers() {
        XCTAssertEqual(snapshot(health: "1.09").tier, .critical)
        XCTAssertEqual(snapshot(health: "1.10").tier, .warning)
        XCTAssertEqual(snapshot(health: "1.49").tier, .warning)
        XCTAssertEqual(snapshot(health: "1.50").tier, .safe)
        XCTAssertEqual(snapshot(health: nil).tier, .safe)
    }

    private func word(_ value: UInt64) -> String {
        String(repeating: "0", count: 64 - String(value, radix: 16).count) + String(value, radix: 16)
    }

    private func snapshot(health: String?) -> AccountSnapshot {
        AccountSnapshot(
            totalCollateralUSD: 0,
            totalDebtUSD: 0,
            availableBorrowsUSD: 0,
            liquidationThresholdPercent: 0,
            loanToValuePercent: 0,
            healthFactor: health.flatMap { Decimal(string: $0) }
        )
    }
}
