import SwiftUI

struct CredibilityCard: View {
    let title: String
    let score: Int
    let badge: String // e.g., "EXPERT", "PRO"
    let subheadline: String
    var studentsTaught: Int = 12
    var rating: Double = 4.9
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.headline)
                Spacer()
                Text(badge)
                    .font(AppTheme.Typography.badge)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badge == "EXPERT" ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                    .foregroundColor(badge == "EXPERT" ? .blue : .green)
                    .cornerRadius(4)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("CREDIBILITY SCORE", systemImage: "shield.fill")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(score)%")
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(height: 6)
                        Capsule()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: geo.size.width * CGFloat(score) / 100, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(studentsTaught) students taught • \(String(format: "%.1f", rating)) ★ • \(badge == "EXPERT" ? "4.9k" : "1.2k") views")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: -8) {
                        ForEach(0..<4) { i in
                            Image("instructor\(i % 2 + 1)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                        }
                        .accessibilityHidden(true)
                        Text("+4")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            StatusBadge(text: "Online", color: .green)
                            StatusBadge(text: "In-Person", color: .blue)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button(action: { }) {
                    HStack(spacing: 4) {
                        Text("Find Learners")
                        Image(systemName: "arrow.right")
                    }
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(AppTheme.Colors.primary)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(badge) badge. Credibility score: \(score)%. \(studentsTaught) students taught, \(String(format: "%.1f", rating)) stars.")
    }
}
