import SwiftUI

struct LearningAnalyticsView: View {
    let data = MockDataProvider.shared.analyticsData
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(title: "Learning Analytics", backAction: { dismiss() })
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Title Area
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Learning Pulse")
                            .font(.system(size: 28, weight: .bold))
                        Text("You're in the top 5% of active learners this week.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Streak Card (Updated to Blue/Cyan Gradient)
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "276EF1"), Color(hex: "06C1FF")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.white)
                                    Text("7 Day Streak!")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Text("Keep growing your garden")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("LEVEL 4")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                Image(systemName: "bolt.horizontal.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(24)
                    }
                    .frame(height: 120)
                    .padding(.horizontal)
                    
                    // Stats Grid
                    HStack(spacing: 12) {
                        StatChip(title: "SESSIONS", value: "24", color: .blue)
                        StatChip(title: "FOCUS HOURS", value: "38.5", color: .green)
                        StatChip(title: "SKILLS PRO", value: "18", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Karma Points Card
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.orange)
                            .padding(10)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("KARMA POINTS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("1,240")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Top 5%")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Growth Trajectory section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Growth Trajectory")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            HStack(spacing: 4) {
                                FilterChip(title: "7 DAYS", isSelected: true, action: { })
                                FilterChip(title: "30 DAYS", isSelected: false, action: { })
                            }
                        }
                        
                        GrowthChart(points: data.growthHistory)
                            .frame(height: 180)
                    }
                    .padding(.horizontal)
                    
                    // Skill Progression
                    VStack(alignment: .leading, spacing: 20) {
                        SectionHeader(title: "Skill Progression")
                        
                        VStack(spacing: 16) {
                            SkillProgressRow(name: "Fullstack Development", level: "Level 4 • Pro", percentage: 0.85, color: .orange)
                            SkillProgressRow(name: "UI/UX Design Strategy", level: "Level 2 • Intermediate", percentage: 0.42, color: .blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Focus Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Focus Breakdown")
                        
                        VStack(spacing: 12) {
                            FocusBreakdownRow(label: "TEACHING EFFICIENCY", percentage: 82, color: .green)
                            FocusBreakdownRow(label: "LEARNING INTAKE", percentage: 64, color: .green)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Next Milestone Card
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next Milestone")
                                .font(.system(size: 12, weight: .bold))
                            Text("Complete 3 more peer reviews to unlock 'Community Catalyst' badge.")
                                .font(.system(size: 10))
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
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct StatChip: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 18, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct SkillProgressRow: View {
    let name: String
    let level: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.system(size: 12, weight: .bold))
                        Text(level)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("\(Int(percentage * 100))%")
                        .font(.system(size: 12, weight: .bold))
                }
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray6))
                        .frame(height: 6)
                    Capsule()
                        .fill(color)
                        .frame(width: 200 * CGFloat(percentage), height: 6) // Mock width
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct FocusBreakdownRow: View {
    let label: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(percentage)%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray6))
                    .frame(height: 4)
                Capsule()
                    .fill(color)
                    .frame(width: 300 * CGFloat(percentage) / 100, height: 4) // Mock width
            }
        }
    }
}


// Sub-components


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
