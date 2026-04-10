import SwiftUI

struct CreditPackCard: View {
    let pack: CreditPack
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if pack.isBestValue {
                    Text("BEST VALUE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(pack.amount)")
                        .font(.system(size: 24, weight: .bold))
                    Text("SKP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                }
                
                if let bonus = pack.bonusAmount {
                    Text("+\(bonus) Bonus Credits")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            Spacer()
            
            Button(action: { }) {
                Text("Buy for \(pack.price)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
    }
}
