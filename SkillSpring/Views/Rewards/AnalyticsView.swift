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
                    
                    // Analytics Header Area
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ANALYTICS DASHBOARD")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(AppTheme.Colors.primary)
                        
                        Text("Learning Pulse")
                            .font(AppTheme.Typography.title)
                        
                        Text("You're in the top 5% of active learners this week.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // High-Fidelity Streak Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "276EF1"), Color(hex: "06C1FF")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("7 Day Streak!")
                                        .font(AppTheme.Typography.title3)
                                        .foregroundColor(.white)
                                }
                                
                                Text("Keep growing your garden")
                                    .font(AppTheme.Typography.footnote)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .accessibilityElement(children: .combine)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("LEVEL 4")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundColor(.white.opacity(0.7))
                                    
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "bolt.horizontal.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                    )
                            }
                            .accessibilityElement(children: .combine)
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                    
                    // Stats Grid
                    HStack(spacing: 12) {
                        RefinedStatGap(label: "SESSIONS", value: "24", color: .blue)
                        RefinedStatGap(label: "FOCUS HOURS", value: "38.5", color: .teal)
                        RefinedStatGap(label: "SKILLS PRO", value: "18", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Karma Card (Mockup style)
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Text("KARMA POINTS")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("1,240")
                            .font(.system(size: 18, weight: .black))
                        
                        Text("TOP 5%")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Karma Points: 1,240. Top 5%")
                    
                    // Growth Trajectory Chart
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Growth Trajectory")
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 0) {
                                Text("7 DAYS").padding(.horizontal, 12).padding(.vertical, 6).background(AppTheme.Colors.primary).foregroundColor(.white).cornerRadius(6)
                                Text("30 DAYS").padding(.horizontal, 12).padding(.vertical, 6).foregroundColor(.gray)
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        GrowthChart(points: data.growthHistory)
                            .frame(height: 180)
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    // Skill Progression Grid
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Skill Progression")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            SkillProgressionRow(name: "Fullstack Development", level: "Level 4 • Pro", percentage: 0.85, color: .orange)
                            SkillProgressionRow(name: "UI/UX Design Strategy", level: "Level 2 • Intermediate", percentage: 0.42, color: .blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Focus Breakdown
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Focus Breakdown")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            HorizontalMetricRow(label: "TEACHING EFFICIENCY", percentage: 82, color: .green)
                            HorizontalMetricRow(label: "LEARNING INTAKE", percentage: 64, color: .green)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Next Milestone Card
                    HStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .padding(12)
                            .background(Circle().fill(Color.yellow.opacity(0.15)))
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next Milestone")
                                .font(AppTheme.Typography.sectionHeader)
                            Text("Complete 3 more peer reviews to unlock 'Community Catalyst' badge.")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.05))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct RefinedStatGap: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.gray)
            Text(value)
                .font(AppTheme.Typography.title2)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct SkillProgressionRow: View {
    let name: String
    let level: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(AppTheme.Typography.subheadline)
                        Text(level)
                            .font(AppTheme.Typography.caption2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("\(Int(percentage * 100))%")
                        .font(.system(size: 14, weight: .black))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(height: 6)
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * CGFloat(percentage), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(level). \(Int(percentage * 100))% complete")
    }
}

struct HorizontalMetricRow: View {
    let label: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(percentage)%")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray6))
                        .frame(height: 6)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(percentage) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(percentage)%")
    }
}
