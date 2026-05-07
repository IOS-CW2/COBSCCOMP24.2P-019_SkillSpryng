import SwiftUI

struct ChildSafetyView: View {
    @State private var isAdultMode = false
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("skillspryng.parentPIN") private var savedPin: String = ""
    @State private var showingPinAlert = false
    @State private var showingSetupPinAlert = false
    @State private var enteredPin = ""
    
    // Adult State Toggles — persisted across launches
    @AppStorage("skillspryng.safety.restrictedContent")    private var restrictedContent = true
    @AppStorage("skillspryng.safety.verifiedInstructors")  private var verifiedInstructors = true
    @AppStorage("skillspryng.safety.privateProfile")       private var privateProfile = false
    @AppStorage("skillspryng.safety.directMsgRestrictions") private var directMsgRestrictions = true
    @AppStorage("skillspryng.safety.videoRecording")       private var videoRecording = true
    @AppStorage("skillspryng.safety.shareActivity")        private var shareActivity = true
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Child Safety", backAction: { dismiss() })
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Safety Hero Status Card
                    SafetyHeroCard(
                        title: "Protected Environment",
                        subtitle: "Enhanced security layers are managing your profile to ensure a respectful and secure digital experience.",
                        isActive: true
                    )
                    .padding(.horizontal)
                    
                    if !isAdultMode {
                        // CHILD VIEW - Display Mode
                        Button(action: { 
                            if savedPin.isEmpty {
                                showingSetupPinAlert = true
                            } else {
                                showingPinAlert = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "key.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                    .font(AppTheme.Typography.title3)
                                Text("Manage with Parent PIN")
                                    .font(AppTheme.Typography.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .accessibilityElement(children: .combine)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "CONTENT & SAFETY")
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "eye.slash.fill", title: "Filter Explicit Content", toggleValue: .constant(true))
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "safari.fill", title: "Safe Search Mode", toggleValue: .constant(true))
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "COMMUNICATION")
                            
                            SettingsRow(icon: "message.badge.fill", title: "Direct Message Restrictions", toggleValue: .constant(true))
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                        
                    } else {
                        // ADULT CONTROL PANEL
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "CONTENT & SAFETY")
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "nosign", title: "Restricted Content", toggleValue: $restrictedContent)
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "checkmark.seal.fill", title: "Verified Instructors", toggleValue: $verifiedInstructors)
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "lock.fill", title: "Private Profile", toggleValue: $privateProfile)
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "COMMUNICATION")
                            
                            VStack(spacing: 12) {
                                SettingsRow(icon: "message.fill", title: "Direct Messaging", toggleValue: $directMsgRestrictions)
                                
                                Button(action: { }) {
                                    Text("Configure Access")
                                        .font(AppTheme.Typography.subheadline)
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.primary, lineWidth: 1))
                                }
                                .padding(.horizontal)
                                
                                Divider().padding(.vertical, 8)
                                
                                SettingsRow(icon: "video.fill", title: "Video Recording", toggleValue: $videoRecording)
                                
                                Button(action: { }) {
                                    Text("Enable Always")
                                        .font(AppTheme.Typography.subheadline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(AppTheme.Colors.primary)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "TIME MANAGEMENT")
                            
                            VStack(spacing: 0) {
                                SettingsRow(icon: "timer", title: "Daily Session Limit", value: "3 Sessions")
                                Divider().padding(.leading, 48)
                                SettingsRow(icon: "calendar.badge.clock", title: "Schedule Restrictions", value: "Edit")
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "REPORTING")
                            
                            SettingsRow(icon: "doc.text.below.ecg.fill", title: "Activity Report", value: "Detailed history and logs")
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                        
                        // Switch to Child View Toggle
                        Button("Lock & Switch to Protected Child View") { 
                            if savedPin.isEmpty {
                                showingSetupPinAlert = true
                            } else {
                                isAdultMode = false 
                            }
                        }
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.top, 16)
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .alert("Setup Parent PIN", isPresented: $showingSetupPinAlert) {
            SecureField("New 4-digit PIN", text: $enteredPin)
                .keyboardType(.numberPad)
            Button("Save", action: {
                if enteredPin.count == 4 {
                    savedPin = enteredPin
                    isAdultMode = true
                }
                enteredPin = ""
            })
            Button("Cancel", role: .cancel, action: { enteredPin = "" })
        } message: {
            Text("Please create a 4-digit PIN to access parent controls.")
        }
        .alert("Enter Parent PIN", isPresented: $showingPinAlert) {
            SecureField("PIN", text: $enteredPin)
                .keyboardType(.numberPad)
            Button("Unlock", action: {
                if enteredPin == savedPin {
                    isAdultMode = true
                }
                enteredPin = ""
            })
            Button("Cancel", role: .cancel, action: { enteredPin = "" })
        } message: {
            Text("Please enter your 4-digit PIN.")
        }
    }
}
