import SwiftUI
import FirebaseFirestore

// MARK: - SessionDetailView
// Detailed view for a specific session, including status, instructor info,
// recording access, and session management actions.
struct SessionDetailView: View {
    let session: Session
    @Environment(\.dismiss) var dismiss
    @State private var showRating = false
    @State private var showCancel = false
    @State private var showRemoveAlert = false
    @State private var showOptions = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                AppHeader(title: "Session Details", backAction: { dismiss() }, actionIcon: "ellipsis", action: { showOptions = true })
                
                // Hero Status Card
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "1D9E75"), Color(hex: "27E246")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        StatusBadge(text: session.status.rawValue, color: .white)
                            .opacity(0.8)
                        
                        Text(session.title)
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(.white)
                        
                        Text("With \(session.instructorName)")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 12) {
                            DetailsInfoLabel(icon: "calendar", text: session.date)
                            Text("|")
                                .foregroundColor(.white.opacity(0.3))
                            DetailsInfoLabel(icon: "clock", text: session.time)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(session.status.rawValue). \(session.title). With \(session.instructorName). \(session.date) at \(session.time).")
                }
                .padding(.horizontal)
                
                // Mentor Info
                HStack(spacing: 16) {
                    Image("instructor1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.instructorName)
                            .font(AppTheme.Typography.headline)
                        Text(session.instructorRole)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if let match = session.matchPercentage {
                        Text("MATCH \(match)%")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.Colors.primary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Instructor \(session.instructorName), \(session.instructorRole). \(session.matchPercentage != nil ? "Match \(session.matchPercentage ?? 0)%" : "")")
                
                // Session Notes
                if let notes = session.notes {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "SESSION NOTES")
                        
                        Text("\"\(notes)\"")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                            .italic()
                            .lineSpacing(6)
                            .padding()
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                
                // Performance Overview
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "PERFORMANCE OVERVIEW")
                    PerformanceStatGrid(
                        duration: session.duration,
                        credits: session.creditsEarned ?? 0,
                        rating: Double(session.rating ?? 0)
                    )
                }
                .padding(.horizontal)
                
                // Recording Card
                if session.recordingAvailable {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "SESSION RECORDING")
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Available for 30 days", systemImage: "clock.arrow.2.circlepath")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: LessonPlayerView(session: session)) {
                                Text("Watch")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.Colors.primary)
                                    .cornerRadius(20)
                            }
                            .accessibilityLabel("Watch session recording, available for 30 days")
                        }
                        .padding()
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                
                // Primary Actions
                VStack(spacing: 12) {
                    if session.status == .completed {
                        Button(action: { showRating = true }) {
                            Text("Rate Session")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.primary)
                                .cornerRadius(16)
                        }
                        .accessibilityButton(
                            label: "Rate Session",
                            hint: "Opens rating sheet for this session"
                        )
                    }
                    
                    Button(action: {
                        if session.status == .upcoming {
                            showCancel = true
                        } else {
                            showRemoveAlert = true
                        }
                    }) {
                        Text(session.status == .upcoming ? "Cancel Session" : "Remove from History")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(16)
                    }
                    .accessibilityButton(
                        label: session.status == .upcoming ? "Cancel Session" : "Remove from History",
                        hint: session.status == .upcoming ? "Cancels this upcoming session" : "Removes this session from your history"
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showRating) {
            RateSessionSheet(instructor: session.instructorName, session: session)
        }
        .sheet(isPresented: $showCancel) {
            CancelSessionSheet(session: session)
        }
        .alert("Remove from History?", isPresented: $showRemoveAlert) {
            Button("Remove", role: .destructive) {
                Task {
                    if let uid = await FirebaseDataService.shared.fetchCurrentUser()?.id {
                        try? await FirebaseDataService.shared.db
                            .collection("users").document(uid)
                            .collection("sessions").document(session.id)
                            .delete()
                    }
                    await MainActor.run { dismiss() }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This session will be permanently removed from your history.")
        }
        .confirmationDialog("Session Options", isPresented: $showOptions, titleVisibility: .visible) {
            Button("Report User", role: .destructive) {
                // Placeholder
            }
            if session.status == .upcoming {
                Button("Cancel Session", role: .destructive) {
                    showCancel = true
                }
            }
            Button("Mute Notifications") {
                // Placeholder
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct DetailsInfoLabel: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(AppTheme.Typography.caption)
            Text(text)
                .font(AppTheme.Typography.badge)
        }
        .foregroundColor(.white)
    }
}
