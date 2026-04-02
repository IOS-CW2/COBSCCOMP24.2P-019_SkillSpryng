import SwiftUI

struct ProfileSetupView: View {
    @ObservedObject var viewModel: SkillSetupViewModel
    var fullName: String
    var phoneNumber: String
    
    @State private var showingImagePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Skip
            HStack {
                Spacer()
                Button(action: {
                    viewModel.isSetupComplete = true
                }) {
                    Text("Skip")
                        .foregroundColor(.gray)
                        .font(.body)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Titles
                    VStack(spacing: 8) {
                        Text("Make your profile\nshine ✨")
                            .font(.system(size: 34, weight: .bold))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        Text("Let the community know who you are.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Profile Image Area
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 150, height: 150)
                            .overlay(
                                Group {
                                    if let image = viewModel.selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                            )
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Circle()
                                .fill(Color(hex: "00A86B")) // Mint Green color
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                )
                                .shadow(radius: 4)
                        }
                    }
                    
                    // Bio Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TELL US ABOUT YOURSELF")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .frame(height: 140)
                            
                            TextEditor(text: $viewModel.bio)
                                .font(.body)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                            
                            if viewModel.bio.isEmpty {
                                Text("Expertise in gardening, curious about coding...")
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Location Toggle Card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color(hex: "00A86B"))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable Location")
                                .font(.system(size: 16, weight: .bold))
                            Text("To find skills in your area")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isLocationEnabled)
                            .toggleStyle(SwitchToggleStyle())
                            .tint(Color(hex: "00A86B"))
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 120) // Spacing for floating button
            }
            
            // Floating Bottom Button
            VStack(spacing: 16) {
                PrimaryButton(title: "Finish Setup ->", action: {
                    viewModel.saveProfile(fullName: fullName, phoneNumber: phoneNumber)
                }, isLoading: viewModel.isLoading)
                
                Text("You can update these details anytime in Settings.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(Color.white.shadow(color: .black.opacity(0.05), radius: 10, y: -5))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $viewModel.selectedImage)
        }
    }
}

// Helper for Hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
