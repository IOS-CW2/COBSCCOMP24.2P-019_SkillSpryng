import SwiftUI
import PhotosUI

// MARK: - ChatDetailView
// Conversation detail screen for one-to-one messaging.
// Handles chat history rendering, input controls, image attachment flows,
// and participant action shortcuts like calling or viewing contact info.
struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let conversation: Conversation

    @StateObject private var viewModel: ChatViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

    // MARK: - Sheet state
    @State private var showInfoSheet   = false
    @State private var showImagePicker = false
    @State private var pickedImage: UIImage?

    init(conversation: Conversation) {
        self.conversation = conversation
        _viewModel = StateObject(wrappedValue: ChatViewModel(conversation: conversation))
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .accessibilityLabel("Back")

                Image(conversation.participant.profileImageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(conversation.participant.fullName)
                        .font(AppTheme.Typography.headline)
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 8, height: 8)
                        Text(viewModel.isTyping ? "Typing…" : "Online")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(.gray)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.isTyping)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "\(conversation.participant.fullName), \(viewModel.isTyping ? "typing" : "online")"
                )

                Spacer()

                HStack(spacing: 20) {
                    // Phone button — opens the dialler with the participant's phone number
                    Button(action: {
                        let phone = conversation.participant.phoneNumber
                            .replacingOccurrences(of: " ", with: "")
                        if let url = URL(string: "tel:\(phone)"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Image(systemName: "phone")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .accessibilityLabel("Call \(conversation.participant.fullName)")
                    .accessibilityHint("Double-tap to open the phone dialler")

                    // Info button — shows participant detail sheet
                    Button(action: { showInfoSheet = true }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .accessibilityLabel("Conversation info for \(conversation.participant.fullName)")
                    .accessibilityHint("Double-tap to view contact details")
                }
            }
            .padding()
            .background(Color.white)

            Divider()

            // MARK: Chat History
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Text("TODAY")
                            .font(AppTheme.Typography.badge)
                            .foregroundColor(.gray)
                            .padding(.top)
                            .accessibilityLabel("Chat history for today")

                        ForEach(viewModel.messages.filter { !($0.isDeleted ?? false) }) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        // Typing indicator — always in the hierarchy, shown/hidden via opacity
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { i in
                                typingIndicatorDot(for: i)
                            }
                            Text(typingStatusText)
                                .font(.system(size: 12).italic())
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .opacity(viewModel.isTyping ? 1 : 0)
                        .allowsHitTesting(false)
                        .id("typingAnchor")

                        // Invisible bottom anchor
                        Color.clear
                            .frame(height: 1)
                            .id("bottomAnchor")
                    }
                    .padding(.bottom, 20)
                }
                .onAppear {
                    proxy.scrollTo("typingAnchor", anchor: .bottom)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("typingAnchor", anchor: .bottom)
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.99))

            // MARK: Input Bar
            HStack(spacing: 16) {
                // Attach button — opens the photo picker
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .accessibilityLabel("Attach image")
                .accessibilityHint("Double-tap to choose a photo from your library")

                TextField("Send a message…", text: $messageText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(24)
                    .focused($isInputFocused)
                    .onSubmit { viewModel.send(text: messageText); messageText = ""; isInputFocused = false }
                    .accessibilityIdentifier("chatMessageTextField")
                    .accessibilityLabel("Message input field")

                Button(action: { viewModel.send(text: messageText); messageText = ""; isInputFocused = false }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(
                            messageText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AppTheme.Colors.primary.opacity(0.3)
                                : AppTheme.Colors.primary
                        )
                }
                .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty)
                .animation(.easeInOut(duration: 0.15), value: messageText.isEmpty)
                .accessibilityIdentifier("chatSendButton")
                .accessibilityLabel("Send message")
            }
            .padding()
            .background(Color.white)
        }
        .navigationBarHidden(true)
        // MARK: - Participant Info Sheet
        .sheet(isPresented: $showInfoSheet) {
            ParticipantInfoSheet(participant: conversation.participant)
        }
        // MARK: - Image Picker Sheet
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $pickedImage)
                .ignoresSafeArea()
        }
        .onChange(of: pickedImage) { image in
            // When the user picks a photo, send it as an attachment message placeholder
            guard image != nil else { return }
            viewModel.send(text: "📷 Photo attached")
            pickedImage = nil
        }
    }

    // sendMessage is handled by ChatViewModel.send(text:)

    private func typingIndicatorDot(for index: Int) -> some View {
        let animation = viewModel.isTyping
            ? Animation.easeInOut(duration: 0.45).repeatForever().delay(Double(index) * 0.15)
            : .default

        return Circle()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 7, height: 7)
            .scaleEffect(viewModel.isTyping ? 1.0 : 0.6)
            .animation(animation, value: viewModel.isTyping)
    }

    private var typingStatusText: String {
        let firstName = conversation.participant.fullName.split(separator: " ").first.map(String.init) ?? conversation.participant.fullName
        return "\(firstName) is typing"
    }
}

// MARK: - ParticipantInfoSheet

/// Shown when the user taps the ⓘ button in the chat header.
/// Displays the participant's name, skills, and a quick-action to call them.
struct ParticipantInfoSheet: View {
    let participant: User
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 28) {

                // Avatar
                ZStack {
                    Circle()
                        .fill(AppTheme.Colors.primary.opacity(0.12))
                        .frame(width: 96, height: 96)
                    Image(systemName: "person.fill")
                        .font(.system(size: 44))
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .accessibilityHidden(true)
                .padding(.top, 8)

                // Name & Location
                VStack(spacing: 6) {
                    Text(participant.fullName)
                        .font(AppTheme.Typography.title)
                    if !participant.location.isEmpty {
                        Label(participant.location, systemImage: "mappin.and.ellipse")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(.gray)
                    }
                }
                .accessibilityElement(children: .combine)

                // Skills chips
                if !participant.skillsToTeach.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Teaches")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        FlowLayout(items: participant.skillsToTeach) { skill in
                            Text(skill)
                                .font(AppTheme.Typography.badge)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.Colors.primary.opacity(0.1))
                                .foregroundColor(AppTheme.Colors.primary)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }

                // Call button
                Button(action: {
                    let phone = participant.phoneNumber
                        .replacingOccurrences(of: " ", with: "")
                    if let url = URL(string: "tel:\(phone)"),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Call \(participant.fullName.split(separator: " ").first.map(String.init) ?? "")",
                          systemImage: "phone.fill")
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .accessibilityLabel("Call \(participant.fullName)")

                Spacer()
            }
            .navigationTitle("Contact Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .accessibilityLabel("Close contact info")
                }
            }
        }
    }
}

// MARK: - FlowLayout
/// Wraps items into rows like a tag cloud. Used for skill chips in ParticipantInfoSheet.
private struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        // Use a simple wrapping approach via a lazy VGrid of rows.
        // For this use-case (short skill names) this is sufficient.
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    content(item)
                }
            }
        }
    }
}

// MARK: - MessageBubble

/// Renders a single chat message bubble in the conversation thread.
/// Supports text, image, and attachment styles, with left/right layout
/// based on the sender.
struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromMe { Spacer() }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                switch message.type {
                case .text:
                    Text(message.text ?? "")
                        .font(AppTheme.Typography.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            message.isFromMe ? AppTheme.Colors.primary : Color.white
                        )
                        .foregroundColor(message.isFromMe ? .white : .black)
                        .cornerRadius(
                            16,
                            corners: message.isFromMe
                                ? [.topLeft, .topRight, .bottomLeft]
                                : [.topLeft, .topRight, .bottomRight]
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                        .frame(maxWidth: 280, alignment: message.isFromMe ? .trailing : .leading)

                case .image:
                    Image(message.imageName ?? "")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 240, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 2)
                        )

                case .attachment:
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: "doc.fill")
                                .foregroundColor(.orange)
                        }
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(message.fileName ?? "")
                                .font(AppTheme.Typography.subheadline)
                            Text(message.fileSize ?? "")
                                .font(AppTheme.Typography.caption2)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    .padding()
                    .frame(width: 280)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }

                Text(message.timeString)
                    .font(AppTheme.Typography.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }

            if !message.isFromMe { Spacer() }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabelText)
    }

    private var accessibilityLabelText: String {
        let speaker = message.isFromMe ? "You" : conversation_participantName(message)
        let content: String
        if let text = message.text {
            content = text
        } else if message.type == .image {
            content = "Image attachment"
        } else {
            content = message.fileName ?? "File attachment"
        }
        return "\(speaker): \(content), \(message.timeString)"
    }

    // Helper so the label compiles without needing a reference to the parent view
    private func conversation_participantName(_ message: ChatMessage) -> String { "Them" }
}
