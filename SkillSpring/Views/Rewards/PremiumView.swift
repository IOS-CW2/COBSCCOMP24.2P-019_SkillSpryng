import SwiftUI
import StoreKit

// MARK: - PremiumView
// Subscription purchase screen that presents SkillSpryng Pro plans.
// Handles plan selection, price display, StoreKit purchases, restores,
// and success feedback through an overlay toast.
struct PremiumView: View {
    @StateObject private var storeKit = StoreKitService.shared
    @State private var selectedPlan: PlanType = .monthly
    @State private var showToast = false
    @Environment(\.dismiss) var dismiss

    enum PlanType { case monthly, yearly }

    private var selectedProduct: Product? {
        selectedPlan == .monthly ? storeKit.proMonthly : storeKit.proYearly
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {

                // MARK: Header
                AppHeader(title: "Go Premium", backAction: { dismiss() })
                    .padding(.top, 8)

                // MARK: Hero Banner (#34C759 → #FF9F0A per spec)
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "34C759"), Color(hex: "FF9F0A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 80, height: 80)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 40))
                        }
                        .accessibilityHidden(true)
                        VStack(spacing: 8) {
                            Text("SkillSpryng Pro")
                                .font(AppTheme.Typography.title)
                                .foregroundColor(.white)
                            Text("Unlock unlimited potential. Learn, teach, and earn without limits.")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(40)
                }
                .frame(height: 260)
                .padding(.horizontal)

                // MARK: Plan Toggle
                ZStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        ForEach([PlanType.monthly, .yearly], id: \.self) { plan in
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) { selectedPlan = plan }
                            }) {
                                Text(plan == .monthly ? "Monthly" : "Yearly")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(selectedPlan == plan ? .primary : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedPlan == plan ? Color.white : Color.clear)
                                    .cornerRadius(10)
                                    .padding(4)
                            }
                            .accessibilityAddTraits(selectedPlan == plan ? .isSelected : [])
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // "Save 40%" badge on yearly tab
                    if selectedPlan == .yearly {
                        Text("SAVE 40%")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(AppTheme.Colors.primary)
                            .cornerRadius(4)
                            .offset(x: -8, y: -18)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 60)

                // MARK: Free vs Pro Comparison Cards
                HStack(spacing: 12) {
                    // Free Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("FREE")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.gray)
                        Text("Standard")
                            .font(AppTheme.Typography.headline)

                        Divider()

                        ProFeatureRow(text: "5 matches / month", isIncluded: true)
                        ProFeatureRow(text: "Basic discovery", isIncluded: true)
                        ProFeatureRow(text: "Limited analytics", isIncluded: true)
                        ProFeatureRow(text: "Host paid sessions", isIncluded: false)
                        ProFeatureRow(text: "Verified badge", isIncluded: false)
                        ProFeatureRow(text: "Ad-free experience", isIncluded: false)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.systemGray4), lineWidth: 1))
                    .accessibilityElement(children: .contain)

                    // Pro Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("PRO")
                                .font(.system(size: 10, weight: .black))
                                .foregroundColor(.white)
                            Spacer()
                            Text("POPULAR")
                                .font(.system(size: 8, weight: .black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(hex: "FF9F0A"))
                                .cornerRadius(4)
                        }
                        Text("Pro")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(.white)

                        Divider().background(Color.white.opacity(0.3))

                        ProFeatureRow(text: "Unlimited matches", isIncluded: true, isPro: true)
                        ProFeatureRow(text: "Priority discovery", isIncluded: true, isPro: true)
                        ProFeatureRow(text: "Full analytics", isIncluded: true, isPro: true)
                        ProFeatureRow(text: "Host paid sessions", isIncluded: true, isPro: true)
                        ProFeatureRow(text: "Verified badge", isIncluded: true, isPro: true)
                        ProFeatureRow(text: "Ad-free experience", isIncluded: true, isPro: true)
                    }
                    .padding()
                    .background(Color(hex: "34C759").gradient)
                    .cornerRadius(20)
                    .accessibilityElement(children: .contain)
                }
                .padding(.horizontal)

                // MARK: Price Display
                // Shows the currently selected plan price and any savings
                // for choosing the yearly subscription.
                VStack(spacing: 6) {
                    if selectedPlan == .monthly {
                        Text(storeKit.proMonthly?.displayPrice ?? "$6.99")
                            .font(AppTheme.Typography.largeTitle)
                        + Text(" / month")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                        Text("7-day free trial included")
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    } else {
                        HStack(spacing: 8) {
                            Text(storeKit.proYearly?.displayPrice ?? "$49.99")
                                .font(AppTheme.Typography.largeTitle)
                            Text("$83.88")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                        Text(" / year")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                        Text("You save $33.89 annually")
                            .font(AppTheme.Typography.footnote)
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                // MARK: CTA Button
                VStack(spacing: 16) {
                    Button(action: {
                        guard let product = selectedProduct else { return }
                        Task {
                            let success = await storeKit.purchase(product)
                            if success {
                                withAnimation { showToast = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { showToast = false }
                                }
                            }
                        }
                    }) {
                        HStack {
                            if storeKit.isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "crown.fill")
                            }
                            Text(selectedPlan == .monthly ? "Start 7-Day Free Trial" : "Get Pro Yearly")
                                .font(AppTheme.Typography.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "34C759"), Color(hex: "FF9F0A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .disabled(storeKit.isPurchasing)

                    // Products loading state
                    if storeKit.products.isEmpty {
                        HStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            Text("Loading products…")
                                .font(AppTheme.Typography.callout)
                                .foregroundColor(.orange)
                        }
                        .padding(.vertical, 4)
                    }

                    // Diagnostic error if StoreKit config not linked
                    if storeKit.products.isEmpty, let error = storeKit.purchaseError {
                        Text("⚠️ " + error)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    } else if let error = storeKit.purchaseError {
                        Text(error)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // Restore Purchases
                    // Reconnects the app with previous StoreKit subscriptions.
                    Button(action: {
                        Task { await storeKit.restorePurchases() }
                    }) {
                        Text("Restore Purchases")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(AppTheme.Colors.primary)
                    }

                    // Footer
                    VStack(spacing: 4) {
                        HStack(spacing: 16) {
                            Button("Terms of Use") {
                                if let url = URL(string: "https://skillspryng.com/terms") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.gray)
                            Button("Privacy Policy") {
                                if let url = URL(string: "https://skillspryng.com/privacy") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.gray)
                        }
                        Text("Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.")
                            .font(AppTheme.Typography.micro)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .task { await storeKit.loadProducts() }
        .overlay(alignment: .top) {
            if showToast || storeKit.isUserPro {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome to Pro! 👑")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.white)
                        Text("Your subscription is now active.")
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "34C759").gradient))
                .padding(.horizontal)
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showToast)
            }
        }
    }
}

// MARK: - ProFeatureRow
struct ProFeatureRow: View {
    let text: String
    let isIncluded: Bool
    var isPro: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isIncluded ? "checkmark" : "xmark")
                .font(AppTheme.Typography.badge)
                .foregroundColor(isIncluded ? (isPro ? .white : .green) : Color(.systemGray3))
            Text(text)
                .font(AppTheme.Typography.caption)
                .foregroundColor(isPro ? .white.opacity(0.9) : (isIncluded ? .primary : Color(.systemGray3)))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(isIncluded ? "Included:" : "Not included:") \(text)")
    }
}
