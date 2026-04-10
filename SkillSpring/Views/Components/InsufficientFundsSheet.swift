import SwiftUI

struct InsufficientFundsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.red.opacity(0.1)).frame(width: 60, height: 60)
                    Image(systemName: "exclamationmark.circle.fill").font(.title).foregroundColor(.red)
                }
                
                VStack(spacing: 4) {
                    Text("Not Enough SkillCredits")
                        .font(.system(size: 20, weight: .bold))
                    Text("You need 52 more SKP to book this session.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 12) {
                QuickTopUpCard(amount: 500, price: "Rs. 500")
                QuickTopUpCard(amount: 1000, price: "Rs. 1000")
            }
            
            Button(action: { }) {
                Text("Top Up Now")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
            }
            
            Button(action: { dismiss() }) {
                Text("Maybe Later")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            Text("Earn credits faster by completing your **Weekly Skills Challenge**.")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
    }
}

struct QuickTopUpCard: View {
    let amount: Int
    let price: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(amount) SKP")
                .font(.system(size: 14, weight: .bold))
            Text(price)
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}
