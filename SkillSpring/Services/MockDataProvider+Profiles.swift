import Foundation

// MARK: - MockDataProvider + Profiles
// All MatchProfile mock data.

extension MockDataProvider {

    // MARK: Elena — primary featured match
    var elenaProfile: MatchProfile {
        MatchProfile(
            fullName: "Elena Rodriguez",
            role: "Senior UI/UX Designer & Creative Strategist",
            location: "Colombo, Sri Lanka",
            distance: "0.8 miles away",
            matchPercentage: 92,
            bio: "Passionate about bridging the gap between high-fidelity design and scalable front-end code. Currently leading design teams at a fintech startup and looking to deepen my technical understanding... Read more",
            skillsToTeach: ["Figma Mastery", "Visual Design"],
            skillsToLearn: ["TypeScript", "React Architecture"],
            imageUrl: "instructor2",
            onlineStatus: true,
            city: "NYC",
            sessionsCount: 128,
            rating: 4.9,
            responseTime: "2h",
            availability: ["W", "T"],
            reviews: [
                UserReview(reviewerName: "Marcus T.", rating: 5, comment: "Elena is an incredible mentor. She helped me restructure my portfolio and land my dream role!", reviewerImageUrl: "instructor1"),
                UserReview(reviewerName: "David L.",  rating: 4, comment: "Very clear communication and actionable feedback on my React projects.", reviewerImageUrl: "instructor1")
            ],
            status: .active,
            hourlyRate: 150
        )
    }

    // MARK: All profiles (for discovery & matches)
    var allProfiles: [MatchProfile] {
        [
            elenaProfile,
            MatchProfile(
                fullName: "Julian Rivers",
                role: "Jazz Pianist & Music Producer",
                location: "Kandy, Sri Lanka",
                distance: "1.2 miles away",
                matchPercentage: 98,
                bio: "Looking for someone to help me brush up on my conversational Italian before my European tour next summer.",
                skillsToTeach: ["Jazz Piano"],
                skillsToLearn: ["Italian"],
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
                location: "Galle, Sri Lanka",
                distance: "0.8 miles away",
                matchPercentage: 91,
                bio: "Software engineer by day, aspiring athlete by evening. Let's trade code for courtside tips!",
                skillsToTeach: ["Python"],
                skillsToLearn: ["Tennis"],
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
                skillsToTeach: ["UI/UX", "Motion"],
                skillsToLearn: ["SwiftUI"],
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
                skillsToTeach: ["Marketing"],
                skillsToLearn: ["Data Analysis"],
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
                skillsToTeach: ["React", "Node"],
                skillsToLearn: ["GraphQL"],
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

    /// Profiles that are in `.suggested` state (shown in the matches carousel).
    var matchProfiles: [MatchProfile] {
        allProfiles.filter { $0.status == .suggested }
    }
}
