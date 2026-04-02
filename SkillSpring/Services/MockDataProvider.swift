import Foundation
import SwiftUI

class MockDataProvider {
    static let shared = MockDataProvider()
    
    // MARK: - Elena Rodriguez (Match Detail)
    let elenaProfile = MatchProfile(
        name: "Elena Rodriguez",
        role: "Senior UI/UX Designer & Creative Strategist",
        location: "NYC",
        matchPercentage: 92,
        bio: "Passionate about bridging the gap between high-fidelity design and scalable front-end code. Currently leading design teams at a fintech startup and looking to deepen my technical understanding... Read more",
        canTeach: ["Figma Mastery", "Visual Design"],
        wantsToLearn: ["TypeScript", "React Architecture"],
        imageUrl: "elena_profile", // placeholder
        onlineStatus: true,
        city: "NYC"
    )
    
    // MARK: - Julian & Sarah (Matches Home)
    let matchProfiles = [
        MatchProfile(
            name: "Julian Rivers",
            role: "Piano Enthusiast",
            location: "Brooklyn, NY • 1.2 miles away",
            matchPercentage: 98,
            bio: "Looking for someone to help me brush up on my conversational Italian before my...",
            canTeach: ["Piano", "Jazz Piano"],
            wantsToLearn: ["Italian"],
            imageUrl: "julian_profile",
            onlineStatus: true,
            city: "Brooklyn"
        ),
        MatchProfile(
            name: "Sarah Chen",
            role: "Software Engineer",
            location: "Manhattan, NY • 0.8 miles away",
            matchPercentage: 98,
            bio: "Software engineer by day, aspiring athlete by evening. Let's trade code for courtside...",
            canTeach: ["Python", "Algorithms"],
            wantsToLearn: ["Tennis"],
            imageUrl: "sarah_profile",
            onlineStatus: true,
            city: "Manhattan"
        )
    ]
    
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
}
