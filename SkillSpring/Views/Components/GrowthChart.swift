import SwiftUI

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
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
