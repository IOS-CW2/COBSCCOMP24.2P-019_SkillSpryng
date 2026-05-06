import SwiftUI

struct CoursesView: View {
    @ObservedObject private var vm: LearningViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = "Courses" // Toggled with "Events"
    @State private var selectedCategory = "All"
    let categories = ["All", "Design", "Coding", "Music", "Languages", "Business"]

    init(vm: LearningViewModel = LearningViewModel()) {
        self.vm = vm
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Back Button and Search
            AppHeader(
                title: "Courses",
                backAction: { dismiss() },
                actionIcon: "magnifyingglass",
                action: { /* Search */ }
            )
            
            // Courses/Events Selector
            HStack(spacing: 0) {
                Button(action: { selectedTab = "Courses" }) {
                    Text("Courses")
                        .font(AppTheme.Typography.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == "Courses" ? AppTheme.Colors.primary.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedTab == "Courses" ? AppTheme.Colors.primary : .gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTab == "Courses" ? AppTheme.Colors.primary : Color.clear, lineWidth: 1)
                        )
                }
                .accessibilityAddTraits(selectedTab == "Courses" ? .isSelected : [])
                
                Button(action: { selectedTab = "Events" }) {
                    Text("Events")
                        .font(AppTheme.Typography.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedTab == "Events" ? AppTheme.Colors.primary.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedTab == "Events" ? AppTheme.Colors.primary : .gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTab == "Events" ? AppTheme.Colors.primary : Color.clear, lineWidth: 1)
                        )
                }
                .accessibilityAddTraits(selectedTab == "Events" ? .isSelected : [])
            }
            .padding(4)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom)
            
            if selectedTab == "Courses" {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Category filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { cat in
                                    Button(action: { selectedCategory = cat }) {
                                        Text(cat)
                                            .font(AppTheme.Typography.subheadline)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == cat ? AppTheme.Colors.primary : Color(.systemGray6))
                                            .foregroundColor(selectedCategory == cat ? .white : .gray)
                                            .cornerRadius(20)
                                    }
                                    .accessibilityAddTraits(selectedCategory == cat ? .isSelected : [])
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Featured Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Featured")
                                    .font(AppTheme.Typography.title3)
                                Spacer()
                                Button("See all") { }.font(.caption).foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(vm.featuredCourses) { course in
                                        FeaturedCourseCard(course: course)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Popular This Week
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Popular This Week")
                                    .font(AppTheme.Typography.title3)
                                Spacer()
                                Button("See all") { }.font(.caption).foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(vm.popularCourses) { course in
                                        PopularCourseCard(course: course)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Your Learning Path
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Your Learning Path")
                                    .font(AppTheme.Typography.title3)
                                Spacer()
                                Button("See all") { }.font(.caption).foregroundColor(AppTheme.Colors.primary)
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                ForEach(vm.learningPath) { course in
                                    LearningPathCard(course: course)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                }
            } else {
                EventsView(isNavigatedFromCourses: true)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subcomponents

struct FeaturedCourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemGray6))
                    .frame(width: 300, height: 180)
                
                Text(course.category)
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(4)
                    .padding(16)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(AppTheme.Typography.headline)
                    .lineLimit(2)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                        Text(course.instructor)
                            .font(.caption)
                    }
                    Spacer()
                    Text("★ " + String(format: "%.1f", course.rating))
                        .font(.caption)
                        .bold()
                }
            }
            .frame(width: 300)
            
            HStack {
                Text(course.price)
                    .font(AppTheme.Typography.badge)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.primary.opacity(0.1))
                    .foregroundColor(AppTheme.Colors.primary)
                    .cornerRadius(4)
                
                Spacer()
                
                Text("\(course.studentsCount) STUDENTS")
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.red)
            }
            .frame(width: 300)
        }
        .accessibilityElement(children: .combine)
    }
}

struct PopularCourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(width: 160, height: 100)
                
                Text(course.category)
                    .font(AppTheme.Typography.badge)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppTheme.Colors.primary.opacity(0.8))
                    .cornerRadius(4)
                    .padding(8)
            }
            
            Text(course.title)
                .font(AppTheme.Typography.subheadline)
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)
            
            Text("By \(course.instructor)")
                .font(.caption2)
                .foregroundColor(.gray)
            
            HStack {
                Text("★ " + String(format: "%.1f", course.rating))
                    .font(.caption2)
                Spacer()
                Text(course.price)
                    .font(.caption2)
                    .bold()
                    .foregroundColor(AppTheme.Colors.primary)
            }
            .frame(width: 160)
        }
        .accessibilityElement(children: .combine)
    }
}

struct LearningPathCard: View {
    let course: Course
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(width: 100, height: 80)
                .overlay(
                    VStack {
                        Spacer()
                        if let progress = course.progress {
                            ZStack(alignment: .leading) {
                                Rectangle().fill(Color.white.opacity(0.3)).frame(height: 6)
                                Rectangle().fill(Color.orange).frame(width: 100 * CGFloat(progress), height: 6)
                            }
                            .overlay(
                                Text("\(Int(progress * 100))% DONE")
                                    .font(AppTheme.Typography.badge)
                                    .foregroundColor(.white)
                                    .padding(.bottom, 8)
                            )
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(AppTheme.Typography.subheadline)
                Text(course.instructor)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
