import SwiftUI

// MARK: - AgeVerificationView
// Screen that confirms the user's age before continuing onboarding.
// Uses a wheel date picker to calculate whether the user is over 18,
// then routes to parental setup or skill setup accordingly.
struct AgeVerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var birthDate = Date()
    @State private var navigateToParental = false
    @State private var navigateToSkillSetup = false

    private var isAdult: Bool {
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        return age >= 18
    }

    var body: some View {
        VStack(spacing: 0) {

            // Top Navigation Bar
            AppHeader(title: "Age Verification", backAction: { presentationMode.wrappedValue.dismiss() })
                .padding(.top, 10)

            // Progress Bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.Colors.primary)
                        .frame(width: geometry.size.width * 0.3)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width * 0.7)
                }
            }
            .frame(height: 3)
            .background(AppTheme.Colors.primary.opacity(0.12))

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Custom Calendar Icon Illustration
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.88, green: 0.95, blue: 0.91))
                            .frame(width: 160, height: 160)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.15, green: 0.26, blue: 0.33))
                            .frame(width: 90, height: 90)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 80, height: 75)
                            .offset(y: 5)
                            .overlay(
                                VStack(spacing: 0) {
                                    Rectangle()
                                        .fill(Color(red: 0.9, green: 0.33, blue: 0.27))
                                        .frame(height: 20)
                                        .overlay(Text("SLAHER").font(AppTheme.Typography.badge).foregroundColor(.white))
                                    Spacer()
                                }
                                .offset(y: 5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .offset(y: 5)

                        Text("10")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(Color(red: 0.17, green: 0.28, blue: 0.37))
                            .offset(y: 15)
                        Text("ST")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(Color(red: 0.17, green: 0.28, blue: 0.37))
                            .offset(y: 32)

                        HStack(spacing: 40) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: 6, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: 6, height: 12)
                        }
                        .offset(y: -25)
                    }
                    .padding(.top, 40)
                    .accessibilityHidden(true)
                    
                    Text("How old are you?")
                        .font(AppTheme.Typography.title)

                    Text("We use this to personalise your\nexperience and keep you safe.")
                        .font(.body)
                        .foregroundColor(Color(UIColor.darkGray))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Date Picker
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.secondarySystemBackground))

                        DatePicker("", selection: $birthDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                            .environment(\.locale, Locale(identifier: "en_US"))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                    Text("Your birthdate is used only for age verification and\nis never shared.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }

            // Continue button — pinned at the bottom, always visible
            VStack(spacing: 0) {
                NavigationLink(destination: ParentalSetupView(), isActive: $navigateToParental) {
                    EmptyView()
                }
                NavigationLink(destination: SkillSetupView(fullName: "", phoneNumber: ""), isActive: $navigateToSkillSetup) {
                    EmptyView()
                }

                Button(action: {
                    if isAdult {
                        navigateToSkillSetup = true
                    } else {
                        navigateToParental = true
                    }
                }) {
                    HStack {
                        Text("Continue")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(AppTheme.Radius.md)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(Color.white.shadow(color: .black.opacity(0.05), radius: 8, y: -4))
        }
        .navigationBarHidden(true)
    }
}
