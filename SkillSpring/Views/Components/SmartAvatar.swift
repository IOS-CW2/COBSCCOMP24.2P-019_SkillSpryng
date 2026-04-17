import SwiftUI

// MARK: - SmartAvatar
// A unified avatar component that handles:
//   • Remote URLs (https://...)  → AsyncImage (Firebase Storage / any CDN)
//   • Local asset names          → Image(name) from Assets.xcassets (offline / demo)
//
// Usage:
//   SmartAvatar(imageUrl: instructor.imageUrl, width: 40, height: 40)
//   SmartAvatar(imageUrl: "instructor1", width: 50, height: 50)

struct SmartAvatar: View {
    let imageUrl: String
    var width: CGFloat = 40
    var height: CGFloat = 40

    var body: some View {
        Group {
            if imageUrl.lowercased().hasPrefix("http") {
                // Feature 1: Download from Firebase Storage or any Web URL
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Feature 2: Load instantly from Xcode Assets (Offline support)
                Image(imageUrl)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: width, height: height)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}
