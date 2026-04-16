import Foundation
import Network
import Combine

// MARK: - NetworkMonitor
// Uses NWPathMonitor (Apple Network framework) to observe real-time connectivity.
// Published `isOnline` drives the offline banner in views such as MySessionsView.
//
// Usage:
//   @StateObject private var network = NetworkMonitor.shared
//   if !network.isOnline { OfflineBannerView() }

@MainActor
final class NetworkMonitor: ObservableObject {

    static let shared = NetworkMonitor()

    // MARK: - Published State

    /// `true` when a usable network path is available (Wi-Fi or Cellular).
    @Published var isOnline: Bool = true

    /// Human readable description of the current connection type.
    @Published var connectionType: String = "Unknown"

    // MARK: - Private

    private let monitor  = NWPathMonitor()
    private let queue    = DispatchQueue(label: "com.skillspryng.network", qos: .utility)

    // MARK: - Init

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                self.isOnline        = path.status == .satisfied
                self.connectionType  = self.resolveConnectionType(path)
                print("[NetworkMonitor] \(self.isOnline ? "🟢 Online" : "🔴 Offline") — \(self.connectionType)")
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Private Helpers

    private func resolveConnectionType(_ path: NWPath) -> String {
        if path.usesInterfaceType(.wifi)     { return "Wi-Fi" }
        if path.usesInterfaceType(.cellular) { return "Cellular" }
        if path.usesInterfaceType(.wiredEthernet) { return "Ethernet" }
        return path.status == .satisfied ? "Connected" : "No Connection"
    }
}

// MARK: - OfflineBannerView
/// A sticky banner shown at the top of any view when connectivity is lost.
/// Automatically dismisses when the connection is restored.
import SwiftUI

struct OfflineBannerView: View {
    @ObservedObject var network: NetworkMonitor = .shared

    var body: some View {
        if !network.isOnline {
            HStack(spacing: 10) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 14, weight: .semibold))
                VStack(alignment: .leading, spacing: 1) {
                    Text("You're offline")
                        .font(.system(size: 13, weight: .bold))
                    Text("Showing cached data • Changes will sync when reconnected")
                        .font(.system(size: 10))
                        .opacity(0.85)
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(red: 0.18, green: 0.18, blue: 0.20))
            .transition(.move(edge: .top).combined(with: .opacity))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Offline: showing cached data. Changes will sync when reconnected.")
        }
    }
}
