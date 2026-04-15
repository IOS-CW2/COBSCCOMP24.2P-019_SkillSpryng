import SwiftUI
import Combine

struct WalletView: View {
    @State private var balance: Int = 0
    @Environment(\.dismiss) var dismiss
    @StateObject private var rewardsVM = RewardsViewModel()
    @StateObject private var storeKit = StoreKitService.shared
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                AppHeader(title: "Wallet", backAction: { dismiss() })
                
                // My Wallet Title Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Wallet")
                        .font(AppTheme.Typography.title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // High-Fidelity Balance Card
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "1D9E75"), Color(hex: "27E246")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Balance")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(balance) SKP")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Current Wallet Balance: \(balance) SKP")
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                Image(systemName: "creditcard.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        HStack {
                            HStack(spacing: -10) {
                                ForEach(0..<3) { i in
                                    Image("instructor\(i + 1)")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                                }
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Text("+12")
                                        .font(AppTheme.Typography.badge)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Text("Trusted by 14 local mentors")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Trusted by 14 local mentors")
                    }
                    .padding(32)
                }
                .padding(.horizontal)
                
                // Dashboard Quick Actions
                HStack(spacing: 32) {
                    WalletActionView(icon: "plus.circle.fill", label: "EARN", color: .green)
                    WalletActionView(icon: "bag.circle.fill", label: "SPEND", color: .blue)
                    WalletActionView(icon: "arrow.left.arrow.right.circle.fill", label: "TRANSFER", color: .teal)
                }
                .padding(.vertical, 8)
                
                // Replenish Credits Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Replenish Credits")
                            .font(.headline)
                        Spacer()
                        Button("VIEW ALL") { }
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    if storeKit.creditPacks.isEmpty {
                        // Fallback to Firestore data while StoreKit loads
                        VStack(spacing: 16) {
                            ForEach(rewardsVM.creditPacks) { pack in
                                CreditPackCard(pack: pack)
                            }
                        }
                    } else {
                        // Real StoreKit products
                        VStack(spacing: 16) {
                            ForEach(storeKit.creditPacks, id: \.id) { product in
                                StoreKitCreditCard(product: product, storeKit: storeKit)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Skill Missions Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Skill Missions")
                                .font(.headline)
                            Text("Earn while you grow")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(rewardsVM.skillMissions) { mission in
                            MissionRow(mission: mission)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .task { 
            await storeKit.loadProducts() 
            if let user = await FirebaseDataService.shared.fetchCurrentUser() {
                balance = user.walletBalance
            }
        }
        .onReceive(storeKit.$creditsToast.compactMap { $0 }) { _ in
            Task {
                if let user = await FirebaseDataService.shared.fetchCurrentUser() {
                    balance = user.walletBalance
                }
            }
        }
        .overlay(alignment: .top) {
            if let toast = storeKit.creditsToast {
                HStack(spacing: 12) {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.white)
                    Text(toast)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.green.gradient))
                .padding(.horizontal)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4), value: toast)
            }
        }
    }
}

struct WalletActionView: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        Button(action: { }) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .background(Circle().fill(Color.white).shadow(color: Color.black.opacity(0.05), radius: 5))
                
                Text(label)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.gray)
            }
        }
        .accessibilityLabel(label)
    }
}
