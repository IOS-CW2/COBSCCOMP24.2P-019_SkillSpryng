import SwiftUI

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let conversation: Conversation

    @StateObject private var viewModel: ChatViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool

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
                        .font(.system(size: 16, weight: .bold))
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text(viewModel.isTyping ? "Typing…" : "Online")
                            .font(.system(size: 12))
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
                    Button(action: { }) {
                        Image(systemName: "phone")
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Voice call")

                    Button(action: { }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Conversation info")
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
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.top)
                            .accessibilityLabel("Chat history for today")

                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        // Typing indicator — always in the hierarchy, shown/hidden via opacity
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 7, height: 7)
                                    .scaleEffect(viewModel.isTyping ? 1.0 : 0.6)
                                    .animation(
                                        viewModel.isTyping
                                            ? .easeInOut(duration: 0.45).repeatForever().delay(Double(i) * 0.15)
                                            : .default,
                                        value: viewModel.isTyping
                                    )
                            }
                            Text("\(conversation.participant.fullName.split(separator: " ").first.map(String.init) ?? "") is typing")
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
                Button(action: { }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.Colors.primary)
                }
                .accessibilityLabel("Attach file")

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
    }

    // sendMessage is handled by ChatViewModel.send(text:)
}

// MARK: - MessageBubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromMe { Spacer() }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                switch message.type {
                case .text:
                    Text(message.text ?? "")
                        .font(.system(size: 15))
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
                                .font(.system(size: 14, weight: .bold))
                            Text(message.fileSize ?? "")
                                .font(.system(size: 10))
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
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }

            if !message.isFromMe { Spacer() }
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(message.isFromMe ? "You" : conversation_participantName(message)): "
            + (message.text
               ?? (message.type == .image ? "Image attachment"
                   : (message.fileName ?? "File attachment")))
            + ", \(message.timeString)"
        )
    }

    // Helper so the label compiles without needing a reference to the parent view
    private func conversation_participantName(_ message: ChatMessage) -> String { "Them" }
}
