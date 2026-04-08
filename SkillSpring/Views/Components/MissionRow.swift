import SwiftUI

struct MissionRow: View {
    let mission: SkillMission
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(mission.status == .completed ? AppTheme.Colors.primary : Color(.systemGray5), lineWidth: 2)
                    .frame(width: 24, height: 24)
                if mission.status == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mission.title)
                    .font(.system(size: 14, weight: .bold))
                Text(mission.status == .available ? "AVAILABLE NOW" : "DUE IN 2 DAYS")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("+\(mission.rewardAmount) SKP")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}
