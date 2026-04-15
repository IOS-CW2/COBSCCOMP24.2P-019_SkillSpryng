import Foundation

// MARK: - MockDataProvider + Learning
// RecommendedSkill, Course, Event, and AnalyticsData mock data
// used in DiscoverView, CoursesView, and EventsView.

extension MockDataProvider {

    // MARK: Recommended Skills (Discover page horizontal scroll)
    var recommendedSkills: [RecommendedSkill] {
        [
        RecommendedSkill(
            title: "Mastering Ceramic Arts",
            instructor: "Elena Kostic",
            price: "$45/hr",
            rating: 4.8,
            imageName: "ceramics_class",
            category: "Arts",
            isTopRated: true,
            instructorImage: "elena_kostic"
        ),
        RecommendedSkill(
            title: "Plant-Based Cooking",
            instructor: "Chef Mario",
            price: "$30/hr",
            rating: 4.9,
            imageName: "vegan_cooking",
            category: "Lifestyle",
            isTopRated: false,
            instructorImage: nil
        ),
        RecommendedSkill(
            title: "Sound Engineering",
            instructor: "Dave Sound",
            price: "$60/hr",
            rating: 4.7,
            imageName: "sound_engineering",
            category: "Music",
            isTopRated: false,
            instructorImage: nil
        )
        ]
    }

    // MARK: Courses
    var featuredCourses: [Course] {
        [
        Course(title: "Mastering 3D Spatial Systems & Glassmorphism", instructor: "Julian Vore",  rating: 4.8, imageName: "course_3d",      category: "DESIGN",  price: "Free",      studentsCount: "2.4k", progress: nil, instructorImage: "julian_profile"),
        Course(title: "Advanced UI Patterns in 2024",                  instructor: "Sarah Chen",   rating: 4.9, imageName: "course_ui",      category: "CODING",  price: "1,200 SKP", studentsCount: "12k",  progress: nil, instructorImage: "sarah_profile")
        ]
    }

    var popularCourses: [Course] {
        [
        Course(title: "Vocal Production Secrets", instructor: "Michael Ross", rating: 4.7, imageName: "course_vocal",    category: "MUSIC",     price: "Free",     studentsCount: "1.2k", progress: nil, instructorImage: "michael_profile"),
        Course(title: "Startup Foundations",       instructor: "Dr. Elena Wu", rating: 4.8, imageName: "course_startup", category: "BUSINESS",  price: "800 SKP",  studentsCount: "5k",   progress: nil, instructorImage: "elena_profile")
        ]
    }

    var learningPath: [Course] {
        [
        Course(title: "Visual Storytelling Masterclass", instructor: "Anna Giraud",  rating: 4.9, imageName: "course_story",  category: "ARTS",      price: "Paid", studentsCount: "3k", progress: 0.65, instructorImage: "anna_profile"),
        Course(title: "French for Explorers",             instructor: "Jean-Pierre",  rating: 4.6, imageName: "course_french", category: "LANGUAGES", price: "Free", studentsCount: "8k", progress: 0.25, instructorImage: "jean_profile")
        ]
    }

    // MARK: Events
    var happeningSoonEvent: Event {
        Event(
            title: "Mastering UI Components",
            instructor: "Sarah Jenkins",
            date: "Oct 28",
            time: "10:00 AM",
            location: "San Francisco",
            imageUrl: "event_ui",
            category: "DESIGN",
            attendanceCount: "124",
            isFree: true,
            spotsLeft: 8
        )
    }

    var upcomingEvents: [Event] {
        [
        Event(title: "Creative Strategy Part II", instructor: "Michael Ross", date: "Oct 28", time: "10:00 AM", location: "San Francisco",   imageUrl: "event_creative", category: "DESIGN", attendanceCount: "45",  isFree: false, spotsLeft: nil),
        Event(title: "Python for Data Viz",        instructor: "Sarah Chen",   date: "Nov 02", time: "2:00 PM",  location: "Online Session",   imageUrl: "event_python",   category: "CODING", attendanceCount: "89",  isFree: true,  spotsLeft: nil),
        Event(title: "Lead Design Sync",           instructor: "Elena Wu",     date: "Nov 05", time: "09:30 AM", location: "Oakland, CA",      imageUrl: "event_sync",     category: "DESIGN", attendanceCount: "12",  isFree: false, spotsLeft: nil)
        ]
    }

    // MARK: Analytics
    var analyticsData: AnalyticsData {
        AnalyticsData(
            streakDays: 7,
            sessionsCount: 24,
            focusHours: 38.5,
            skillsPro: 18,
            karmaPoints: 1240,
            growthHistory: [
                GrowthPoint(day: "MON", value: 40),
                GrowthPoint(day: "TUE", value: 35),
                GrowthPoint(day: "WED", value: 60),
                GrowthPoint(day: "THU", value: 75),
                GrowthPoint(day: "FRI", value: 70),
                GrowthPoint(day: "SAT", value: 85),
                GrowthPoint(day: "SUN", value: 95)
            ],
            skillProgress: [
                SkillProgress(name: "Fullstack Development",  percentage: 85, level: "Level 4 • Pro"),
                SkillProgress(name: "UI/UX Design Strategy",  percentage: 42, level: "Level 2 • Intermediate")
            ]
        )
    }
}
