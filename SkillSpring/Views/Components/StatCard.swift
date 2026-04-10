import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subValue: String?
    let iconName: String?
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = iconName {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundColor(.gray)
            } else {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                if let sub = subValue {
                    Text(sub)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}
