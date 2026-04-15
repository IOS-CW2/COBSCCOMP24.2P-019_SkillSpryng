import SwiftUI

struct RateSessionSheet: View {
    let instructor: String
    @Environment(\.dismiss) var dismiss
    @State private var rating = 0
    @State private var feedback = ""
    
    var body: some View {
        VStack(spacing: 32) {
            // Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            VStack(spacing: 20) {
                // Profile
                ZStack {
                    Circle()
                        .stroke(AppTheme.Colors.primary.opacity(0.1), lineWidth: 4)
                        .frame(width: 100, height: 100)
                    Image("instructor1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
                .accessibilityHidden(true)
                
                VStack(spacing: 4) {
                    Text(instructor)
                        .font(AppTheme.Typography.title3)
                    Text("UX Design Mastery Session")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(.gray)
                }
                .accessibilityElement(children: .combine)
                
                Text("How was your session?")
                    .font(AppTheme.Typography.title2)
                    .padding(.top, 10)
                
                // Stars
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        Button(action: { rating = index }) {
                            Image(systemName: rating >= index ? "star.fill" : "star")
                                .font(.system(size: 32))
                                .foregroundColor(rating >= index ? .orange : Color(.systemGray4))
                        }
                        .accessibilityLabel("\(index) star\(index > 1 ? "s" : "")")
                        .accessibilityHint("Tap to rate \(index) out of 5")
                        .accessibilityAddTraits(rating == index ? .isSelected : [])
                    }
                }
                
                if rating > 0 {
                    Text(["Poor", "Fair", "Good", "Great", "Exceptional!"][rating-1])
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            // Text Feedback
            VStack(alignment: .leading, spacing: 8) {
                Text("TELL US MORE")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.gray)
                
                TextEditor(text: $feedback)
                    .frame(height: 100)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .accessibilityField(label: "Review feedback")
                    .overlay(
                        VStack {
                            if feedback.isEmpty {
                                Text("\(instructor) was incredibly insightful about user flow optimization...")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 24)
                                    .padding(.horizontal, 16)
                            }
                            Spacer()
                        },
                        alignment: .topLeading
                    )
            }
            .padding(.horizontal)
            
            // Actions
            VStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Submit Review")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(rating > 0 ? AppTheme.Colors.primary : Color.gray.opacity(0.3))
                        .cornerRadius(16)
                }
                .disabled(rating == 0)
                
                Button(action: { dismiss() }) {
                    Text("Skip")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.Colors.primary, lineWidth: 1))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}

struct CancelSessionSheet: View {
    let session: Session
    @Environment(\.dismiss) var dismiss
    @State private var isCancelling = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            VStack(spacing: 16) {
                Text("Cancel Session")
                    .font(AppTheme.Typography.title2)
                Text("This cannot be undone.")
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(.red)
            }
            
            // Session Brief
            HStack(spacing: 16) {
                Image("instructor1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.instructorName)
                        .font(AppTheme.Typography.subheadline)
                    Text(session.instructorRole)
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(.gray)
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text("\(session.date) • \(session.time)")
                    }
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(16)
            .padding(.horizontal)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Session with \(session.instructorName), \(session.instructorRole), on \(session.date) at \(session.time)")
            
            // Refund Section
            VStack(alignment: .leading, spacing: 16) {
                Text("CANCELLATION POLICY")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.gray)
                
                HStack {
                    ZStack {
                        Circle().fill(Color.green.opacity(0.1)).frame(width: 24, height: 24)
                        Image(systemName: "checkmark").font(AppTheme.Typography.badge).foregroundColor(.green)
                    }
                    VStack(alignment: .leading) {
                        Text("Full Refund")
                            .font(AppTheme.Typography.badge)
                        Text("Cancel by Oct 22, 10:00 AM")
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("ACTIVE")
                        .font(AppTheme.Typography.badge)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.green, lineWidth: 1))
                .accessibilityElement(children: .combine)
                
                HStack(spacing: 12) {
                    Circle().fill(Color(.systemGray5)).frame(width: 24, height: 24)
                    VStack(alignment: .leading) {
                        Text("No Refund")
                            .font(AppTheme.Typography.badge)
                        Text("After Oct 23, 10:00 AM")
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .accessibilityElement(children: .combine)
            }
            .padding(.horizontal)
            
            HStack {
                Text("Estimated Refund")
                    .font(AppTheme.Typography.subheadline)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(0) SKP")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primary)
                    Text("Returned to your SkillSpryng wallet")
                        .font(AppTheme.Typography.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Actions
            VStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Text("Keep My Session")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
                
                Button(action: {
                    isCancelling = true
                    Task {
                        // Attempt to delete it from calendar if the ID is tracked
                        if let eventId = session.calendarEventId {
                            _ = await CalendarService.shared.deleteCalendarEvent(identifier: eventId)
                        }
                        
                        // Proceed to dismiss or run actual cancel logic
                        await MainActor.run {
                            isCancelling = false
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        if isCancelling {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .red))
                        }
                        Text("Confirm Cancellation")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.2), lineWidth: 1))
                }
                .disabled(isCancelling)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}
