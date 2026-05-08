import Foundation

// MARK: - MockDataProvider + Sessions
// All Session mock data used in MySessionsView and SessionDetailView.

extension MockDataProvider {

    var mockSessions: [Session] {
        [
            // MARK: Today — Online
            Session(
                title: "Advanced Creative Strategy",
                instructorName: "Sarah Thompson",
                instructorRole: "Lead Instructor",
                instructorId: "sarah-thompson-id",
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

            // MARK: Tomorrow — In-Person
            Session(
                title: "Advanced Creative Strategy",
                instructorName: "Sarah Thompson",
                instructorRole: "Lead Instructor",
                instructorId: "sarah-thompson-id",
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

            // MARK: Completed — with recording & notes
            Session(
                title: "Advanced Brand Identity Systems",
                instructorName: "Marcus Aurelius",
                instructorRole: "Senior Design Lead",
                instructorId: "marcus-aurelius-id",
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
            ),

            // MARK: Completed — short 1-on-1
            Session(
                title: "Systems Thinking 101",
                instructorName: "David Chen",
                instructorRole: "Senior Architect",
                instructorId: "david-chen-id",
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

            // MARK: Cancelled
            Session(
                title: "Creative Strategy Part II",
                instructorName: "Elena Moretti",
                instructorRole: "Strategist",
                instructorId: "elena-moretti-id",
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

            // MARK: Completed — September (history section)
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
}
