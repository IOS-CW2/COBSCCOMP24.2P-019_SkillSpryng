import SwiftUI
import MapKit

struct LocationMapView: View {
    @StateObject private var viewModel = MapViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nearby Skills")
                        .font(.title2)
                        .bold()
                    Text(viewModel.locationName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if viewModel.isLoadingPins {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Finding nearby...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("\(viewModel.nearbySkills.count) found")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            // Map
            ZStack(alignment: .bottom) {
                Map(
                    coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.nearbySkills
                ) { skill in
                    MapAnnotation(coordinate: skill.coordinate) {
                        SkillPinView(skill: skill, isSelected: viewModel.selectedSkill?.id == skill.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.selectedSkill = (viewModel.selectedSkill?.id == skill.id) ? nil : skill
                                }
                            }
                    }
                }
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Selected skill detail card
                if let selected = viewModel.selectedSkill {
                    SelectedSkillCard(skill: selected) {
                        withAnimation { viewModel.selectedSkill = nil }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxHeight: .infinity)
            
            // Location button
            Button(action: { viewModel.requestPermission() }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Use My Current Location")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.Colors.primary.opacity(0.1))
                .foregroundColor(AppTheme.Colors.primary)
                .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            // Auto-request permission on load
            viewModel.requestPermission()
        }
    }
}

// MARK: - Pin View

struct SkillPinView: View {
    let skill: SkillLocation
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Label bubble
            if isSelected {
                Text(skill.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(8)
                    .padding(.bottom, 4)
            }
            
            // Pin circle
            ZStack {
                Circle()
                    .fill(isSelected ? AppTheme.Colors.primary : Color.white)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: isSelected ? 8 : 4)
                
                Image(skill.profile.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: isSelected ? 38 : 30, height: isSelected ? 38 : 30)
                    .clipShape(Circle())
            }
            
            // Pin triangle
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundColor(isSelected ? AppTheme.Colors.primary : .white)
                .offset(y: -2)
        }
        .animation(.spring(response: 0.25), value: isSelected)
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
            
            VStack(alignment: .leading, spacing: 3) {
                Text(skill.name)
                    .font(.system(size: 14, weight: .bold))
                Text("Teaches: \(skill.skills)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f", skill.profile.rating))
                        .font(.system(size: 11, weight: .semibold))
                    Text("• \(skill.profile.distance)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray.opacity(0.4))
                    .font(.title3)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 4)
    }
}

#Preview {
    LocationMapView()
}

