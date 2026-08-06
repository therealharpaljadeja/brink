import AppKit
#if canImport(BrinkCore)
import BrinkCore
#endif
import DynamicNotchKit
import SwiftUI

@MainActor
final class NotchController {
    private var notch: DynamicNotch<AnyView, AnyView, AnyView>!
    private var expanded = false

    init(store: PortfolioStore) {
        notch = DynamicNotch(
            hoverBehavior: .all,
            style: .auto,
            expanded: { [weak self] in
                AnyView(
                    ExpandedNotchView(store: store)
                        .onHover { hovering in
                            if !hovering { self?.collapse() }
                        }
                )
            },
            compactLeading: { [weak self] in
                AnyView(
                    CompactHealthDot(store: store)
                        .onHover { hovering in
                            if hovering { self?.expand() }
                        }
                )
            },
            compactTrailing: { [weak self] in
                AnyView(
                    CompactHealthText(store: store)
                        .onHover { hovering in
                            if hovering { self?.expand() }
                        }
                )
            }
        )
    }

    func present() {
        Task { Self.hasNotch ? await notch.compact() : await notch.expand() }
    }

    private func expand() {
        guard !expanded else { return }
        expanded = true
        Task { await notch.expand() }
    }

    private func collapse() {
        guard expanded else { return }
        expanded = false
        Task { Self.hasNotch ? await notch.compact() : await notch.expand() }
    }

    private static var hasNotch: Bool {
        (NSScreen.main?.safeAreaInsets.top ?? 0) > 0
    }
}
