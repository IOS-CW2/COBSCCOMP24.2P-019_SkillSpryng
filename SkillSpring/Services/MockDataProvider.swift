import Foundation
import SwiftUI

class MockDataProvider {
    static let shared = MockDataProvider()
    
    var currentUser = User(
        fullName: "Alex Rivera",
        phoneNumber: "+1 234 567 890",
        skillsToTeach: ["UI Design", "Brand Strategy", "React Native"],
        skillsToLearn: ["Surfing", "Pottery", "Public Speaking"],
        experienceLevel: "Expert",
        location: "San Francisco, CA",
        bio: "Adrian is an incredible mentor. He doesn't just teach craft, he teaches the mindset of a successful lead designer.",
        profileImageURL: "instructor2",
        role: "Pro Instructor",
        level: 4,
        karmaPoints: 4850,
        sessionsCount: 128,
        rating: 4.9,
        awardsCount: 12,
        walletBalance: 200,
        isPro: false, // Changed to false to show the subscription UI better
        isChildMode: false,
        profileCompleteness: 85,
        skillStats: [
            "Creative Design": SkillMetrics(credibilityScore: 85, studentsTaught: 12, rating: 4.9, level: "EXPERT"),
            "UI Engineering": SkillMetrics(credibilityScore: 62, studentsTaught: 24, rating: 5.0, level: "PRO")
        ]
    )
    
    // MARK: - Match Profiles
    lazy var elenaProfile = MatchProfile(
        fullName: "Elena Rodriguez",
        role: "Senior UI/UX Designer & Creative Strategist",
        location: "Manhattan, NY",
        distance: "0.8 miles away",
        matchPercentage: 92,
        bio: "Passionate about bridging the gap between high-fidelity design and scalable front-end code. Currently leading design teams at a fintech startup and looking to deepen my technical understanding... Read more",
        canTeach: ["Figma Mastery", "Visual Design"],
        wantsToLearn: ["TypeScript", "React Architecture"],
        imageUrl: "instructor2",
        onlineStatus: true,
        city: "NYC",
        sessionsCount: 128,
        rating: 4.9,
        responseTime: "2h",
        availability: ["W", "T"],
        reviews: [
            UserReview(reviewerName: "Marcus T.", rating: 5, comment: "Elena is an incredible mentor. She helped me restructure my portfolio and land my dream role!", reviewerImageUrl: "instructor1"),
            UserReview(reviewerName: "David L.", rating: 4, comment: "Very clear communication and actionable feedback on my React projects.", reviewerImageUrl: "instructor1")
        ],
        status: .active,
        hourlyRate: 150
    )
    
    var allProfiles: [MatchProfile] {
        return [
            elenaProfile,
            MatchProfile(
                fullName: "Julian Rivers",
                role: "Jazz Pianist & Music Producer",
                location: "Brooklyn, NY",
                distance: "1.2 miles away",
                matchPercentage: 98,
                bio: "Looking for someone to help me brush up on my conversational Italian before my European tour next summer.",
                canTeach: ["Jazz Piano"],
                wantsToLearn: ["Italian"],
                imageUrl: "instructor1",
                onlineStatus: true,
                city: "Brooklyn",
                sessionsCount: 45,
                rating: 5.0,
                responseTime: "1h",
                availability: ["M", "F"],
                reviews: [],
                status: .suggested
            ),
            MatchProfile(
                fullName: "Sarah Chen",
                role: "Software Engineer & Athlete",
                location: "Manhattan, NY",
                distance: "0.8 miles away",
                matchPercentage: 91,
                bio: "Software engineer by day, aspiring athlete by evening. Let's trade code for courtside tips!",
                canTeach: ["Python"],
                wantsToLearn: ["Tennis"],
                imageUrl: "instructor2",
                onlineStatus: false,
                city: "NYC",
                sessionsCount: 82,
                rating: 4.8,
                responseTime: "4h",
                availability: ["S", "S"],
                reviews: [],
                status: .suggested
            ),
            MatchProfile(
                fullName: "Marcus Chen",
                role: "Senior Product Designer",
                location: "Online",
                distance: "N/A",
                matchPercentage: 88,
                bio: "I'd love to help you bridge the gap between UI/UX and motion design.",
                canTeach: ["UI/UX", "Motion"],
                wantsToLearn: ["SwiftUI"],
                imageUrl: "instructor1",
                onlineStatus: true,
                city: "Online",
                sessionsCount: 156,
                rating: 4.9,
                responseTime: "30m",
                availability: ["T", "W", "T"],
                reviews: [],
                status: .requestIncoming
            ),
            MatchProfile(
                fullName: "Sarah Jenkins",
                role: "Growth Marketing Lead",
                location: "Online",
                distance: "N/A",
                matchPercentage: 85,
                bio: "Request sent - Waiting for response",
                canTeach: ["Marketing"],
                wantsToLearn: ["Data Analysis"],
                imageUrl: "instructor2",
                onlineStatus: false,
                city: "Online",
                sessionsCount: 40,
                rating: 4.7,
                responseTime: "1d",
                availability: ["F"],
                reviews: [],
                status: .requestSent
            ),
            MatchProfile(
                fullName: "David Miller",
                role: "Fullstack Engineer",
                location: "Online",
                distance: "N/A",
                matchPercentage: 94,
                bio: "Saw your post about the new React server components. I've been experimenting with those too!",
                canTeach: ["React", "Node"],
                wantsToLearn: ["GraphQL"],
                imageUrl: "instructor1",
                onlineStatus: true,
                city: "Online",
                sessionsCount: 200,
                rating: 5.0,
                responseTime: "15m",
                availability: ["M", "W", "F"],
                reviews: [],
                status: .active
            )
        ]
    }
    
    var matchProfiles: [MatchProfile] {
        return allProfiles.filter { $0.status == .suggested }
    }
    
    // MARK: - Recommended Skills (Discover Page)
    let recommendedSkills = [
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
    
    // MARK: - Courses
    let featuredCourses = [
        Course(title: "Mastering 3D Spatial Systems & Glassmorphism", instructor: "Julian Vore", rating: 4.8, imageName: "course_3d", category: "DESIGN", price: "Free", studentsCount: "2.4k", progress: nil, instructorImage: "julian_profile"),
        Course(title: "Advanced UI Patterns in 2024", instructor: "Sarah Chen", rating: 4.9, imageName: "course_ui", category: "CODING", price: "1,200 SKP", studentsCount: "12k", progress: nil, instructorImage: "sarah_profile")
    ]
    
    let popularCourses = [
        Course(title: "Vocal Production Secrets", instructor: "Michael Ross", rating: 4.7, imageName: "course_vocal", category: "MUSIC", price: "Free", studentsCount: "1.2k", progress: nil, instructorImage: "michael_profile"),
        Course(title: "Startup Foundations", instructor: "Dr. Elena Wu", rating: 4.8, imageName: "course_startup", category: "BUSINESS", price: "800 SKP", studentsCount: "5k", progress: nil, instructorImage: "elena_profile")
    ]
    
    let learningPath = [
        Course(title: "Visual Storytelling Masterclass", instructor: "Anna Giraud", rating: 4.9, imageName: "course_story", category: "ARTS", price: "Paid", studentsCount: "3k", progress: 0.65, instructorImage: "anna_profile"),
        Course(title: "French for Explorers", instructor: "Jean-Pierre", rating: 4.6, imageName: "course_french", category: "LANGUAGES", price: "Free", studentsCount: "8k", progress: 0.25, instructorImage: "jean_profile")
    ]
    
    // MARK: - Events
    let happeningSoonEvent = Event(
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
    
    let upcomingEvents = [
        Event(title: "Creative Strategy Part II", instructor: "Michael Ross", date: "Oct 28", time: "10:00 AM", location: "San Francisco", imageUrl: "event_creative", category: "DESIGN", attendanceCount: "45", isFree: false, spotsLeft: nil),
        Event(title: "Python for Data Viz", instructor: "Sarah Chen", date: "Nov 02", time: "2:00 PM", location: "Online Session", imageUrl: "event_python", category: "CODING", attendanceCount: "89", isFree: true, spotsLeft: nil),
        Event(title: "Lead Design Sync", instructor: "Elena Wu", date: "Nov 05", time: "09:30 AM", location: "Oakland, CA", imageUrl: "event_sync", category: "DESIGN", attendanceCount: "12", isFree: false, spotsLeft: nil)
    ]
    
    // MARK: - Analytics Data
    let analyticsData = AnalyticsData(
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
            SkillProgress(name: "Fullstack Development", percentage: 85, level: "Level 4 • Pro"),
            SkillProgress(name: "UI/UX Design Strategy", percentage: 42, level: "Level 2 • Intermediate")
        ]
    )
    
    // MARK: - Messaging Data
    
    var mockConversations: [Conversation] {
        let marcus = User(id: "marcus", fullName: "Marcus Chen", phoneNumber: "123456789", skillsToTeach: ["Python", "Algorithms"], bio: "Senior Dev", profileImageURL: "instructor1")
        let aria = User(id: "aria", fullName: "Aria Sterling", phoneNumber: "987654321", skillsToTeach: ["Creative Writing"], bio: "Author", profileImageURL: "instructor2")
        let sim = User(id: "sim", fullName: "Sim V", phoneNumber: "555555555", skillsToTeach: ["UI/UX Design"], bio: "Product Designer", profileImageURL: "instructor1")
        
        return [
            Conversation(
                participant: marcus,
                lastMessage: "Try refactoring this section using a lambda function. It'll make it much cleaner.",
                lastMessageTime: "10:48 AM",
                unreadCount: 0,
                messages: [
                    ChatMessage(text: "Hey! I just reviewed your progress on the advanced Python module. Your logic in the recursion exercise was impressive. 🚀", timestamp: Date().addingTimeInterval(-3600), isFromMe: false, type: .text, imageName: nil, fileName: nil, fileSize: nil),
                    ChatMessage(text: "Thanks Marcus! It took a few tries to get the base case right, but it finally clicked.", timestamp: Date().addingTimeInterval(-3400), isFromMe: true, type: .text, imageName: nil, fileName: nil, fileSize: nil),
                    ChatMessage(text: nil, timestamp: Date().addingTimeInterval(-3200), isFromMe: false, type: .image, imageName: "course_python", fileName: nil, fileSize: nil),
                    ChatMessage(text: "Try refactoring this section using a lambda function. It'll make it much cleaner.", timestamp: Date().addingTimeInterval(-3000), isFromMe: false, type: .text, imageName: nil, fileName: nil, fileSize: nil),
                    ChatMessage(text: nil, timestamp: Date().addingTimeInterval(-2800), isFromMe: true, type: .attachment, imageName: nil, fileName: "Refactored_Logic.pdf", fileSize: "1.2 MB • PDF")
                ]
            ),
            Conversation(
                participant: aria,
                lastMessage: "Thanks for the resources you shared yesterday!",
                lastMessageTime: "YESTERDAY",
                unreadCount: 0,
                messages: []
            ),
            Conversation(
                participant: sim,
                lastMessage: "The session on UI/UX was really helpful.",
                lastMessageTime: "2MIN AGO",
                unreadCount: 1,
                messages: []
            )
        ]
    }
    
    var mockSessions: [Session] {
        return [
            Session(
                title: "Advanced Creative Strategy",
                instructorName: "Sarah Thompson",
                instructorRole: "Lead Instructor",
                date: "Oct 24",
                time: "2:00 PM",
                duration: "90 min",
                location: nil,
                distance: nil,
                timeRemaining: "In 2 hours",
                status: .upcoming,
                type: .online,
                category: "Creative Strategy",
                rating: nil,
                matchPercentage: 98
            ),
            Session(
                title: "Advanced Creative Strategy",
                instructorName: "Sarah Thompson",
                instructorRole: "Lead Instructor",
                date: "Oct 25",
                time: "2:30 PM",
                duration: "90 min",
                location: "Salesforce Transit Center",
                distance: "0.3 mi",
                timeRemaining: "In 19 hours",
                status: .upcoming,
                type: .inPerson,
                category: "Creative Strategy",
                rating: nil
            ),
            Session(
                title: "Advanced Brand Identity Systems",
                instructorName: "Marcus Aurelius",
                instructorRole: "Senior Design Lead",
                date: "Oct 24",
                time: "14:00 - 15:30",
                duration: "90 min",
                location: nil,
                distance: nil,
                timeRemaining: nil,
                status: .completed,
                type: .online,
                category: "Brand Systems",
                rating: 5,
                notes: "Focus was placed on developing a scalable design system for enterprise-level applications. Discussed the implementation of atomic design principles and color accessibility.",
                creditsEarned: 450,
                recordingAvailable: true,
                recordingDuration: "1h 35m",
                lessonCount: 8
            )
,
            Session(
                title: "Systems Thinking 101",
                instructorName: "David Chen",
                instructorRole: "Senior Architect",
                date: "Oct 18",
                time: "02:30 PM",
                duration: "45 min",
                location: nil,
                distance: nil,
                timeRemaining: nil,
                status: .completed,
                type: .online,
                category: "1-on-1 Mentorship",
                rating: 5
            ),
            Session(
                title: "Creative Strategy Part II",
                instructorName: "Elena Moretti",
                instructorRole: "Strategist",
                date: "Oct 12",
                time: "09:00 AM",
                duration: "60 min",
                location: nil,
                distance: nil,
                timeRemaining: nil,
                status: .cancelled,
                type: .online,
                category: "Digital Workshop",
                rating: nil
            ),
            Session(
                title: "JavaScript Performance",
                instructorName: "James Smith",
                instructorRole: "Dev Rel",
                date: "Sep 28",
                time: "04:00 PM",
                duration: "120 min",
                location: nil,
                distance: nil,
                timeRemaining: nil,
                status: .completed,
                type: .online,
                category: "Group Webinar",
                rating: 5
            )
        ]
    }
    
    // MARK: - Rewards & Wallet Data
    
    let masteryData = MasteryPoints(total: 12450, level: 14, progressTowardsNextLevel: 0.85)
    
    let leaderboardWeekly = [
        LeaderboardEntry(fullName: "Marcus T.", points: 2840, rank: 1, avatarUrl: "instructor1"),
        LeaderboardEntry(fullName: "Sarah Jenkins", points: 3120, rank: 2, avatarUrl: "instructor2", weeklyChange: 2),
        LeaderboardEntry(fullName: "Liam W.", points: 2710, rank: 3, avatarUrl: "instructor1")
    ]
    
    let leaderboardAllTimeCurrent = LeaderboardEntry(fullName: "You (Alex)", points: 1450, rank: 24, avatarUrl: "instructor2", isCurrentUser: true, weeklyChange: 3)
    
    let topCurators = [
        LeaderboardEntry(fullName: "Elena Vance", points: 14200, rank: 1, avatarUrl: "instructor2"),
        LeaderboardEntry(fullName: "Marcus Thorne", points: 12800, rank: 2, avatarUrl: "instructor1"),
        LeaderboardEntry(fullName: "Sana Kim", points: 11900, rank: 3, avatarUrl: "instructor2")
    ]
    
    let rewardBadges = [
        RewardBadge(title: "First Bloom", iconName: "leaf.fill", colorHex: "2DBF8E"),
        RewardBadge(title: "Steady Growth", iconName: "bolt.fill", colorHex: "1D9E75"),
        RewardBadge(title: "Master Mind", iconName: "star.fill", colorHex: "FFD700"),
        RewardBadge(title: "Night Owl", iconName: "moon.fill", colorHex: "5D5FEF")
    ]
    
    let milestones = [
        Milestone(title: "Publish 10 Case Studies", progress: 7, total: 10, iconName: "doc.text.fill"),
        Milestone(title: "Help 50 Newbies", progress: 22, total: 50, iconName: "person.2.fill")
    ]
    
    let creditPacks = [
        CreditPack(amount: 2500, bonusAmount: 500, price: "$49.99", isBestValue: true),
        CreditPack(amount: 1000, price: "$24.99")
    ]
    
    let skillMissions = [
        SkillMission(title: "Complete UI Basics", rewardAmount: 150, status: .inProgress),
        SkillMission(title: "Peer Review Workshop", rewardAmount: 300, status: .available)
    ]
}
