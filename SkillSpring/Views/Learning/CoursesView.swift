import SwiftUI

/// Displays the courses and events discovery experience within the learning tab.
///
/// Users can switch between a course catalog and live event listings while
/// browsing featured classes, popular recommendations, and their personal learning path.
struct CoursesView: View {
    @ObservedObject private var vm: LearningViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = "Courses" // Toggled with "Events"
    @State private var selectedCategory = "All"
    @State private var selectedCourse: Course? = nil
    let categories = ["All", "Design", "Coding", "Music", "Languages", "Business"]

    @MainActor
    init() {
        _vm = ObservedObject(initialValue: .init())
    }

    @MainActor
    init(vm: LearningViewModel) {
        _vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Back Button and Search
            // This top bar is the fixed entry point for the learning section.
            AppHeader(
                title: selectedTab,
                backAction: { dismiss() },
                actionIcon: "magnifyingglass",
                action: { /* Search */ }
            )
            
            // Courses/Events Selector
            // Toggles between the course catalog and the events listing.
            HStack(spacing: 0) {
                Button(action: { selectedTab = "Courses" }) {
                    Text("Courses")
                        .font(AppTheme.Typography.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == "Courses" ? AppTheme.Colors.primary.opacity(0.18) : Color.clear)
                        .foregroundColor(selectedTab == "Courses" ? AppTheme.Colors.primary : .gray)
                        .clipShape(Capsule())
                }
                .accessibilityAddTraits(selectedTab == "Courses" ? .isSelected : [])
                
                Button(action: { selectedTab = "Events" }) {
                    Text("Events")
                        .font(AppTheme.Typography.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == "Events" ? AppTheme.Colors.primary.opacity(0.18) : Color.clear)
                        .foregroundColor(selectedTab == "Events" ? AppTheme.Colors.primary : .gray)
                        .clipShape(Capsule())
                }
                .accessibilityAddTraits(selectedTab == "Events" ? .isSelected : [])
            }
            .padding(6)
            .background(Color(.systemGray6))
            .cornerRadius(24)
            .padding(.horizontal)
            .padding(.bottom)
            
            if selectedTab == "Courses" {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Category filters
                        // These chips let the user narrow the course catalog by topic.
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
                        // Highlights the most important courses for the user.
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
                                        Button(action: { selectedCourse = course }) {
                                            FeaturedCourseCard(course: course)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .accessibilityHint("Tap to view details for \(course.title).")
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Popular This Week
                        // Surfaced courses that are trending with the community.
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
                                        Button(action: { selectedCourse = course }) {
                                            PopularCourseCard(course: course)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .accessibilityHint("Tap to view details for \(course.title).")
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Your Learning Path
                        // Displays courses the user is already following.
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
                                    Button(action: { selectedCourse = course }) {
                                        LearningPathCard(course: course)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .accessibilityHint("Tap to view details for \(course.title).")
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
        .sheet(item: $selectedCourse) { course in
            CourseDetailSheet(course: course)
        }
    }
}

// MARK: - Course Detail Sheet

struct CourseDetailSheet: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Image(course.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.12), radius: 15, x: 0, y: 10)

                    VStack(alignment: .leading, spacing: 14) {
                        Text(course.title)
                            .font(AppTheme.Typography.largeTitle)
                            .lineLimit(3)
                        Text("By \(course.instructor)")
                            .font(AppTheme.Typography.title3)
                            .foregroundColor(.gray)

                        HStack(spacing: 12) {
                            Label("★ \(String(format: "%.1f", course.rating))", systemImage: "star.fill")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(.orange)
                            Text(course.price)
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.primary)
                        }

                        Text("Category: \(course.category)")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)

                        Text("Tap below to request a session with this instructor and receive a confirmation notification.")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)

                    VStack(spacing: 14) {
                        Button(action: {
                            NotificationManager.shared.scheduleBookingRequestSent(instructorName: course.instructor)
                            dismiss()
                        }) {
                            Text("Request Session")
                                .font(AppTheme.Typography.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.Colors.primary)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }

                        Button(action: { dismiss() }) {
                            Text("Close")
                                .font(AppTheme.Typography.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 32)
            }
            .navigationTitle("Course Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Subcomponents

/// A large cardio-style card used for featured courses.
/// Includes category badge, instructor details, rating, and pricing.
struct FeaturedCourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                Image(course.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 180)
                    .clipped()
                    .cornerRadius(20)
                
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

/// A compact card representing a popular course choice for the week.
/// Shows the course title, instructor, rating, and cost.
struct PopularCourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                Image(course.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 100)
                    .clipped()
                    .cornerRadius(16)
                
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

/// Displays a course already in the user's personalized learning path.
/// Includes a progress indicator and quick access action.
struct LearningPathCard: View {
    let course: Course
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                Image(course.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 80)
                    .clipped()
                    .cornerRadius(12)
                
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
                    .padding(4)
                }
            }
            
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
