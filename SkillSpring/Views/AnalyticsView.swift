import SwiftUI

struct AnalyticsView: View {
    let data = MockDataProvider.shared.analyticsData
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("SkillSpryng")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "00A86B"))
                    Spacer()
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Title Area
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learning Pulse")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("You're in the top 5% of active learners this \nweek.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Streak Card
                StreakCard(streak: data.streakDays)
                    .padding(.horizontal)
                
                // Stats Grid
                HStack(spacing: 16) {
                    StatCard(title: "SESSIONS", value: "\(data.sessionsCount)", subValue: nil, iconName: nil)
                    StatCard(title: "FOCUS HOURS", value: "\(data.focusHours)", subValue: nil, iconName: nil)
                    StatCard(title: "SKILLS PRO", value: "\(data.skillsPro)", subValue: nil, iconName: nil)
                }
                .padding(.horizontal)
                
                // Karma Points Card
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.orange)
                    Text("KARMA POINTS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Top 5%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .overlay(
                    Text("\(data.karmaPoints)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                )
                .frame(height: 80)
                .padding(.horizontal)
                
                // Growth Trajectory section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Growth Trajectory")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        HStack(spacing: 4) {
                            Text("7 DAYS")
                                .font(.system(size: 8, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "00A86B"))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                            Text("30 DAYS")
                                .font(.system(size: 8, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    GrowthChart(points: data.growthHistory)
                        .frame(height: 180)
                }
                .padding(.horizontal)
                
                // Skill Progression
                VStack(alignment: .leading, spacing: 20) {
                    Text("Skill Progression")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(data.skillProgress) { progress in
                        SkillProgressBar(
                            name: progress.name,
                            percentage: progress.percentage,
                            subheadline: progress.level,
                            color: progress.name.contains("Fullstack") ? .blue : .green
                        )
                    }
                }
                .padding(.horizontal)
                
                // Next Milestone Card
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.yellow.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "trophy.fill").foregroundColor(.yellow))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next Milestone")
                            .font(.system(size: 14, weight: .bold))
                        Text("Complete 3 more peer reviews to unlock 'Community Catalyst' badge.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer().frame(height: 100)
            }
            .padding(.top)
        }
    }
}

// Sub-components
struct StreakCard: View {
    let streak: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                    Text("\(streak) Day Streak!")
                        .fontWeight(.bold)
                }
                .font(.headline)
                .foregroundColor(.white)
                
                Text("Keep growing your garden")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack {
                Text("LEVEL 4")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                Image(systemName: "bolt.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.Gradients.streakCard)
        .cornerRadius(AppTheme.Radius.xl)
    }
}

struct GrowthChart: View {
    let points: [GrowthPoint]
    
    var body: some View {
        VStack {
            ZStack {
                // Background Lines
                VStack {
                    Divider()
                    Spacer()
                    Divider()
                    Spacer()
                    Divider()
                }
                
                // Gradient Path
                GeometryReader { geo in
                    let path = createPath(in: geo.size)
                    
                    ZStack {
                        path
                            .stroke(AppTheme.Colors.primary, lineWidth: 3)
                        
                        createFilledPath(from: path, in: geo.size)
                            .fill(AppTheme.Gradients.chartFill)
                    }
                }
            }
            
            HStack {
                ForEach(points) { point in
                    Text(point.day)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func createPath(in size: CGSize) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        let stepX = size.width / CGFloat(points.count - 1)
        let maxY = points.map { $0.value }.max() ?? 100
        
        func getY(for value: Double) -> CGFloat {
            return size.height - CGFloat(value / maxY) * size.height
        }
        
        path.move(to: CGPoint(x: 0, y: getY(for: points[0].value)))
        
        for i in 1..<points.count {
            let x = CGFloat(i) * stepX
            let y = getY(for: points[i].value)
            
            // Smooth curve
            let prevX = CGFloat(i - 1) * stepX
            let prevY = getY(for: points[i - 1].value)
            let midX = (prevX + x) / 2
            
            path.addCurve(to: CGPoint(x: x, y: y), 
                          control1: CGPoint(x: midX, y: prevY), 
                          control2: CGPoint(x: midX, y: y))
        }
        
        return path
    }
    
    private func createFilledPath(from path: Path, in size: CGSize) -> Path {
        var filledPath = path
        filledPath.addLine(to: CGPoint(x: size.width, y: size.height))
        filledPath.addLine(to: CGPoint(x: 0, y: size.height))
        filledPath.closeSubpath()
        return filledPath
    }
}
