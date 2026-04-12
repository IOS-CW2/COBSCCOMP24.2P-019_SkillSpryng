import SwiftUI

struct ReviewRow: View {
    let name: String
    let time: String
    let comment: String
    let rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(name.prefix(1))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.gray)
                    )
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 14, weight: .bold))
                    Text(time)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(i < rating ? .orange : .gray.opacity(0.3))
                    }
                }
                .accessibilityHidden(true)
            }
            
            Text("\"\(comment)\"")
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.7))
                .italic()
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name). \(rating) out of 5 stars. \(comment). \(time)")
    }
}

#Preview {
    ReviewRow(name: "Sarah Mitchell", time: "Learner of UI Design • 2 days ago", comment: "Adrian is an incredible mentor. He doesn't just teach the craft, he teaches the mindset of a successful designer.", rating: 5)
        .padding()
}
