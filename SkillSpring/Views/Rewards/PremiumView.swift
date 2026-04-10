import SwiftUI

struct PremiumView: View {
    @State private var billingCycle = "Monthly"
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("Go Premium")
                        .font(.headline)
                    Spacer()
                    EmptyView().frame(width: 34)
                }
                .padding(.horizontal)
                
                // Elevation Hero Card
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "27E246"), Color(hex: "1D9E75")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: "crown.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Elevate Your Growth")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            Text("Unlock exclusive courses, direct mentorship, and advanced career analytics.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(40)
                }
                .frame(height: 280)
                .padding(.horizontal)
                
                // Toggle Switcher
                HStack(spacing: 0) {
                    ForEach(["Monthly", "Yearly"], id: \.self) { cycle in
                        Button(action: { billingCycle = cycle }) {
                            Text(cycle)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(billingCycle == cycle ? .primary : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(billingCycle == cycle ? Color.white : Color.clear)
                                .cornerRadius(10)
                                .padding(4)
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 60)
                
                // Plans Stack
                VStack(spacing: 24) {
                    // Free Plan
                    PlanHeaderView(title: "STANDARD", price: "Free", isRecommended: false)
                        .overlay(
                            VStack(alignment: .leading, spacing: 12) {
                                BulletRow(text: "Basic Course Access")
                                BulletRow(text: "Community Forums")
                                BulletRow(text: "1-on-1 Mentorship")
                                BulletRow(text: "Advanced Career Labs")
                                
                                Button(action: { }) {
                                    Text("Current Plan")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(AppTheme.Colors.primary)
                                        .cornerRadius(12)
                                }
                                .padding(.top, 10)
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                            .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 5)
                            .offset(y: 140)
                        )
                        .padding(.bottom, 220) // Spacer for the overlay
                    
                    // Recommended Plan
                    PlanHeaderView(title: "RECOMMENDED", price: "Rs.2000 /mo", isRecommended: true)
                        .overlay(
                            VStack(alignment: .leading, spacing: 12) {
                                BulletRow(text: "Unlimited Course Access", isPro: true)
                                BulletRow(text: "Priority Mentorship Chats", isPro: true)
                                BulletRow(text: "Skill Assessment Badges", isPro: true)
                                BulletRow(text: "Exclusive Networking Events", isPro: true)
                                
                                Button(action: { }) {
                                    Text("Go Premium")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.Colors.primary, lineWidth: 1))
                                }
                                .padding(.top, 10)
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(24, corners: [.bottomLeft, .bottomRight])
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 10)
                            .offset(y: 140)
                        )
                        .padding(.bottom, 220)
                }
                .padding(.horizontal)
                
                // Why Pro features
                VStack(alignment: .leading, spacing: 24) {
                    Text("WHY SKILLSPRYNG PRO?")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        BenefitCard(icon: "sparkles", title: "AI Career Paths", subtitle: "Personalized learning routes driven by market trends.", color: .purple)
                        BenefitCard(icon: "person.2.fill", title: "Elite Network", subtitle: "Direct access to industry-top mentors.", color: .orange)
                        BenefitCard(icon: "doc.text.fill", title: "Certificates", subtitle: "Industry-recognized credentials.", color: .blue)
                        BenefitCard(icon: "bolt.fill", title: "Fast-Track Content", subtitle: "Condensed modules for busy professionals.", color: .green)
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    Text("Cancel anytime. No hidden commitments.")
                    Text("14-day money-back guarantee.")
                }
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.vertical, 20)
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct PlanHeaderView: View {
    let title: String
    let price: String
    let isRecommended: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .black))
                .foregroundColor(isRecommended ? .white : .gray)
            
            Text(price)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isRecommended ? .white : .primary)
            
            if isRecommended {
                Text("BEST VALUE")
                    .font(.system(size: 8, weight: .black))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(isRecommended ? Color(hex: "1D9E75") : Color.white)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

struct BulletRow: View {
    let text: String
    var isPro: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(isPro ? AppTheme.Colors.primary : .green)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
        }
    }
}
