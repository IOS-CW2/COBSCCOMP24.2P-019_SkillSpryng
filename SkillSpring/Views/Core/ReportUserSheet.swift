import SwiftUI

struct ReportUserSheet: View {
    @State private var selectedReason: String? = "Harassment or hate speech" // Default per mockup
    @State private var details: String = ""
    @State private var blockUser: Bool = true // Default per mockup
    @Environment(\.dismiss) var dismiss
    
    let reasons = [
        "Spam or misleading",
        "Harassment or hate speech",
        "Inappropriate content",
        "Other reason"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Pill indicator for bottom sheet
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 8) {
                        Text("Report User")
                            .font(.system(size: 20, weight: .bold))
                        Text("Please let us know why you are reporting this user. Your feedback helps keep SkillSpryng safe.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // User Profile Brief
                    HStack(spacing: 12) {
                        Image("instructor2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Alex Rivera")
                                .font(.system(size: 16, weight: .bold))
                            Text("@rivera_design")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    
                    // Select Reason
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SELECT A REASON")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 0) {
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: { selectedReason = reason }) {
                                    HStack {
                                        Text(reason)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        
                                        ZStack {
                                            Circle()
                                                .stroke(selectedReason == reason ? AppTheme.Colors.primary : Color.gray.opacity(0.2), lineWidth: 2)
                                                .frame(width: 22, height: 22)
                                            
                                            if selectedReason == reason {
                                                Circle()
                                                    .fill(AppTheme.Colors.primary)
                                                    .frame(width: 14, height: 14)
                                                
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 8, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal)
                                
                                if reason != reasons.last {
                                    Divider()
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    }
                    
                    // Additional Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADDITIONAL DETAILS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $details)
                                .frame(height: 100)
                                .padding(12)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
                            
                            if details.isEmpty {
                                Text("Tell us more about the incident (optional)...")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                            }
                        }
                    }
                    
                    // Block Toggle Card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "person.badge.minus.fill")
                                .foregroundColor(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Block Alex Rivera")
                                .font(.system(size: 14, weight: .bold))
                            Text("They won't be able to message you or see your profile.")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $blockUser)
                            .tint(.red)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { dismiss() }) {
                            Text("Submit Report")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(16)
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.Colors.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.Colors.primary.opacity(0.1), lineWidth: 1))
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemBackground))
    }
}
