import SwiftUI
import MapKit
import CoreLocation
import Combine

/// Shows a venue map for a session and manages optional geofence safety monitoring.
///
/// Users can see the session location, start monitoring, and receive alerts if
/// they move outside the safe zone during the session.
struct MapSelectionView: View {
    var session: Session? = nil

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var venueCoordinate: CLLocationCoordinate2D? = nil
    @ObservedObject private var geofenceManager = GeofenceManager.shared
    @State private var showMonitoringStarted = false
    @State private var showNeedHelpAlert = false

    // Live session timer — counts up from 0 once monitoring starts
    // Used to show how long the user has been under geofence supervision.
    @State private var sessionSeconds: Int = 0
    private let sessionTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var venueAnnotations: [MapPoint] {
        if let coord = venueCoordinate {
            return [MapPoint(name: session?.location ?? "Session Venue",
                             coordinate: coord, icon: "mappin.circle.fill")]
        }
        return [
            MapPoint(name: "Tennis Coach",
                     coordinate: CLLocationCoordinate2D(latitude: 37.7895, longitude: -122.4000),
                     icon: "figure.tennis"),
            MapPoint(name: "UX Workshop",
                     coordinate: CLLocationCoordinate2D(latitude: 37.7885, longitude: -122.3960),
                     icon: "desktopcomputer")
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            Map(coordinateRegion: $region, annotationItems: venueAnnotations) { point in
                MapAnnotation(coordinate: point.coordinate) {
                    MapPointView(point: point)
                }
            }
            .ignoresSafeArea()

            // Map control buttons
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        MapButton(icon: "scope")
                        MapButton(icon: "layers.fill")
                    }
                    .padding()
                }
                Spacer()
            }

            // Bottom Card
            // This card contains venue details, monitoring actions, and live session status.
            VStack(spacing: 20) {

                // Venue header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("SESSION VENUE")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.blue)
                        Spacer()
                        if geofenceManager.isMonitoring {
                            HStack(spacing: 4) {
                                Circle().fill(AppTheme.Colors.primary).frame(width: 6, height: 6)
                                Text("MONITORING ACTIVE")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.green)
                            }
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    Text(session?.location ?? "Salesforce Transit Center")
                        .font(.title3).fontWeight(.bold)
                    Text(session?.title ?? "Session")
                        .font(.caption).foregroundColor(.gray)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Session venue: \(session?.location ?? "Salesforce Transit Center"). \(session?.title ?? "Session"). \(geofenceManager.isMonitoring ? "Monitoring active" : "")")

                // Amenities row
                HStack(spacing: 16) {
                    AmenityView(icon: "wifi", title: "Fast WiFi")
                    AmenityView(icon: "cup.and.saucer.fill", title: "Quiet Cafe", color: .orange)
                }

                if geofenceManager.isMonitoring {
                    // Live session timer row
                    // Displays active monitoring state and elapsed time.
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(AppTheme.Colors.primary)
                            .font(AppTheme.Typography.footnote)
                        Text(formatDuration(sessionSeconds))
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.Colors.primary)
                        Spacer()
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.green)
                        Text("Geofence Active")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(12)
                    .background(AppTheme.Colors.primary.opacity(0.07))
                    .cornerRadius(12)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Geofence active. Time elapsed: \(formatDuration(sessionSeconds)).")

                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: { showNeedHelpAlert = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "staroflife.fill")
                                    .font(AppTheme.Typography.caption)
                                Text("I Need Help")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1.5))
                        }

                        Button(action: {
                            geofenceManager.stopMonitoring()
                            sessionSeconds = 0
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "stop.circle.fill")
                                    .font(AppTheme.Typography.caption)
                                Text("End Session")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                        }
                    }

                    // ── Simulator Testing Buttons (DEBUG only) ──────────────
                    #if DEBUG
                    VStack(spacing: 8) {
                        Divider()
                        Text("SIMULATOR TESTING")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            Button(action: {
                                GeofenceManager.shared.simulateGeofenceExit()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.right.circle.fill")
                                    Text("Simulate Exit")
                                        .fontWeight(.semibold)
                                }
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange.opacity(0.4), lineWidth: 1))
                            }

                            Button(action: {
                                GeofenceManager.shared.simulateGeofenceReturn()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.down.left.circle.fill")
                                    Text("Simulate Return")
                                        .fontWeight(.semibold)
                                }
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.top, 4)
                    #endif

                } else {
                    // Start monitoring button
                    // This begins the geofence supervision flow for the session.
                    Button(action: startSafetyMonitoring) {
                        HStack {
                            Image(systemName: "shield.fill")
                            Text("I've Arrived — Start Safety Monitoring")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.1), radius: 20)
            .padding()
        }
        .navigationBarHidden(false)
        .onAppear { geocodeVenue() }
        // Increment timer
        .onReceive(sessionTimer) { _ in
            if geofenceManager.isMonitoring { sessionSeconds += 1 }
        }
        // Monitoring started confirmation
        .alert("Safety Monitoring Started", isPresented: $showMonitoringStarted) {
            Button("Got It", role: .cancel) { }
        } message: {
            Text("You'll be alerted if you move more than 500m from the venue.")
        }
        // I Need Help emergency alert
        .alert("Emergency Alert", isPresented: $showNeedHelpAlert) {
            Button("Confirm — Send Alert", role: .destructive) {
                NotificationManager.shared.scheduleEmergencyContactAlert(sessionTitle: session?.title)
                HapticManager.error()
                showNeedHelpAlert = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will notify your emergency contacts and local authorities. Continue?")
        }
        // ── Safety Alert — triggered when geofence exit detected ────────────
        .fullScreenCover(isPresented: $geofenceManager.userLeftSession) {
            SafetyAlertSheet(sessionTitle: session?.title ?? "your session") {
                // "Yes, I'm Fine"
                geofenceManager.handleUserConfirmedSafe()
                HapticManager.success()
            } onNeedHelp: {
                // "I Need Help"
                geofenceManager.userLeftSession = false
                HapticManager.error()
                showNeedHelpAlert = true
            }
        }
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: Int) -> String {
        String(format: "%02d:%02d:%02d", seconds / 3600, (seconds % 3600) / 60, seconds % 60)
    }

    private func geocodeVenue() {
        guard let address = session?.location else { return }
        Task {
            let geocoder = CLGeocoder()
            if let placemark = try? await geocoder.geocodeAddressString(address),
               let coord = placemark.first?.location?.coordinate {
                await MainActor.run {
                    self.venueCoordinate = coord
                    self.region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                }
            }
        }
    }

    private func startSafetyMonitoring() {
        let coord = venueCoordinate ?? region.center
        GeofenceManager.shared.startMonitoring(
            sessionTitle: session?.title ?? "Session",
            coordinate: coord,
            radius: 100
        )
        HapticManager.success()
        showMonitoringStarted = true
    }
}


// MARK: - Sub-components (unchanged)

struct MapPoint: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
}

struct MapPointView: View {
    let point: MapPoint

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(point.name)
                    .font(AppTheme.Typography.badge)
            }
            .padding(6)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)

            Image(systemName: "triangle.fill")
                .resizable()
                .frame(width: 8, height: 4)
                .rotationEffect(.degrees(180))
                .foregroundColor(.white)
        }
    }
}

struct MapButton: View {
    let icon: String

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .padding(10)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
        .accessibilityLabel(icon == "scope" ? "Current Location" : "Map settings")
    }
}

struct AmenityView: View {
    let icon: String
    let title: String
    var color: Color = .green

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(AppTheme.Typography.badge)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
