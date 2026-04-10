import SwiftUI

struct CreditPackCard: View {
    let pack: CreditPack
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                if pack.isBestValue {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 8))
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
                        .font(.system(size: 28, weight: .bold))
                    Text("SKP")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
                
                if let bonus = pack.bonusAmount {
                    Text("+\(bonus) Bonus Credits")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            Spacer()
            
            Button(action: { }) {
                Text("Buy for \(pack.price)")
                    .font(.system(size: 14, weight: .bold))
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
