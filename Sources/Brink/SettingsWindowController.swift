import AppKit
#if canImport(BrinkCore)
import BrinkCore
#endif
import SwiftUI

extension Notification.Name {
    static let openBrinkSettings = Notification.Name("openBrinkSettings")
}

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    init(store: PortfolioStore) {
        let content = SettingsView(store: store)
        let hostingController = NSHostingController(rootView: content)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Brink Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 520, height: 480))
        window.minSize = NSSize(width: 480, height: 420)
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.moveToActiveSpace]
        window.tabbingMode = .disallowed
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func show() {
        guard let window else { return }
        if !window.isVisible { window.center() }
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window.deminiaturize(nil)
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
