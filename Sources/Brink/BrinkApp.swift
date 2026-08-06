import AppKit
#if canImport(BrinkCore)
import BrinkCore
#endif
import SwiftUI

@main
struct BrinkApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Brink", systemImage: "heart.text.square") {
            MenuBarView(store: appDelegate.store)
        }
        .menuBarExtraStyle(.menu)

    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = PortfolioStore()
    private var notchController: NotchController?
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        let controller = NotchController(store: store)
        notchController = controller
        settingsWindowController = SettingsWindowController(store: store)
        controller.present()
        store.startPolling()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openSettings),
            name: .openBrinkSettings,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(willSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(didWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.stopPolling()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc private func willSleep() { store.stopPolling() }
    @objc private func didWake() { store.startPolling() }
    @objc private func openSettings() { settingsWindowController?.show() }
}

private struct MenuBarView: View {
    @ObservedObject var store: PortfolioStore

    var body: some View {
        if let wallet = store.selectedWallet {
            Text(wallet.displayName)
            Text("Health factor: \(store.selectedSnapshot?.healthFactor.healthText ?? "—")")
        } else {
            Text("No wallet added")
        }
        Divider()
        Button("Refresh Now") { Task { await store.refresh() } }
            .disabled(store.wallets.isEmpty || store.isRefreshing)
        Button("Settings…") {
            NotificationCenter.default.post(name: .openBrinkSettings, object: nil)
        }
        Divider()
        Button("Quit Brink") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
