import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @Environment(\.dismiss) var dismiss

    // Camera / image picker state
    @State private var showSourcePicker  = false
    @State private var showCamera        = false
    @State private var showLibraryPicker = false
    @State private var pickedImage: UIImage?
    @State private var uploadError: String?
    @State private var isSaveLoading    = false
    @State private var showSaveSuccess  = false

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Edit Profile", backAction: { dismiss() })

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {

                    // MARK: Avatar — tapping opens AVFoundation camera or photo library
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            // Profile image: use picked image first, then URL, then placeholder
                            Group {
                                if let picked = pickedImage {
                                    Image(uiImage: picked)
                                        .resizable().scaledToFill()
                                } else if !vm.user.profileImageURL.isEmpty,
                                          vm.user.profileImageURL.hasPrefix("http") {
                                    AsyncImage(url: URL(string: vm.user.profileImageURL)) { img in
                                        img.resizable().scaledToFill()
                                    } placeholder: {
                                        avatarPlaceholder
                                    }
                                } else {
                                    avatarPlaceholder
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                            .accessibilityLabel("Profile photo")

                            // Camera button — triggers source picker
                            Button(action: { showSourcePicker = true }) {
                                Image(systemName: vm.isSaving ? "arrow.triangle.2.circlepath" : "camera.fill")
                                    .font(AppTheme.Typography.subheadline)
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(AppTheme.Colors.primary)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            }
                            .disabled(vm.isSaving)
                            .accessibilityLabel("Change profile photo")
                            .accessibilityHint("Opens camera or photo library")
                            .offset(x: 4, y: 4)
                        }

                        if vm.isSaving {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.primary))
                                    .scaleEffect(0.8)
                                Text("Uploading to Firebase Storage…")
                                    .font(AppTheme.Typography.caption2)
                                    .foregroundColor(.gray)
                            }
                        } else if let err = uploadError {
                            Text(err)
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else {
                            Text("Change Profile Photo")
                                .font(AppTheme.Typography.subheadline)
                                .foregroundColor(AppTheme.Colors.primary)
                        }
                    }
                    .padding(.top, 20)

                    // MARK: Form Fields
                    VStack(alignment: .leading, spacing: 24) {
                        EditField(label: "FULL NAME",     text: $vm.user.fullName)
                        EditField(label: "PHONE NUMBER",  text: $vm.user.phoneNumber)
                        EditField(label: "LOCATION",      text: $vm.user.location)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("BIO")
                                .font(AppTheme.Typography.badge)
                                .foregroundColor(.gray)
                            TextEditor(text: $vm.user.bio)
                                .font(AppTheme.Typography.callout)
                                .padding(12)
                                .frame(height: 100)
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
                                .accessibilityLabel("Bio")
                        }
                    }
                    .padding(.horizontal)

                    // MARK: Save Button — persists to Firestore
                    Button(action: saveProfile) {
                        HStack(spacing: 8) {
                            if isSaveLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isSaveLoading ? "Saving…" : showSaveSuccess ? "Saved ✓" : "Save Changes")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(showSaveSuccess ? Color.green : AppTheme.Colors.primary)
                        .cornerRadius(16)
                        .animation(.easeInOut(duration: 0.3), value: showSaveSuccess)
                    }
                    .disabled(isSaveLoading || vm.isSaving)
                    .padding(.horizontal)
                    .padding(.top, 24)

                    Button(action: { showDeleteAccountAlert = true }) {
                        Text("Delete Account")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 40)
                    .alert("Delete Account?", isPresented: $showDeleteAccountAlert) {
                        Button("Delete", role: .destructive) {
                            Task {
                                try? await FirebaseAuth.Auth.auth().currentUser?.delete()
                                FirebaseDataService.shared.db
                                    .collection("users")
                                    .document(FirebaseDataService.shared.uid ?? "")
                                    .delete()
                                UserDefaults.standard.set(false, forKey: "skillspryng.isLoggedIn")
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will permanently delete your account and all data. This action cannot be undone.")
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)

        // MARK: Source picker — Camera (AVFoundation) or Library
        .confirmationDialog("Change Profile Photo", isPresented: $showSourcePicker, titleVisibility: .visible) {
            Button("Take Photo") { showCamera = true }
            Button("Choose from Library") { showLibraryPicker = true }
            Button("Cancel", role: .cancel) {}
        }

        // MARK: AVFoundation camera sheet
        .fullScreenCover(isPresented: $showCamera) {
            CameraSheetView { image in
                pickedImage = image
                Task { await uploadImage(image) }
            }
        }

        // MARK: Photo library picker
        .sheet(isPresented: $showLibraryPicker) {
            ImagePicker(image: $pickedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
        .onChange(of: pickedImage) { image in
            // If image arrived from library picker (not camera — camera calls uploadImage directly)
            if !showCamera, let img = image {
                Task { await uploadImage(img) }
            }
        }
    }

    // MARK: - Helpers

    private var avatarPlaceholder: some View {
        ZStack {
            Circle().fill(AppTheme.Colors.primary.opacity(0.15))
            Image(systemName: "person.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.5))
        }
    }

    private func uploadImage(_ image: UIImage) async {
        uploadError = nil
        do {
            let url = try await FirebaseStorageService.shared.uploadProfileImage(image)
            vm.user.profileImageURL = url
            print("[EditProfileView] ✅ Image uploaded → \(url)")
        } catch {
            uploadError = "Upload failed: \(error.localizedDescription)"
            print("[EditProfileView] ❌ Upload error: \(error)")
        }
    }

    private func saveProfile() {
        isSaveLoading = true
        Task {
            await vm.saveProfile()
            isSaveLoading = false
            showSaveSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSaveSuccess = false
                dismiss()
            }
        }
    }
}

// MARK: - EditField (unchanged)
struct EditField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AppTheme.Typography.badge)
                .foregroundColor(.gray)
            TextField("", text: $text)
                .font(AppTheme.Typography.callout)
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                .accessibilityLabel(label)
        }
    }
}

#Preview { EditProfileView() }
