import SwiftUI

// MARK: - PaySessionView
// Modal payment review screen that shows SKP balance, pricing breakdown,
// and confirms the booking transaction.
struct PaySessionView: View {
    @ObservedObject var viewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Indicator
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Pay Session")
                    .font(AppTheme.Typography.title2)
                
                // Details Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.instructor.skillsToTeach.first ?? "Skill Session")
                                .font(AppTheme.Typography.headline)
                            Text("\(viewModel.isOnline ? "Online" : "In-Person") • \(viewModel.selectedDate.formatted(.dateTime.month(.abbreviated).day())) • \(viewModel.selectedTime)")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .combine)
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("YOUR SKP BALANCE")
                                .font(AppTheme.Typography.badge)
                                .foregroundColor(.gray)
                            Text("\(viewModel.userBalance) SKP")
                                .font(AppTheme.Typography.subheadline)
                        }
                        Spacer()
                        if viewModel.userBalance < viewModel.totalPrice {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Your SKP balance: \(viewModel.userBalance) SKP. \(viewModel.userBalance < viewModel.totalPrice ? "Insufficient funds." : "")")
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(16)
                
                // Breakdown
                VStack(spacing: 12) {
                    PriceRow(label: "Session rate (60 min)", value: "\(viewModel.sessionPrice) SKP")
                    PriceRow(label: "Platform fee (10%)", value: "\(viewModel.platformFee) SKP")
                    Divider()
                    PriceRow(label: "Total", value: "\(viewModel.totalPrice) SKP", isBold: true)
                }
                
                Spacer()
                
                // Action
                Button(action: { 
                    viewModel.confirmBooking()
                    dismiss()
                }) {
                    Text("Confirm & Pay \(viewModel.totalPrice) SKP ->")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
                
                Text("SKP will be held in escrow and only released to the mentor after the session is successfully completed.")
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(24)
        }
    }
}

struct PriceRow: View {
    let label: String
    let value: String
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isBold ? AppTheme.Typography.callout.weight(.bold) : AppTheme.Typography.callout)
                .foregroundColor(isBold ? .black : .gray)
            Spacer()
            Text(value)
                .font(isBold ? AppTheme.Typography.title3.weight(.bold) : AppTheme.Typography.callout)
                .foregroundColor(isBold ? AppTheme.Colors.primary : .black)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
