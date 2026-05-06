import SwiftUI

struct GenericListView: View {
    let title: String
    
    // We can pass strings or simply show a generic placeholder
    var items: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if items.isEmpty {
                    // Placeholder state
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.3))
                        
                        Text("Coming Soon")
                            .font(AppTheme.Typography.title2)
                        
                        Text("This list will be populated once you have more activity.")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 100)
                } else {
                    ForEach(items, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                            Text(item)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(.primary)
                            Divider()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
