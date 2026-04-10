import SwiftUI

struct ChildSafetyView: View {
    @State private var isAdultMode = true // Mock state to switch between Adult/Child views
    @Environment(\.dismiss) var dismiss
    
    // Adult State Toggles
    @State private var restrictedContent = true
    @State private var verifiedInstructors = true
    @State private var privateProfile = false
    @State private var directMsgRestrictions = true
    @State private var videoRecording = true
    @State private var shareActivity = true
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Child Safety", backAction: { dismiss() })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Safety Hero Card
                    SafetyHeroCard(
                        title: "Protected Environment",
                        subtitle: "Enhanced security layers are managing your profile to ensure a respectful and secure digital experience.",
                        isActive: true
                    )
                    .padding(.horizontal)
                    
                    if !isAdultMode {
                        // CHILD VIEW - Simplified UI
                        Button(action: { }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text("Manage with Parent PIN")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "CONTENT & SAFETY")
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "eye.slash.fill", title: "Filter Explicit Content", toggleValue: .constant(true))
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "safari.fill", title: "Safe Search Mode", toggleValue: .constant(true))
                            }
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "COMMUNICATION")
                            
                            SettingsRow(icon: "message.badge.fill", title: "Direct Message Restrictions", toggleValue: .constant(true))
                                .padding(.horizontal)
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Toggle for demo
                        Button("Switch to Adult View") { isAdultMode.toggle() }
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                    } else {
                        // ADULT VIEW - Control Panel
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "CONTENT SAFETY")
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "exclamationmark.shield.fill", title: "Restricted Content", toggleValue: $restrictedContent)
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "star.bubble.fill", title: "Verified Instructors Only", toggleValue: $verifiedInstructors)
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "lock.fill", title: "Private Profile", toggleValue: $privateProfile)
                            }
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "COMMUNICATION")
                            
                            VStack(spacing: 12) {
                                SettingsRow(icon: "message.fill", title: "Direct Messaging", toggleValue: $directMsgRestrictions)
                                
                                Button(action: { }) {
                                    Text("Configure Access")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.primary, lineWidth: 1))
                                }
                                
                                Divider().padding(.vertical, 8)
                                
                                SettingsRow(icon: "video.fill", title: "Video Recording", toggleValue: $videoRecording)
                                
                                Button(action: { }) {
                                    Text("Enable Always")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(AppTheme.Colors.primary)
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "TIME MANAGEMENT")
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "clock.fill", title: "Daily Session Limit", value: "3 Sessions")
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "moon.stars.fill", title: "Schedule Restrictions", value: "Edit")
                            }
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "REPORTING")
                            
                            SettingsRow(icon: "doc.text.fill", title: "Activity Report")
                                .padding(.horizontal)
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // Toggle for demo
                        Button("Switch to Child View") { isAdultMode.toggle() }
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer().frame(height: 60)
                }
                .padding(.top)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
