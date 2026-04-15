import SwiftUI
import MapKit

struct LocationMapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showPrivacyBanner = true
    @State private var sheetOffset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0

    // Bottom sheet peek height
    private let sheetPeekHeight: CGFloat = 200
    private let sheetFullHeight: CGFloat = 420
    @State private var sheetExpanded = false

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Permission Denied State ─────────────────────────────────────
            if viewModel.permissionStatus == .denied ||
               viewModel.permissionStatus == .restricted {
                locationDeniedView
            } else {
                // ── Full Screen Map ─────────────────────────────────────────
                ZStack(alignment: .top) {
                    Map(
                        coordinateRegion: $viewModel.region,
                        showsUserLocation: true,
                        annotationItems: viewModel.nearbySkills
                    ) { skill in
                        MapAnnotation(coordinate: skill.coordinate) {
                            SkillPinView(
                                skill: skill,
                                isSelected: viewModel.selectedSkill?.id == skill.id
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.selectedSkill = (viewModel.selectedSkill?.id == skill.id)
                                        ? nil : skill
                                }
                            }
                            .accessibilityLabel(
                                "\(skill.name), teaches \(skill.skills), \(skill.profile.distance). Double tap to view profile."
                            )
                        }
                    }
                    .ignoresSafeArea()

                    // ── Top Overlay: Search bar + Filter ───────────────────
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text("Search nearby skills...")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Search nearby skills")

                            Button(action: {}) {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundColor(.primary)
                                    .padding(12)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                            }
                            .accessibilityLabel("Filter map")
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // ── Privacy Banner ──────────────────────────────────
                        if showPrivacyBanner {
                            HStack(spacing: 10) {
                                Image(systemName: "location.fill")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.white)
                                Text("Showing approximate locations only")
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        showPrivacyBanner = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(AppTheme.Typography.badge)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: "FF9F0A"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .accessibilityLabel("Location privacy notice. Only approximate locations are shown.")
                        }
                    }
                }

                // ── Selected Skill Card ─────────────────────────────────────
                if let selected = viewModel.selectedSkill {
                    SelectedSkillCard(skill: selected) {
                        withAnimation { viewModel.selectedSkill = nil }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, sheetPeekHeight + 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
                }

                // ── Draggable Bottom Sheet ──────────────────────────────────
                bottomSheet
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { viewModel.requestPermission() }
    }

    // MARK: - Bottom Sheet

    private var bottomSheet: some View {
        let currentHeight = sheetExpanded ? sheetFullHeight : sheetPeekHeight
        let offset = max(0, currentHeight - sheetPeekHeight - dragOffset)

        return VStack(spacing: 0) {
            // Handle bar
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 8)

            // Heading
            HStack {
                if viewModel.isLoadingPins {
                    HStack(spacing: 6) {
                        ProgressView().scaleEffect(0.7)
                        Text("Finding learners nearby...")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                } else {
                    Text("\(viewModel.nearbySkills.count) learners nearby")
                        .font(.system(size: 17, weight: .bold))
                }
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.35)) {
                        sheetExpanded.toggle()
                    }
                }) {
                    Image(systemName: sheetExpanded ? "chevron.down" : "chevron.up")
                        .font(AppTheme.Typography.sectionHeader)
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .accessibilityLabel("\(viewModel.nearbySkills.count) learners nearby. Swipe up to see full list.")

            // Horizontal scroll of compact user cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.nearbySkills) { skill in
                        NearbyUserCard(skill: skill, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }

            if sheetExpanded {
                // Vertical list when expanded
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.nearbySkills) { skill in
                            NearbyUserRow(skill: skill, viewModel: viewModel)
                            Divider().padding(.leading, 72)
                        }
                    }
                }
                .padding(.bottom, 24)
            }

            Spacer(minLength: 0)
        }
        .frame(height: currentHeight)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 20, y: -4)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.35)) {
                        if value.translation.height < -50 {
                            sheetExpanded = true
                        } else if value.translation.height > 50 {
                            sheetExpanded = false
                        }
                    }
                }
        )
    }

    // MARK: - Permission Denied State

    private var locationDeniedView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "location.slash.fill")
                    .font(.system(size: 52))
                    .foregroundColor(.gray.opacity(0.5))

                VStack(spacing: 8) {
                    Text("Enable location to see nearby learners")
                        .font(AppTheme.Typography.headline)
                        .multilineTextAlignment(.center)

                    Text("SkillSpryng uses approximate location to show you instructors and learners in your area. Your exact address is never stored.")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "gear")
                        Text("Open Settings")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(14)
                }
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.08), radius: 20)
            .padding()

            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Nearby User Card (horizontal scroll, bottom sheet compact)

struct NearbyUserCard: View {
    let skill: SkillLocation
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(skill.profile.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.green, lineWidth: 2.5))

                VStack(alignment: .leading, spacing: 2) {
                    Text(skill.name)
                        .font(AppTheme.Typography.sectionHeader)
                        .lineLimit(1)
                    Text(skill.skills)
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            HStack {
                Label(viewModel.calculateDistance(to: skill.profile),
                      systemImage: "location.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primary)

                Spacer()

                Text("\(viewModel.calculateMatchPercentage(with: skill.profile))% match")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.green)
            }

            NavigationLink(destination: Text("Profile: \(skill.name)")) {
                Text("View")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .frame(width: 170)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(skill.name). Teaches \(skill.skills). \(viewModel.calculateDistance(to: skill.profile)). \(viewModel.calculateMatchPercentage(with: skill.profile)) percent match.")
    }
}

// MARK: - Nearby User Row (expanded sheet list)

struct NearbyUserRow: View {
    let skill: SkillLocation
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(skill.profile.imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.green, lineWidth: 2.5))

            VStack(alignment: .leading, spacing: 3) {
                Text(skill.name)
                    .font(AppTheme.Typography.subheadline)
                Text("Teaches: \(skill.skills)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
                HStack(spacing: 6) {
                    Label(viewModel.calculateDistance(to: skill.profile),
                          systemImage: "location.fill")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(AppTheme.Colors.primary)
                    Text("• \(viewModel.calculateMatchPercentage(with: skill.profile))% match")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(AppTheme.Typography.caption)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(skill.name). Teaches: \(skill.skills). \(viewModel.calculateDistance(to: skill.profile)). \(viewModel.calculateMatchPercentage(with: skill.profile)) percent match.")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Pin View

struct SkillPinView: View {
    let skill: SkillLocation
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Name label bubble when selected
            if isSelected {
                Text(skill.name)
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(8)
                    .padding(.bottom, 4)
            }

            // Avatar circle — 60pt selected (with match % callout), 44pt deselected
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.Colors.primary : Color.white)
                    .frame(width: isSelected ? 60 : 44, height: isSelected ? 60 : 44)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: isSelected ? 10 : 4)
                    .overlay(
                        Circle()
                            .stroke(Color.green, lineWidth: 3)
                    )

                Image(skill.profile.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: isSelected ? 52 : 38, height: isSelected ? 52 : 38)
                    .clipShape(Circle())
            }

            // Pin triangle
            Image(systemName: "arrowtriangle.down.fill")
                .font(AppTheme.Typography.caption2)
                .foregroundColor(isSelected ? AppTheme.Colors.primary : .white)
                .offset(y: -2)
        }
        .animation(.spring(response: 0.25), value: isSelected)
        .accessibilityLabel(
            "\(skill.name), teaches \(skill.skills), \(skill.profile.distance) away. Double tap to view profile."
        )
    }
}

// MARK: - Selected Skill Detail Card

struct SelectedSkillCard: View {
    let skill: SkillLocation
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(skill.profile.imageUrl)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.green, lineWidth: 2.5))

            VStack(alignment: .leading, spacing: 3) {
                Text(skill.name)
                    .font(AppTheme.Typography.subheadline)
                Text("Teaches: \(skill.skills)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(AppTheme.Typography.micro)
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", skill.profile.rating))
                        .font(AppTheme.Typography.footnote)
                    Text("• \(skill.profile.matchPercentage)% match")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(.green)
                    Text("• \(skill.profile.distance)")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray.opacity(0.4))
                    .font(.title3)
            }
            .accessibilityLabel("Dismiss selected skill")
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
    }
}

#Preview {
    LocationMapView()
}
