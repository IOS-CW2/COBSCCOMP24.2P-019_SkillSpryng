import SwiftUI

struct LessonPlaylistRow: View {
    let index: Int
    let title: String
    let duration: String
    var isCompleted: Bool = false
    var isCurrent: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCurrent ? AppTheme.Colors.primary.opacity(0.1) : Color(.systemGray6))
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                } else if isCurrent {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(AppTheme.Colors.primary)
                } else {
                    Text("\(index)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isCurrent ? AppTheme.Colors.primary : .black)
                Text(isCurrent ? "\(duration) • In Progress" : duration)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !isCompleted && !isCurrent {
                Image(systemName: "play.circle")
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isCurrent ? AppTheme.Colors.primary.opacity(0.05) : Color.clear)
        .cornerRadius(12)
    }
}
