import SwiftUI
import StoreKit

struct CreditPackCard: View {
    let pack: CreditPack
    var onBuy: () -> Void = {}
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                if pack.isBestValue {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(AppTheme.Typography.caption2)
                        Text("BEST VALUE")
                            .font(.system(size: 8, weight: .black))
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(4)
                }
                
                HStack(alignment: .center, spacing: 8) {
                    Text("\(pack.amount.formatted())")
                        .font(AppTheme.Typography.title)
                    Text("SKP")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.gray)
                }
                
                if let bonus = pack.bonusAmount {
                    Text("+\(bonus) Bonus Credits")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            Spacer()
            
            Button(action: onBuy) {
                Text("Buy for \(pack.price)")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(.white)
                    .frame(width: 140)
                    .padding(.vertical, 14)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

// MARK: - StoreKitCreditCard
// Renders a real StoreKit product card with live pricing and a wired purchase button.
struct StoreKitCreditCard: View {
    let product: Product
    @ObservedObject var storeKit: StoreKitService
    @State private var isPurchasingThis = false

    private var creditsAmount: Int {
        if product.id.contains("credits.100") { return 100 }
        if product.id.contains("credits.500") { return 500 }
        if product.id.contains("credits.1200") { return 1200 }
        return 0
    }

    private var isBestValue: Bool { product.id.contains("credits.500") }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                if isBestValue {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles").font(AppTheme.Typography.caption2)
                        Text("BEST VALUE").font(.system(size: 8, weight: .black))
                    }
                    .foregroundColor(AppTheme.Colors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .cornerRadius(4)
                }

                HStack(alignment: .center, spacing: 8) {
                    Text("\(creditsAmount)")
                        .font(AppTheme.Typography.title)
                    Text("SKP")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.gray)
                }

                Text(product.description)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: {
                isPurchasingThis = true
                Task {
                    _ = await storeKit.purchase(product)
                    isPurchasingThis = false
                }
            }) {
                Group {
                    if isPurchasingThis {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Buy \(product.displayPrice)")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 140)
                .padding(.vertical, 14)
                .background(AppTheme.Colors.primary)
                .cornerRadius(12)
            }
            .disabled(isPurchasingThis)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

