import SwiftUI

struct MyMatchesInboxView: View {
    @StateObject private var discoverVM = DiscoverViewModel()
    @State private var selectedTab = 0
    @Namespace private var animation
    let tabs = ["Requests", "Active", "Archived"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(title: "My Matches", showBackButton: true)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Matches")
                            .font(.system(size: 32, weight: .bold))
                        Text("Connect with experts who match your growth path.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Segmented Control
                    HStack(spacing: 0) {
                        ForEach(0..<tabs.count, id: \.self) { index in
                            Button(action: { selectedTab = index }) {
                                VStack(spacing: 8) {
                                    Text(tabs[index])
                                        .font(.system(size: 14, weight: selectedTab == index ? .bold : .medium))
                                        .foregroundColor(selectedTab == index ? AppTheme.Colors.primary : .gray)
                                    
                                    ZStack {
                                        Capsule()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(height: 4)
                                        if selectedTab == index {
                                            Capsule()
                                                .fill(AppTheme.Colors.primary)
                                                .frame(height: 4)
                                                .matchedGeometryEffect(id: "tab", in: animation)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .accessibilityButton(label: "\(tabs[index]) tab")
                            .accessibilityAddTraits(selectedTab == index ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tab Content
                    if selectedTab == 0 {
                        RequestsView(discoverVM: discoverVM)
                    } else if selectedTab == 1 {
                        ActiveMatchesView(discoverVM: discoverVM)
                    } else {
                        ArchivedMatchesView(discoverVM: discoverVM)
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Requests Tab
struct RequestsView: View {
    @ObservedObject var discoverVM: DiscoverViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Incoming
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "INCOMING", actionTitle: "1 NEW", action: { })
                    .padding(.horizontal)
                
                ForEach(discoverVM.profiles.filter { $0.status == .requestIncoming }) { profile in
                    InboxMatchCard(profile: profile, type: .incoming)
                }
            }
            
            // Sent By You
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "SENT BY YOU")
                    .padding(.horizontal)
                
                ForEach(discoverVM.profiles.filter { $0.status == .requestSent }) { profile in
                    InboxMatchCard(profile: profile, type: .sent)
                }
            }
        }
    }
}

// MARK: - Active Tab
struct ActiveMatchesView: View {
    @ObservedObject var discoverVM: DiscoverViewModel
    var body: some View {
        VStack(spacing: 16) {
            ForEach(discoverVM.profiles.filter { $0.status == .active }) { profile in
                InboxMatchCard(profile: profile, type: .active)
            }
        }
    }
}

// MARK: - Archived Tab
struct ArchivedMatchesView: View {
    @ObservedObject var discoverVM: DiscoverViewModel
    var body: some View {
        VStack(spacing: 16) {
            ForEach(discoverVM.profiles.filter { $0.status == .archived }) { profile in
                // Using Marcus Chen as a mock for declined in this demo
                InboxMatchCard(profile: profile, type: .archived)
            }
            
            VStack(spacing: 16) {
                Image(systemName: "archivebox")
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.3))
                    .accessibilityHidden(true)
                Text("Archived matches are stored for 90 days before being permanently removed.")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)
        }
    }
}

enum InboxCardType {
    case incoming, sent, active, archived
}

struct InboxMatchCard: View {
    let profile: MatchProfile
    let type: InboxCardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(profile.imageUrl)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(profile.fullName)
                            .font(AppTheme.Typography.headline)
                        
                        if type == .archived && profile.fullName == "Marcus Chen" {
                             StatusBadge(text: "DECLINED", color: .red)
                        }
                    }
                    
                    Text(profile.role)
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    Text("\"\(profile.bio.prefix(60))...\"")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(type == .active ? "YESTERDAY" : "2H AGO")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.gray)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(profile.fullName), \(profile.role). \(type == .active ? "Active Match" : "")")
            
            // Action Buttons based on type
            HStack(spacing: 12) {
                switch type {
                case .incoming:
                    Button(action: { }) {
                        Text("Accept")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                    }
                    Button(action: { }) {
                        Text("Decline")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.2), lineWidth: 1))
                    }
                case .sent:
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Expires in 18h 23m", systemImage: "clock")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.orange)
                        
                        Button(action: { }) {
                            Text("Cancel Request")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.2), lineWidth: 1))
                        }
                    }
                case .active:
                    let conversation = Conversation(
                        id: profile.id,
                        participant: User(id: profile.id, fullName: profile.fullName, phoneNumber: "", profileImageURL: profile.imageUrl),
                        lastMessage: "Start a conversation",
                        lastMessageTime: "Now",
                        unreadCount: 0,
                        messages: []
                    )
                    NavigationLink(destination: ChatDetailView(conversation: conversation)) {
                        Text("Message")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.Colors.primary.opacity(0.05))
                            .cornerRadius(12)
                    }
                    .accessibilityIdentifier("messageMatchButton")

                    NavigationLink(destination: SessionBookingView(instructor: profile)) {
                        Text("Book Now")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(12)
                    }
                    .accessibilityIdentifier("bookNowButton")
                case .archived:
                    NavigationLink(destination: MatchDetailView(profile: profile)) {
                        Text(profile.fullName == "Sarah Jenkins" ? "Request Match Again" : "View Profile")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(profile.fullName == "Sarah Jenkins" ? AppTheme.Colors.primary : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(profile.fullName == "Sarah Jenkins" ? AppTheme.Colors.primary : Color.gray.opacity(0.3), lineWidth: 1))
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(type == .active ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
        .accessibilityIdentifier("inboxMatchCard")
    }
}
