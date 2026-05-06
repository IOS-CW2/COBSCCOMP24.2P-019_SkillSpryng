import SwiftUI
import Combine

struct WalletView: View {
    @State private var balance: Int = 0
    @State private var transactions: [CreditTransaction] = []
    @Environment(\.dismiss) var dismiss
    @StateObject private var rewardsVM = RewardsViewModel()
    @StateObject private var storeKit = StoreKitService.shared

    // MARK: - Quick-action sheet state
    @State private var showEarnSheet     = false
    @State private var showSpendSheet    = false
    @State private var showTransferSheet = false
    @State private var showAllCreditsSheet = false
    
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
                                    .font(AppTheme.Typography.largeTitle)
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
                    WalletActionView(icon: "plus.circle.fill",               label: "EARN",     color: .green) { showEarnSheet     = true }
                    WalletActionView(icon: "bag.circle.fill",                label: "SPEND",    color: .blue)  { showSpendSheet    = true }
                    WalletActionView(icon: "arrow.left.arrow.right.circle.fill", label: "TRANSFER", color: .teal)  { showTransferSheet = true }
                }
                .padding(.vertical, 8)
                
                // Transaction History Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Transaction History")
                        .font(.headline)
                        .padding(.horizontal)

                    if transactions.isEmpty {
                        Text("No transactions yet")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(transactions.prefix(10)) { tx in
                                TransactionRow(transaction: tx)
                                Divider().padding(.horizontal)
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }

                // Replenish Credits Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Replenish Credits")
                            .font(.headline)
                        Spacer()
                        Button("VIEW ALL") { showAllCreditsSheet = true }
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    if storeKit.creditPacks.isEmpty {
                        // Fallback to Firestore data while StoreKit loads
                        VStack(spacing: 16) {
                            ForEach(rewardsVM.creditPacks) { pack in
                                CreditPackCard(pack: pack) {
                                    Task { await storeKit.loadProducts() }
                                }
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
            transactions = await FirebaseDataService.shared.fetchTransactions()
        }
        .onReceive(storeKit.$creditsToast.compactMap { $0 }) { _ in
            Task {
                if let user = await FirebaseDataService.shared.fetchCurrentUser() {
                    balance = user.walletBalance
                }
            }
        }
        // MARK: - EARN sheet: ways to earn SKP credits
        .sheet(isPresented: $showEarnSheet) {
            EarnCreditsSheet()
                .presentationDetents([.medium])
        }
        // MARK: - SPEND sheet: go to PremiumView / credit packs
        .sheet(isPresented: $showSpendSheet) {
            NavigationView { PremiumView() }
        }
        .sheet(isPresented: $showAllCreditsSheet) {
            NavigationView {
                CreditOptionsSheet(
                    fallbackCreditPacks: rewardsVM.creditPacks,
                    storeKit: storeKit
                ) {
                    showAllCreditsSheet = false
                    showSpendSheet = true
                }
            }
        }
        // MARK: - TRANSFER sheet: explain credit transfer rules
        .confirmationDialog(
            "Transfer Credits",
            isPresented: $showTransferSheet,
            titleVisibility: .visible
        ) {
            Button("Buy More Credits") { showSpendSheet = true }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Credits can be used to book sessions or rewarded for teaching. " +
                 "Direct peer-to-peer transfers are coming in a future update.")
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
            struct CreditOptionsSheet: View {
                let fallbackCreditPacks: [CreditPack]
                @ObservedObject var storeKit: StoreKitService
                let onShowPremium: () -> Void

                @Environment(\.dismiss) private var dismiss

                var body: some View {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            AppHeader(title: "Top Up Options", backAction: { dismiss() })
                                .padding(.top, 8)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Choose how you want to top up")
                                    .font(AppTheme.Typography.title)
                                Text("Buy credit packs for sessions or upgrade for premium perks.")
                                    .font(AppTheme.Typography.callout)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 16) {
                                Text("Credit Packs")
                                    .font(.headline)

                                if storeKit.creditPacks.isEmpty {
                                    VStack(spacing: 16) {
                                        ForEach(fallbackCreditPacks) { pack in
                                            CreditPackCard(pack: pack) {
                                                Task { await storeKit.loadProducts() }
                                            }
                                        }
                                    }
                                } else {
                                    VStack(spacing: 16) {
                                        ForEach(storeKit.creditPacks, id: \.id) { product in
                                            StoreKitCreditCard(product: product, storeKit: storeKit)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Need more than credits?")
                                    .font(.headline)
                                Button(action: onShowPremium) {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                        Text("View Premium Plans")
                                            .font(AppTheme.Typography.headline)
                                        Spacer()
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.Colors.primary)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal)

                            Spacer().frame(height: 32)
                        }
                    }
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                    .task {
                        await storeKit.loadProducts()
                    }
                }
            }
    }
}

struct WalletActionView: View {
    let icon: String
    let label: String
    let color: Color
    /// Called when the user taps this action button.
    var action: () -> Void = { }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(color)
                    .background(Circle().fill(Color.white).shadow(color: Color.black.opacity(0.05), radius: 5))

                Text(label)
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.gray)
            }
        }
        .accessibilityLabel(label)
        .accessibilityHint("Double-tap to \(label.lowercased()) SKP credits")
    }
}

struct TransactionRow: View {
    let transaction: CreditTransaction

    private var isCredit: Bool { transaction.amount > 0 }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCredit ? Color.green.opacity(0.15) : Color.red.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: isCredit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundColor(isCredit ? .green : .red)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(AppTheme.Typography.subheadline)
                    .lineLimit(1)
                Text(transaction.createdAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(isCredit ? "+" : "")\(transaction.amount) SKP")
                .font(AppTheme.Typography.subheadline.weight(.semibold))
                .foregroundColor(isCredit ? .green : .red)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - EarnCreditsSheet

/// Presented when the user taps the EARN quick-action on WalletView.
/// Lists every way a user can accumulate SKP credits within the app.
struct EarnCreditsSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct EarnMethod: Identifiable {
        let id = UUID()
        let icon: String
        let color: Color
        let title: String
        let subtitle: String
        let reward: String
    }

    private let methods: [EarnMethod] = [
        EarnMethod(
            icon: "person.2.fill",
            color: .blue,
            title: "Teach a Session",
            subtitle: "Host an in-person or online skill session and earn credits when it completes.",
            reward: "+120 SKP / hr"
        ),
        EarnMethod(
            icon: "checkmark.seal.fill",
            color: .green,
            title: "Complete Skill Missions",
            subtitle: "Finish the weekly missions shown in the Missions section below your balance.",
            reward: "+50–200 SKP"
        ),
        EarnMethod(
            icon: "star.fill",
            color: .orange,
            title: "Get a 5-Star Rating",
            subtitle: "Receive a top rating from a learner after a session to earn bonus credits.",
            reward: "+30 SKP / review"
        ),
        EarnMethod(
            icon: "person.badge.plus",
            color: .purple,
            title: "Refer a Friend",
            subtitle: "Invite someone to SkillSpryng. You both earn credits when they book their first session.",
            reward: "+100 SKP"
        ),
        EarnMethod(
            icon: "flame.fill",
            color: .red,
            title: "Keep Your Streak",
            subtitle: "Maintain a daily learning or teaching streak to earn multiplier bonuses.",
            reward: "+10 SKP / day"
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .accessibilityHidden(true)

            // Title
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ways to Earn SKP")
                        .font(AppTheme.Typography.title)
                    Text("SkillSpryng Credits — spend them on sessions")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.6))
                }
                .accessibilityLabel("Close")
            }
            .padding(.horizontal)
            .padding(.bottom, 20)

            // Earn methods list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(methods) { method in
                        HStack(spacing: 14) {
                            // Icon badge
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(method.color.opacity(0.12))
                                    .frame(width: 48, height: 48)
                                Image(systemName: method.icon)
                                    .font(.title3)
                                    .foregroundColor(method.color)
                            }
                            .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(method.title)
                                    .font(AppTheme.Typography.subheadline)
                                Text(method.subtitle)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Text(method.reward)
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(method.color)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(method.title). \(method.subtitle). Reward: \(method.reward)")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
