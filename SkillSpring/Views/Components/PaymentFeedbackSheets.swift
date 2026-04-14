import SwiftUI

struct PaymentFailedSheet: View {
    @Environment(\.dismiss) private var dismiss
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.red.opacity(0.1)).frame(width: 80, height: 80)
                    Image(systemName: "xmark.circle.fill").font(.system(size: 60)).foregroundColor(.red)
                }
                .accessibilityHidden(true)
                
                VStack(spacing: 8) {
                    Text("Payment Failed")
                        .font(AppTheme.Typography.title2)
                    Text("Transaction failed — your SKP was not deducted.")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 20)
            
            VStack(spacing: 12) {
                Button(action: {
                    dismiss()
                    retryAction()
                }) {
                    Text("Try Again")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
                
                Button(action: { }) {
                    Text("Contact Support")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(AppTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.Colors.primary, lineWidth: 1))
                }
                
                Button(action: { dismiss() }) {
                    Text("Cancel Booking")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.red)
                        .padding(.top, 12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct PaymentConfirmationSheet: View {
    let amount: Int
    let instructorName: String
    var confirmAction: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.Colors.primary)
                    .accessibilityHidden(true)
                
                Text("Confirm Payment")
                    .font(AppTheme.Typography.title3)
            }
            
            VStack(spacing: 16) {
                HStack {
                    Text("Payment to")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(instructorName)
                        .fontWeight(.bold)
                }
                HStack {
                    Text("Total Amount")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(amount) SKP")
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Button(action: {
                dismiss()
                confirmAction()
            }) {
                Text("Pay Now")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
            }
            
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
    }
}
