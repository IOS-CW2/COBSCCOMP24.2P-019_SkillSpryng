import SwiftUI

struct AgeVerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var birthDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Navigation Bar
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding()
                }
                Spacer()
                Text("Age Verification")
                    .font(.headline)
                    .bold()
                Spacer()
                Image(systemName: "chevron.left").opacity(0).padding()
            }
            .padding(.top)
            
            // Progress Bar
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.3)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width * 0.7)
                }
            }
            .frame(height: 2)
            .background(Color.blue.opacity(0.1))
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Custom Calendar Icon Illustration
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.88, green: 0.95, blue: 0.91))
                            .frame(width: 160, height: 160)
                        
                        // Calendar Board
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.15, green: 0.26, blue: 0.33))
                            .frame(width: 90, height: 90)
                        
                        // Calendar Paper Page
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 80, height: 75)
                            .offset(y: 5)
                            .overlay(
                                VStack(spacing: 0) {
                                    // Red header
                                    Rectangle()
                                        .fill(Color(red: 0.9, green: 0.33, blue: 0.27))
                                        .frame(height: 20)
                                        .overlay(Text("SLAHER").font(.system(size: 8, weight: .bold)).foregroundColor(.white))
                                    Spacer()
                                }
                                .offset(y: 5) // offset within the board
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .offset(y: 5)
                        
                        Text("10")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundColor(Color(red: 0.17, green: 0.28, blue: 0.37))
                            .offset(y: 15)
                        Text("ST")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.17, green: 0.28, blue: 0.37))
                            .offset(y: 32)
                            
                        // Small white pins at the top
                        HStack(spacing: 40) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: 6, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: 6, height: 12)
                        }
                        .offset(y: -25)
                    }
                    .padding(.top, 40)
                    
                    Text("How old are you?")
                        .font(.system(size: 28, weight: .bold))
                    
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
                    
                    Spacer(minLength: 40)
                    
                    Text("Your birthdate is used only for age verification and\nis never shared.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Move to next step if under age, or another view
                    }) {
                        HStack {
                            Text("Continue")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.Gradients.primaryButton)
                        .cornerRadius(AppTheme.Radius.md)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
