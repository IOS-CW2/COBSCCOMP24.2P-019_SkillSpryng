import SwiftUI

// MARK: - MentorSessionRequestView
// Shown to the instructor when they receive an incoming session request.
// Accessible from MyMatchesInboxView (Requests tab) by tapping a pending request card.

struct MentorSessionRequestView: View {
    let profile: MatchProfile          // The learner who sent the request
    @Environment(\.dismiss) private var dismiss
    @State private var showDeclineSheet = false
    @State private var isAccepting = false
    @State private var isAccepted = false
    @State private var pendingMatch: MatchRequest? = nil

    // Formatted display values — real when match loaded, fallback otherwise
    private var displayFormat: String {
        if let online = pendingMatch?.isOnline { return online ? "Online \u{00B7} Jitsi Meet" : "In-Person" }
        return "Online \u{00B7} Jitsi Meet"
    }
    private var displayDate: String {
        guard let date = pendingMatch?.scheduledDate else { return "Pending" }
        let f = DateFormatter(); f.dateFormat = "EEE, MMM d"; return f.string(from: date)
    }
    private var displayTime: String  { pendingMatch?.scheduledTime ?? "TBD" }
    private var displayDuration: String {
        guard let mins = pendingMatch?.durationMinutes else { return "60 min" }
        return "\(mins) min"
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    AppHeader(title: "Session Request", backAction: { dismiss() })

                    VStack(spacing: 24) {

                        // Learner Profile Card
                        VStack(spacing: 16) {
                            SmartAvatar(imageUrl: profile.imageUrl, width: 80, height: 80)

                            VStack(spacing: 4) {
                                Text(profile.fullName)
                                    .font(AppTheme.Typography.title2)
                                Text(profile.role)
                                    .font(AppTheme.Typography.callout)
                                    .foregroundColor(.gray)
                            }

                            // Match badge
                            HStack(spacing: 6) {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.white)
                                Text("\(profile.matchPercentage)% SKILL MATCH")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(20)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Session request from \(profile.fullName), \(profile.role)")

                        // Session Details Card
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "SESSION DETAILS")

                            VStack(spacing: 12) {
                                MentorDetailRow(icon: "video.fill",   label: "FORMAT",   value: displayFormat)
                                MentorDetailRow(icon: "calendar",     label: "DATE",     value: displayDate)
                                MentorDetailRow(icon: "clock.fill",   label: "TIME",     value: displayTime)
                                MentorDetailRow(icon: "timer",        label: "DURATION", value: displayDuration)
                                MentorDetailRow(icon: "tag.fill",     label: "SKILL",    value: profile.skillsToTeach.first ?? "Skill Session")
                                MentorDetailRow(icon: "creditcard.fill", label: "YOU EARN", value: "\(profile.hourlyRate) SKP")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)

                        // About Learner
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "ABOUT LEARNER")

                            Text(profile.bio.isEmpty ? "Looking forward to learning from you." : String(profile.bio.prefix(200)))
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.gray)
                                .lineSpacing(5)

                            HStack(spacing: 8) {
                                MentorStatPill(icon: "star.fill",     text: String(format: "%.1f Rating", profile.rating), color: .orange)
                                MentorStatPill(icon: "checkmark.seal.fill", text: "Verified", color: AppTheme.Colors.primary)
                                MentorStatPill(icon: "clock.fill",    text: profile.responseTime, color: .blue)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)

                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                isAccepting = true
                                Task {
                                    // Accept the pending MatchRequest in Firestore + notify learner
                                    await FirebaseDataService.shared.acceptIncomingMatch(fromUserId: profile.id)
                                    isAccepting = false
                                    isAccepted = true
                                    HapticManager.success()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                        dismiss()
                                    }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if isAccepting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.85)
                                    } else if isAccepted {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                    }
                                    Text(isAccepted ? "Session Accepted!" : (isAccepting ? "Accepting..." : "Accept Session →"))
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isAccepted ? AppTheme.Colors.primary : AppTheme.Colors.primary)
                                .cornerRadius(16)
                            }
                            .disabled(isAccepting || isAccepted)
                            .accessibilityLabel("Accept this session request")

                            Button(action: { showDeclineSheet = true }) {
                                Text("Decline")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.07))
                                    .cornerRadius(16)
                            }
                            .accessibilityLabel("Decline this session request")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            // Load the real scheduling details from the pending MatchRequest
            pendingMatch = await FirebaseDataService.shared.fetchPendingMatch(fromUserId: profile.id)
        }
        .sheet(isPresented: $showDeclineSheet) {
            DeclineReasonSheet {
                // Decline the pending MatchRequest in Firestore + notify learner
                Task {
                    await FirebaseDataService.shared.declineIncomingMatch(fromUserId: profile.id)
                    HapticManager.error()
                }
                showDeclineSheet = false
                dismiss()
            }
        }
    }
}

// MARK: - Supporting Components

private struct MentorDetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.primary)
                .frame(width: 20)
                .accessibilityHidden(true)
            Text(label)
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(AppTheme.Typography.subheadline)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

private struct MentorStatPill: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(AppTheme.Typography.badge)
                .foregroundColor(color)
                .accessibilityHidden(true)
            Text(text)
                .font(AppTheme.Typography.badge)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - DeclineReasonSheet
// Bottom sheet shown when the instructor taps "Decline" on a session request.

struct DeclineReasonSheet: View {
    var onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReason: String = "Not available at this time"

    private let reasons = [
        "Not available at this time",
        "Topic outside my expertise",
        "Schedule conflict",
        "Other"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Pill
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 16)
                .accessibilityHidden(true)

            VStack(spacing: 24) {
                // Title
                VStack(spacing: 6) {
                    Text("Decline Request")
                        .font(AppTheme.Typography.title3)
                    Text("Please let the learner know why you're declining so they can find a better match.")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                // Reason Picker
                VStack(spacing: 0) {
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: { selectedReason = reason }) {
                            HStack {
                                Text(reason)
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.Colors.primary)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray.opacity(0.4))
                                }
                            }
                            .padding()
                        }
                        .accessibilityAddTraits(selectedReason == reason ? .isSelected : [])
                        .accessibilityLabel(reason)

                        if reason != reasons.last {
                            Divider().padding(.horizontal)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                .padding(.horizontal)

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: { onConfirm() }) {
                        Text("Confirm Decline")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(16)
                    }
                    .accessibilityLabel("Confirm decline with reason: \(selectedReason)")

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                    }
                    .accessibilityLabel("Cancel, go back to the session request")
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.medium])
    }
}

