// MARK: - SmartAvatar
// Avatar component that chooses placeholder styling based on user state.
import SwiftUI
import UIKit

// MARK: - SmartAvatar
// A unified avatar component that handles:
//   • Remote URLs (https://...)  → AsyncImage (Firebase Storage / any CDN)
//   • Local file URLs (file://...) → UIImage(contentsOfFile:)
//   • Local asset names          → Image(name) from Assets.xcassets (offline / demo)
//
// Usage:
//   SmartAvatar(imageUrl: instructor.imageUrl, width: 40, height: 40)
//   SmartAvatar(imageUrl: "instructor1", width: 50, height: 50)

struct SmartAvatar: View {
    let imageUrl: String
    var width: CGFloat = 40
    var height: CGFloat = 40
    var strokeColor: Color = AppTheme.Colors.primary
    var strokeWidth: CGFloat = 2.5

    private var trimmedImageUrl: String {
        imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var fileURL: URL? {
        guard let url = URL(string: trimmedImageUrl), url.isFileURL else { return nil }
        return url
    }

    private var fileUIImage: UIImage? {
        guard let fileURL = fileURL else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    var body: some View {
        Group {
            if trimmedImageUrl.isEmpty {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            } else if let uiImage = fileUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if trimmedImageUrl.lowercased().hasPrefix("http"), let url = URL(string: trimmedImageUrl) {
                // Feature 1: Download from Firebase Storage or any Web URL
                AsyncImage(url: url) { phase in
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
                Image(trimmedImageUrl)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: width, height: height)
        .clipShape(Circle())
        .overlay(Circle().stroke(strokeColor, lineWidth: strokeWidth))
        .onAppear {
            if trimmedImageUrl.isEmpty {
                print("[SmartAvatar] ⚠️ Empty imageUrl provided")
            } else if fileURL != nil {
                print("[SmartAvatar] 📄 Loading local file URL: \(trimmedImageUrl)")
            } else if trimmedImageUrl.lowercased().hasPrefix("http") {
                print("[SmartAvatar] 🌐 Loading remote URL: \(trimmedImageUrl)")
            } else {
                print("[SmartAvatar] 📦 Loading asset: \(trimmedImageUrl)")
            }
        }
    }
}
