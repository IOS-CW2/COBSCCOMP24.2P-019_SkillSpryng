// MARK: - GrowthChart
// Analytics chart component for progress or streak visualization.
import SwiftUI

// MARK: - GrowthChart (Legacy — iOS 15 Bezier Fallback)
//
// ⚠️ SUPERSEDED by Swift Charts in AnalyticsView (see LearningAnalyticsView.swift).
//
// This component was the original growth-trajectory renderer using manual
// UIBezierPath-equivalent SwiftUI Path drawing. It is retained as a reference
// implementation demonstrating raw Bezier curve maths (control-point calculation,
// area fill with gradient) for environments where `import Charts` is unavailable
// (i.e. iOS 15 and earlier).
//
// Current usage: NOT called by any active view — AnalyticsView uses `import Charts`
// with AreaMark / LineMark / PointMark and Catmull-Rom interpolation.
//
// Safe to remove for production. Kept for iOS 15 backward-compatibility reference.

struct GrowthChart: View {
    let points: [GrowthPoint]
    
    var body: some View {
        VStack(spacing: 20) {
            GeometryReader { geo in
                ZStack {
                    // Grid Lines
                    VStack {
                        ForEach(0..<4) { _ in
                            Divider()
                            Spacer()
                        }
                    }
                    
                    // Bezier Path
                    Path { path in
                        let width = geo.size.width
                        let height = geo.size.height
                        let stepWidth = width / CGFloat(points.count - 1)
                        
                        for (index, point) in points.enumerated() {
                            let x = CGFloat(index) * stepWidth
                            let y = height * (1 - CGFloat(point.value) / 100)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                let prevX = CGFloat(index - 1) * stepWidth
                                let prevY = height * (1 - CGFloat(points[index - 1].value) / 100)
                                
                                let control1 = CGPoint(x: prevX + stepWidth / 2, y: prevY)
                                let control2 = CGPoint(x: x - stepWidth / 2, y: y)
                                
                                path.addCurve(to: CGPoint(x: x, y: y), control1: control1, control2: control2)
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "276EF1"), Color(hex: "06C1FF")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Area Fill
                    Path { path in
                        let width = geo.size.width
                        let height = geo.size.height
                        let stepWidth = width / CGFloat(points.count - 1)
                        
                        path.move(to: CGPoint(x: 0, y: height))
                        
                        for (index, point) in points.enumerated() {
                            let x = CGFloat(index) * stepWidth
                            let y = height * (1 - CGFloat(point.value) / 100)
                            
                            if index == 0 {
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                let prevX = CGFloat(index - 1) * stepWidth
                                let prevY = height * (1 - CGFloat(points[index - 1].value) / 100)
                                let control1 = CGPoint(x: prevX + stepWidth / 2, y: prevY)
                                let control2 = CGPoint(x: x - stepWidth / 2, y: y)
                                path.addCurve(to: CGPoint(x: x, y: y), control1: control1, control2: control2)
                            }
                        }
                        
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "276EF1").opacity(0.2), Color(hex: "06C1FF").opacity(0.01)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            
            // Labels
            HStack {
                ForEach(points, id: \.day) { point in
                    Text(point.day)
                        .font(AppTheme.Typography.badge)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
