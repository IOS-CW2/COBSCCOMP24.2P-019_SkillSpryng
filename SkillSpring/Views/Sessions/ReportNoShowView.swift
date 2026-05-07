import SwiftUI

// MARK: - ReportNoShowView
// Shown to the instructor when the learner hasn't joined the live session
// after a waiting period. Accessible from LiveSessionView.

struct ReportNoShowView: View {
    let session: Session
    var onKeepWaiting: () -> Void
    var onLeaveSession: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isReporting = false
    @State private var reportConfirmed = false

    var body: some View {
        VStack(spacing: 0) {
            // Pill
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 16)
                .accessibilityHidden(true)

            VStack(spacing: 28) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.12))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 34))
                        .foregroundColor(.orange)
                }
                .accessibilityHidden(true)

                // Title
                VStack(spacing: 8) {
                    Text("\(session.instructorName) hasn't joined yet")
                        .font(AppTheme.Typography.title3)
                        .multilineTextAlignment(.center)

                    Text("The session was scheduled for \(session.time). You've been waiting — let us know what you'd like to do.")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)
                }

                // Option Cards
                VStack(spacing: 12) {
                    // Keep Waiting
                    OptionCard(
                        icon: "clock.fill",
                        iconColor: AppTheme.Colors.primary,
                        title: "Keep Waiting",
                        subtitle: "Give them a few more minutes to join",
                        borderColor: AppTheme.Colors.primary.opacity(0.3)
                    ) {
                        onKeepWaiting()
                        dismiss()
                    }
                    .accessibilityLabel("Keep waiting for the learner to join")

                    // Report No-Show
                    // This action refunds SKP and creates a report record for audit.
                    OptionCard(
                        icon: "flag.fill",
                        iconColor: .orange,
                        title: "Report No-Show",
                        subtitle: "You'll receive a full SKP refund for this session",
                        badgeText: "FULL REFUND",
                        badgeColor: .orange,
                        borderColor: Color.orange.opacity(0.3)
                    ) {
                        isReporting = true
                        Task {
                            // 1. Mark session as cancelled in Firestore
                            await FirebaseDataService.shared.cancelSession(session.id)

                            // 2. Refund the session cost to the user's wallet
                            if let user = await FirebaseDataService.shared.fetchCurrentUser() {
                                let refund = session.creditsEarned ?? 100   // fall back to 100 SKP
                                let newBalance = user.walletBalance + refund
                                await FirebaseDataService.shared.updateWalletBalance(newBalance)
                                await FirebaseDataService.shared.createTransaction(CreditTransaction(
                                    amount: refund,
                                    type: .sessionEarning,
                                    description: "No-show refund: \(session.instructorName) did not join",
                                    balanceAfter: newBalance,
                                    referenceId: session.id
                                ))
                            }

                            // 3. Write a no-show report document to Firestore
                            await FirebaseDataService.shared.createNotification(AppNotification(
                                type: .systemAlert,
                                title: "No-Show Report Filed",
                                body: "Your no-show report for the session with \(session.instructorName) has been submitted and your SKP has been refunded.",
                                referenceId: session.id
                            ))

                            await MainActor.run {
                                isReporting = false
                                reportConfirmed = true
                            }
                        }
                    }
                    .disabled(isReporting || reportConfirmed)
                    .accessibilityLabel("Report no-show and receive a full SKP refund")

                    // Leave Session
                    OptionCard(
                        icon: "xmark.circle.fill",
                        iconColor: .red,
                        title: "Leave Session",
                        subtitle: "Exit without reporting — no SKP refund",
                        borderColor: Color.red.opacity(0.2)
                    ) {
                        onLeaveSession()
                        dismiss()
                    }
                    .accessibilityLabel("Leave session without reporting")
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .overlay(
                Group {
                    if reportConfirmed {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(AppTheme.Colors.primary)
                            Text("No-show reported.")
                                .font(AppTheme.Typography.headline)
                            Text("Your SKP credits have been refunded.")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.gray)
                            Button("Done") { dismiss() }
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(16)
                                .padding(.top, 8)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.1), radius: 20)
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                    } else if isReporting {
                        ProgressView("Submitting report…")
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                            .transition(.opacity)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: reportConfirmed || isReporting)
            )
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - OptionCard

private struct OptionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var badgeText: String? = nil
    var badgeColor: Color = .orange
    var borderColor: Color = Color.gray.opacity(0.2)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(iconColor)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.primary)
                        if let badge = badgeText {
                            Text(badge)
                                .font(AppTheme.Typography.badge)
                                .foregroundColor(badgeColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(badgeColor.opacity(0.12))
                                .cornerRadius(4)
                        }
                    }
                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                        .lineSpacing(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray.opacity(0.5))
                    .accessibilityHidden(true)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
