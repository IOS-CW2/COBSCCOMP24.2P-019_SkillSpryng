import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

// MARK: - FirebaseStorageService
// Uploads and manages files in Firebase Cloud Storage using the
// Firebase Storage REST API over URLSession.
//
// Why REST instead of the FirebaseStorage SDK?
//   The Firebase Storage CocoaPod/SPM target was not added to this project.
//   The REST API provides identical functionality and additionally allows:
//     • Fine-grained URLRequest control (custom headers, timeout, retry)
//     • Observable upload progress via URLSessionUploadTask
//     • No SDK binary size overhead
//
// REST endpoint:
//   POST https://firebasestorage.googleapis.com/v0/b/{bucket}/o
//        ?uploadType=media&name={path}
//   Authorization: Bearer <Firebase ID token>
//
// SIMULATOR TESTING:
//   1. Sign in so Auth.auth().currentUser is non-nil
//   2. Tap "Change Profile Photo" → "Take Photo" or "Choose from Library"
//   3. Observe upload progress in EditProfileView
//   4. Check Firebase Console → Storage → profile_images/{uid}.jpg
//   5. The returned download URL is stored in Firestore under users/{uid}.profileImageURL

@MainActor
final class FirebaseStorageService {

    static let shared = FirebaseStorageService()
    private init() {}

    // MARK: - Configuration

    /// Firebase Storage bucket name, read from GoogleService-Info.plist.
    private lazy var storageBucket: String = {
        guard
            let path   = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dict   = NSDictionary(contentsOfFile: path),
            let bucket = dict["STORAGE_BUCKET"] as? String,
            !bucket.isEmpty
        else {
            // Fallback — replace with your actual bucket if plist is missing
            print("[FirebaseStorage] ⚠️ STORAGE_BUCKET not found in plist — using fallback")
            return "skillspryng-default.appspot.com"
        }
        return bucket
    }()

    private var baseURL: String { "https://firebasestorage.googleapis.com/v0/b/\(storageBucket)/o" }

    // MARK: - FUNCTION 1: uploadProfileImage
    /// Compresses the image to JPEG and uploads it to Firebase Storage via REST.
    /// On success, persists the download URL to Firestore.
    /// If authentication fails, falls back to local image storage.
    ///
    /// - Parameter image: UIImage from AVFoundation camera or photo library.
    /// - Returns: HTTPS download URL string OR local file URL for use in Firestore + AsyncImage.
    /// - Throws: `StorageError.invalidImageData`
    func uploadProfileImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImageData
        }

        // Try Firebase upload first
        if let uid = Auth.auth().currentUser?.uid {
            do {
                return try await uploadToFirebase(imageData: imageData, uid: uid)
            } catch {
                print("[FirebaseStorage] ⚠️ Firebase upload failed, falling back to local storage: \(error)")
                // Fall through to local storage
            }
        } else {
            print("[FirebaseStorage] ⚠️ User not authenticated, using local image storage")
        }

        // Fallback: Save image locally
        return try saveImageLocally(imageData: imageData)
    }

    // MARK: - FUNCTION 1B: uploadToFirebase (Helper)
    private func uploadToFirebase(imageData: Data, uid: String) async throws -> String {
        let token        = try await getIDToken()
        let objectName   = "profile_images/\(uid).jpg"
        let encodedName  = objectName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? objectName

        guard let url = URL(string: "\(baseURL)?uploadType=media&name=\(encodedName)") else {
            throw StorageError.invalidResponse
        }

        var request          = URLRequest(url: url, timeoutInterval: 60)
        request.httpMethod   = "POST"
        request.setValue("Bearer \(token)",  forHTTPHeaderField: "Authorization")
        request.setValue("image/jpeg",       forHTTPHeaderField: "Content-Type")
        request.setValue("\(imageData.count)", forHTTPHeaderField: "Content-Length")

        print("[FirebaseStorage] ⬆️ Uploading \(imageData.count / 1024) KB → \(objectName)")

        let (data, response) = try await URLSession.shared.upload(for: request, from: imageData)

        guard let http = response as? HTTPURLResponse else {
            throw StorageError.uploadFailed(statusCode: 0)
        }
        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "(no body)"
            print("[FirebaseStorage] ❌ Upload HTTP \(http.statusCode): \(body)")
            throw StorageError.uploadFailed(statusCode: http.statusCode)
        }

        // Parse the upload response — contains `downloadTokens`
        guard
            let json           = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let downloadTokens = json["downloadTokens"] as? String
        else {
            throw StorageError.invalidResponse
        }

        // Build a public download URL usable in AsyncImage and Firestore
        let encodedPath  = objectName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? objectName
        let downloadURL  = "\(baseURL)/\(encodedPath)?alt=media&token=\(downloadTokens)"

        print("[FirebaseStorage] ✅ Upload complete → \(downloadURL.prefix(80))…")

        // Persist the URL back to the Firestore user document.
        // Let failures propagate so callers can handle persistence errors explicitly.
        try await FirebaseDataService.shared.db
            .collection("users").document(uid)
            .updateData(["profileImageURL": downloadURL])

        return downloadURL
    }

    // MARK: - FUNCTION 1C: saveImageLocally (Fallback)
    /// Saves image data locally when Firebase authentication is unavailable.
    /// Returns a local file URL for temporary local storage.
    private func saveImageLocally(imageData: Data) throws -> String {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw StorageError.invalidResponse
        }

        let imageDirectory = documentsDirectory.appendingPathComponent("profile_images", isDirectory: true)
        try fileManager.createDirectory(at: imageDirectory, withIntermediateDirectories: true)

        let fileName = "profile_\(UUID().uuidString).jpg"
        let fileURL = imageDirectory.appendingPathComponent(fileName)

        try imageData.write(to: fileURL)
        print("[FirebaseStorage] 💾 Image saved locally → \(fileURL.lastPathComponent)")

        // Return file URL as string (will be converted to data URL when needed)
        return fileURL.absoluteString
    }

    // MARK: - FUNCTION 2: fetchProfileImageURL
    /// Returns the current profile image download URL from Firestore.
    func fetchProfileImageURL() async -> String? {
        await FirebaseDataService.shared.fetchCurrentUser()?.profileImageURL
    }

    // MARK: - FUNCTION 3: deleteProfileImage
    /// Deletes the current user's profile image from Firebase Storage via REST.
    func deleteProfileImage() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw StorageError.notAuthenticated
        }

        let token       = try await getIDToken()
        let objectName  = "profile_images%2F\(uid).jpg"  // path-encoded

        guard let url = URL(string: "\(baseURL)/\(objectName)") else { return }

        var request        = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0

        if status == 204 || status == 200 {
            print("[FirebaseStorage] 🗑️ Deleted profile_images/\(uid).jpg")
        } else {
            print("[FirebaseStorage] ⚠️ Delete returned HTTP \(status)")
        }
    }

    // MARK: - FUNCTION 4: uploadSessionRecording
    /// Uploads a recorded session video to Firebase Storage via REST.
    /// - Returns: Download URL string for the recording.
    func uploadSessionRecording(sessionId: String, data: Data) async throws -> String {
        guard Auth.auth().currentUser?.uid != nil else {
            throw StorageError.notAuthenticated
        }

        let token       = try await getIDToken()
        let objectName  = "session_recordings/\(sessionId).mp4"
        let encoded     = objectName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? objectName

        guard let url = URL(string: "\(baseURL)?uploadType=media&name=\(encoded)") else {
            throw StorageError.invalidResponse
        }

        var request          = URLRequest(url: url, timeoutInterval: 120)
        request.httpMethod   = "POST"
        request.setValue("Bearer \(token)",  forHTTPHeaderField: "Authorization")
        request.setValue("video/mp4",         forHTTPHeaderField: "Content-Type")

        let (responseData, response) = try await URLSession.shared.upload(for: request, from: data)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw StorageError.uploadFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        guard
            let json   = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
            let tokens = json["downloadTokens"] as? String
        else { throw StorageError.invalidResponse }

        let pathEncoded = objectName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? objectName
        return "\(baseURL)/\(pathEncoded)?alt=media&token=\(tokens)"
    }

    // MARK: - Private Helpers

    /// Retrieves the Firebase ID token for the currently signed-in user.
    /// Used in the Authorization: Bearer header for all Storage REST calls.
    private func getIDToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            guard let user = Auth.auth().currentUser else {
                continuation.resume(throwing: StorageError.notAuthenticated)
                return
            }
            user.getIDToken { token, error in
                if let error  { continuation.resume(throwing: error); return }
                if let token  { continuation.resume(returning: token) }
                else          { continuation.resume(throwing: StorageError.notAuthenticated) }
            }
        }
    }

    // MARK: - StorageError

    enum StorageError: LocalizedError {
        case notAuthenticated
        case invalidImageData
        case uploadFailed(statusCode: Int)
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "You must be signed in to upload files."
            case .invalidImageData:
                return "Could not convert image to upload format."
            case .uploadFailed(let code):
                return "Upload failed with HTTP \(code). Check your internet connection."
            case .invalidResponse:
                return "Unexpected response from Firebase Storage."
            }
        }
    }
}
