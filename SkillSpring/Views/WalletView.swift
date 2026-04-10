import SwiftUI

struct WalletView: View {
    @State private var balance = MockDataProvider.shared.currentUser.walletBalance
    @Environment(\.dismiss) var dismiss
    let data = MockDataProvider.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                AppHeader(title: "Wallet", backAction: { dismiss() })
                
                // Balance Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Wallet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CURRENT WALLET BALANCE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(balance)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                Text("SKP")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.bottom, 4)
                            }
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.white)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: -8) {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 24, height: 24)
                                    .overlay(Image(systemName: "person.fill").font(.system(size: 10)).foregroundColor(.white))
                                    .overlay(Circle().stroke(AppTheme.Colors.primary, lineWidth: 2))
                            }
                        }
                        Text("Trusted by 14 local mentors")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(24)
                .background(AppTheme.Colors.primary)
                .cornerRadius(32)
                .padding(.horizontal)
                
                // Quick Actions
                HStack(spacing: 24) {
                    WalletActionCircle(icon: "plus", label: "EARN", color: .green)
                    WalletActionCircle(icon: "bag.fill", label: "SPEND", color: .blue)
                    WalletActionCircle(icon: "arrow.left.arrow.right", label: "TRANSFER", color: .teal)
                }
                .padding(.vertical)
                
                // Replenish Credits
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Replenish Credits", actionTitle: "VIEW ALL", action: { })
                    
                    VStack(spacing: 12) {
                        ForEach(data.creditPacks) { pack in
                            CreditPackCard(pack: pack)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Skill Missions
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Skill Missions")
                                .font(.headline)
                            Text("Earn while you grow")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(data.skillMissions) { mission in
                            MissionRow(mission: mission)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct WalletActionCircle: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        Button(action: { }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
    }
}
