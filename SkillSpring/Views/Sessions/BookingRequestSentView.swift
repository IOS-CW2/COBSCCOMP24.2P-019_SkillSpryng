import SwiftUI

struct BookingRequestSentView: View {
    let instructor: MatchProfile
    let date: Int
    let time: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 12) {
                Text("Request Sent!")
                    .font(.system(size: 28, weight: .bold))
                Text("Waiting for \(instructor.fullName) to accept your request.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Summary Card
            VStack(spacing: 20) {
                HStack {
                    Text("FORMAT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Online • Jitsi Meet")
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("MENTOR")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    HStack {
                        Image(instructor.imageUrl)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                        Text(instructor.fullName)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
                
                HStack {
                    Text("DATE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Tuesday, Oct \(date)")
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("TIME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(time) - 11:30 AM")
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("DURATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("60 min")
                        .font(.system(size: 12, weight: .bold))
                }
                
                HStack {
                    Text("COST")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("FREE (Request based)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 10)
            .padding(.horizontal)
            
            Text("Coach has 24 hours to respond. You'll be notified.")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
