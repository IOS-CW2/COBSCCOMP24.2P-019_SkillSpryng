import SwiftUI

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
                    .font(.system(size: 24, weight: .bold))
                
                // Details Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.instructor.skillsToTeach.first ?? "Skill Session")
                                .font(.system(size: 18, weight: .bold))
                            Text("Online • Oct \(viewModel.selectedDate), \(viewModel.selectedTime)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("YOUR SKP BALANCE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.gray)
                            Text("\(viewModel.userBalance) SKP")
                                .font(.system(size: 14, weight: .bold))
                        }
                        Spacer()
                        if viewModel.userBalance < viewModel.totalPrice {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                        }
                    }
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
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
                
                Text("SKP will be held in escrow and only released to the mentor after the session is successfully completed.")
                    .font(.system(size: 10))
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
                .font(.system(size: isBold ? 16 : 14, weight: isBold ? .bold : .regular))
                .foregroundColor(isBold ? .black : .gray)
            Spacer()
            Text(value)
                .font(.system(size: isBold ? 20 : 14, weight: isBold ? .bold : .bold))
                .foregroundColor(isBold ? AppTheme.Colors.primary : .black)
        }
    }
}
