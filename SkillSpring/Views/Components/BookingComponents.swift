import SwiftUI

struct FormatSelector: View {
    @Binding var isOnline: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            FormatCard(title: "Online", icon: "video.fill", isSelected: isOnline) {
                isOnline = true
            }
            FormatCard(title: "In-Person", icon: "person.2.fill", isSelected: !isOnline) {
                isOnline = false
            }
        }
    }
}

struct FormatCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(AppTheme.Typography.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? AppTheme.Colors.primary.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(isSelected ? AppTheme.Colors.primary : .gray)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct SelectionChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.subheadline)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? AppTheme.Colors.primary : Color.white)
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct DateChip: View {
    let date: Int
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(day)
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                Text("\(date)")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(width: 50, height: 70)
            .background(isSelected ? AppTheme.Colors.primary : Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
