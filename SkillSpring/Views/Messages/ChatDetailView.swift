import SwiftUI

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let conversation: Conversation
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.Colors.primary)
                }
                
                Image(conversation.participant.profileImageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(conversation.participant.fullName)
                        .font(.system(size: 16, weight: .bold))
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .accessibilityElement(children: .combine)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: { }) {
                        Image(systemName: "phone")
                            .foregroundColor(.gray)
                    }
                    Button(action: { }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            // Chat History
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        Text("TODAY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        ForEach(conversation.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        HStack {
                            Text("\(conversation.participant.fullName.split(separator: " ").first ?? "") is typing...")
                                .font(.system(size: 12).italic())
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    .padding(.bottom, 20)
                }
                .onAppear {
                    if let lastId = conversation.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.99))
            
            // Input Area
            VStack {
                HStack(spacing: 16) {
                    Button(action: { }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                    
                    TextField("Send a message...", text: $messageText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(24)
                    
                    Button(action: { }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                .padding()
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
}

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
                        .background(message.isFromMe ? AppTheme.Colors.primary : Color.white)
                        .foregroundColor(message.isFromMe ? .white : .black)
                        .cornerRadius(16, corners: message.isFromMe ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                        .frame(maxWidth: 280, alignment: message.isFromMe ? .trailing : .leading)
                    
                case .image:
                    Image(message.imageName ?? "")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 240, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 2))
                    
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
        .accessibilityLabel("\(message.isFromMe ? "You" : "Them"): \(message.text ?? (message.type == .image ? "Image Attachment" : (message.fileName ?? "Attachment"))), at \(message.timeString)")
    }
}
