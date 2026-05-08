import SwiftUI
import FirebaseFirestore
import FirebaseAuth

/// A bottom-sheet reporting form used when a user flags another profile.
///
/// This view collects the report reason, optional details, and an optional
/// block toggle. It then writes the report to Firestore and dismisses itself.
struct ReportUserSheet: View {
    let reportedUserId: String
    let reportedUserName: String
    
    // MARK: - Local state for the reporting form
    @State private var selectedReason: String? = "Harassment or hate speech" // Default per mockup
    @State private var details: String = ""
    @State private var blockUser: Bool = true // Default per mockup
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Supported report reasons shown as selectable options
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
                .accessibilityHidden(true)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header block explaining why this report screen exists.
                    VStack(spacing: 8) {
                        Text("Report User")
                            .font(AppTheme.Typography.title3)
                        Text("Please let us know why you are reporting this user. Your feedback helps keep SkillSpryng safe.")
                            .font(AppTheme.Typography.callout)
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
                            Text(reportedUserName)
                                .font(AppTheme.Typography.headline)
                            Text("@\(reportedUserName.lowercased().replacingOccurrences(of: " ", with: "_"))")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(16)
                    .accessibilityElement(children: .combine)
                    
                    // Select Reason
                    // The user chooses one reason that best describes the issue.
                    // This selection is required to help moderation triage the report.
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SELECT A REASON")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 0) {
                            ForEach(reasons, id: \.self) { reason in
                                Button(action: { selectedReason = reason }) {
                                    HStack {
                                        Text(reason)
                                            .font(AppTheme.Typography.subheadline)
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
                                                    .font(AppTheme.Typography.badge)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .accessibilityHidden(true)
                                    }
                                }
                                .accessibilityAddTraits(selectedReason == reason ? .isSelected : [])
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
                    // Optional free-form text that lets the reporter explain the incident.
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADDITIONAL DETAILS")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $details)
                                .frame(height: 100)
                                .padding(12)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
                                .accessibilityLabel("Additional Details")
                            
                            if details.isEmpty {
                                Text("Tell us more about the incident (optional)...")
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                            }
                        }
                    }
                    
                    // Block Toggle Card
                    // Allows the reporter to immediately block the reported user.
                    // This is separate from the moderation report itself.
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "person.badge.minus.fill")
                                .foregroundColor(.red)
                        }
                        .accessibilityHidden(true)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Block \(reportedUserName)")
                                .font(AppTheme.Typography.subheadline)
                            Text("They won't be able to message you or see your profile.")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $blockUser)
                            .tint(.red)
                            .labelsHidden()
                            .accessibilityLabel("Block \(reportedUserName)")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
                    
                    // Action Buttons
                    // These two buttons either submit the report or close the sheet.
                    VStack(spacing: 12) {
                        Button(action: { submitReport() }) {
                            Text("Submit Report")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(16)
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(AppTheme.Typography.headline)
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
    
    /// Saves the report to Firestore and then dismisses the sheet.
    ///
    /// This method captures the selected reason, any additional details,
    /// the block preference, and the reporting user's UID.
    /// If Firestore returns an error, it prints it to the console.
    private func submitReport() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("reports").addDocument(data: [
            "reason": selectedReason ?? "",
            "details": details,
            "blockUser": blockUser,
            "reportedBy": uid,
            "reportedUserId": reportedUserId,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error capturing report: \(error)")
            } else {
                dismiss()
            }
        }
    }
}
