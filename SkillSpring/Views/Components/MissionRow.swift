import SwiftUI

struct MissionRow: View {
    let mission: SkillMission
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(mission.status == .completed ? AppTheme.Colors.primary.opacity(0.1) : Color(.systemGray6))
                    .frame(width: 44, height: 44)
                
                if mission.status == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mission.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mission.status == .completed ? .gray : .primary)
                
                Text(mission.status == .completed ? "DUE IN 2 DAYS" : "AVAILABLE NOW")
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(mission.status == .completed ? .gray : AppTheme.Colors.accent)
            }
            
            Spacer()
            
            Text("+\(mission.rewardAmount) SKP")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(mission.status == .completed ? .gray : AppTheme.Colors.primary)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}
