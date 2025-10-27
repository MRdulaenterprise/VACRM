//
//  ChatMessageView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Individual chat message display component
/// Handles markdown rendering, timestamps, and de-identification indicators
struct ChatMessageView: View {
    
    // MARK: - Properties
    let message: ChatMessage
    
    @State private var isHovered = false
    @State private var showingCopyConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            avatarView
            
            // Message Content
            VStack(alignment: .leading, spacing: 8) {
                // Header
                messageHeader
                
                // Content
                messageContent
                
                // Footer
                messageFooter
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(messageBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(messageBorderColor, lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            messageContextMenu
        }
        .overlay(alignment: .topTrailing) {
            if isHovered {
                messageActions
            }
        }
    }
    
    // MARK: - Avatar View
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(avatarBackgroundColor)
                .frame(width: 32, height: 32)
            
            Image(systemName: message.role.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(avatarIconColor)
        }
    }
    
    // MARK: - Message Header
    
    private var messageHeader: some View {
        HStack {
            Text(message.role.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(headerTextColor)
            
            Spacer()
            
            Text(formatTimestamp(message.timestamp))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Message Content
    
    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main content
            Text(message.content)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // De-identification indicator
            if message.isDeidentified {
                deidentificationIndicator
            }
            
            // Associated document indicator
            if let document = message.associatedDocument {
                documentIndicator(document)
            }
        }
    }
    
    // MARK: - Message Footer
    
    private var messageFooter: some View {
        HStack {
            // Model info (for assistant messages)
            if message.role == .assistant, let model = message.modelUsed {
                Text("Model: \(model)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Processing time (for assistant messages)
            if message.role == .assistant, let processingTime = message.processingTime {
                Text("\(String(format: "%.1f", processingTime))s")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            // Token count
            if message.tokenCount > 0 {
                Text("\(message.tokenCount) tokens")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - De-identification Indicator
    
    private var deidentificationIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 12))
                .foregroundColor(.orange)
            
            Text("De-identified content")
                .font(.system(size: 11))
                .foregroundColor(.orange)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
    
    // MARK: - Document Indicator
    
    private func documentIndicator(_ document: ChatDocument) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.fill")
                .font(.system(size: 12))
                .foregroundColor(.blue)
            
            Text(document.fileName)
                .font(.system(size: 11))
                .foregroundColor(.blue)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
    
    // MARK: - Message Actions
    
    private var messageActions: some View {
        HStack(spacing: 8) {
            Button(action: copyMessage) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .background(.regularMaterial, in: Circle())
            .frame(width: 24, height: 24)
            
            if message.role == .assistant {
                Button(action: regenerateMessage) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .background(.regularMaterial, in: Circle())
                .frame(width: 24, height: 24)
            }
        }
        .padding(4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Context Menu
    
    private var messageContextMenu: some View {
        Group {
            Button(action: copyMessage) {
                Label("Copy Message", systemImage: "doc.on.doc")
            }
            
            if message.role == .assistant {
                Button(action: regenerateMessage) {
                    Label("Regenerate", systemImage: "arrow.clockwise")
                }
            }
            
            Divider()
            
            Button(action: copyTimestamp) {
                Label("Copy Timestamp", systemImage: "clock")
            }
            
            if message.isDeidentified {
                Button(action: showDeidentificationDetails) {
                    Label("De-identification Details", systemImage: "shield.checkered")
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var messageBackgroundColor: Color {
        switch message.role {
        case .user:
            return .blue.opacity(0.1)
        case .assistant:
            return .green.opacity(0.1)
        case .system:
            return .gray.opacity(0.1)
        }
    }
    
    private var messageBorderColor: Color {
        switch message.role {
        case .user:
            return .blue.opacity(0.3)
        case .assistant:
            return .green.opacity(0.3)
        case .system:
            return .gray.opacity(0.3)
        }
    }
    
    private var avatarBackgroundColor: Color {
        switch message.role {
        case .user:
            return .blue
        case .assistant:
            return .green
        case .system:
            return .gray
        }
    }
    
    private var avatarIconColor: Color {
        return .white
    }
    
    private var headerTextColor: Color {
        switch message.role {
        case .user:
            return .blue
        case .assistant:
            return .green
        case .system:
            return .gray
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func copyMessage() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(message.content, forType: .string)
        
        showingCopyConfirmation = true
        
        // Hide confirmation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingCopyConfirmation = false
        }
    }
    
    private func copyTimestamp() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(formatTimestamp(message.timestamp), forType: .string)
    }
    
    private func regenerateMessage() {
        // In a real implementation, this would trigger message regeneration
        print("Regenerate message: \(message.id)")
    }
    
    private func showDeidentificationDetails() {
        // In a real implementation, this would show details about what was de-identified
        print("Show de-identification details for message: \(message.id)")
    }
}

// MARK: - Message Extensions

extension ChatMessage {
    /// Get display content (de-identified if available)
    var displayContent: String {
        return isDeidentified ? (deidentifiedContent ?? content) : content
    }
    
    /// Check if message has associated document
    var hasDocument: Bool {
        return associatedDocument != nil
    }
    
    /// Get message age as human-readable string
    var ageString: String {
        let interval = Date().timeIntervalSince(timestamp)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Message Status

enum MessageStatus {
    case sending
    case sent
    case delivered
    case failed
    
    var icon: String {
        switch self {
        case .sending:
            return "clock"
        case .sent:
            return "checkmark"
        case .delivered:
            return "checkmark.circle"
        case .failed:
            return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .sending:
            return .orange
        case .sent:
            return .blue
        case .delivered:
            return .green
        case .failed:
            return .red
        }
    }
}

// MARK: - Copy Confirmation Overlay

struct CopyConfirmationOverlay: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                
                Text("Copied!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ChatMessageView(
            message: ChatMessage(
                role: .user,
                content: "Hello, I need help with my VA disability claim for PTSD."
            )
        )
        
        ChatMessageView(
            message: ChatMessage(
                role: .assistant,
                content: "I'd be happy to help you with your VA disability claim for PTSD. This is a common condition among veterans, and there are specific requirements and processes for filing a successful claim.\n\nHere are the key steps:\n\n1. **Gather Medical Evidence**: You'll need current medical records showing your PTSD diagnosis\n2. **Service Connection**: Establish a connection between your PTSD and military service\n3. **Complete VA Forms**: File VA Form 21-526EZ (Application for Disability Compensation)\n4. **Submit Supporting Documents**: Include medical records, service records, and any nexus letters\n\nWould you like me to help you with any specific part of this process?"
            )
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.regularMaterial)
}
