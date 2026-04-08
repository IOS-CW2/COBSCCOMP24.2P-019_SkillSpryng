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
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("Go Premium")
                        .font(.headline)
                    Spacer()
                    EmptyView().frame(width: 34)
                }
                .padding(.horizontal)
                
                // Hero Card
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
                        Image(systemName: "crown.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            Text("Elevate Your Growth")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("Unlock exclusive courses, direct mentorship, and advanced career analytics.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(40)
                }
                .frame(height: 240)
                .padding(.horizontal)
                
                // Toggle
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
                                .shadow(color: billingCycle == cycle ? Color.black.opacity(0.1) : .clear, radius: 5)
                        }
                    }
                }
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                
                // Plans
                VStack(spacing: 24) {
                    PlanCard(
                        title: "STANDARD",
                        price: "Free",
                        features: ["Basic Course Access", "Community Forums", "1-on-1 Mentorship", "Advanced Career Labs"],
                        isRecommended: false
                    )
                    
                    PlanCard(
                        title: "RECOMMENDED",
                        price: "Rs.2000 /mo",
                        features: ["Unlimited Course Access", "Priority Mentorship Chats", "Skill Assessment Badges", "Exclusive Networking Events"],
                        isRecommended: true
                    )
                }
                .padding(.horizontal)
                
                // Why Pro? section
                VStack(alignment: .leading, spacing: 24) {
                    Text("WHY SKILLSPRYNG PRO?")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primary)
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            BenefitCard(icon: "sparkles", title: "AI Career Paths", subtitle: "Personalized learning routes driven by market trends.")
                                .frame(maxWidth: .infinity)
                            BenefitCard(icon: "person.2.fill", title: "Elite Network", subtitle: "Direct access to industry-top mentors.", color: .orange)
                                .frame(maxWidth: .infinity)
                        }
                        
                        HStack(spacing: 16) {
                            BenefitCard(icon: "doc.text.fill", title: "Certificates", subtitle: "Industry-recognized credentials for every course.", color: .brown)
                                .frame(maxWidth: .infinity)
                            BenefitCard(icon: "bolt.fill", title: "Fast-Track Content", subtitle: "Condensed modules for busy professionals.", color: .blue)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    Text("Cancel anytime. No hidden commitments.")
                    Text("14-day money-back guarantee.")
                }
                .font(.system(size: 10))
                .foregroundColor(.gray)
                
                Spacer().frame(height: 40)
            }
            .padding(.top)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct BenefitCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var color: Color = .green
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
        }
        .padding()
        .frame(height: 140, alignment: .topLeading)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(20)
    }
}
