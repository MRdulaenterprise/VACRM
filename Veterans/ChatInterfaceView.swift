//
//  ChatInterfaceView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Chat interface component for displaying messages and handling user input
struct ChatInterfaceView: View {
    
    // MARK: - Properties
    let session: ChatSession
    let openAIService: OpenAIService
    let documentService: CopilotDocumentService
    let pdfExporter: ChatPDFExporter
    
    @Environment(\.modelContext) private var modelContext
    @Query private var messages: [ChatMessage]
    
    @State private var currentMessage = ""
    @State private var isSending = false
    @State private var selectedTemplate: PromptTemplate?
    @State private var showingTemplatePicker = false
    @State private var showingDocumentList = false
    
    // MARK: - Computed Properties
    
    private var sessionMessages: [ChatMessage] {
        messages.filter { $0.session?.id == session.id }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader
            
            Divider()
            
            // Messages Area
            messagesArea
            
            Divider()
            
            // Input Area
            inputArea
        }
    }
    
    // MARK: - Chat Header
    
    private var chatHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    Text("\(sessionMessages.count) messages")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if let veteran = session.associatedVeteran {
                        Text("Veteran: \(veteran.fullName)")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    
                    if let template = session.promptTemplate {
                        Text("Template: \(template.name)")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: { showingDocumentList = true }) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(session.documents.isEmpty)
                
                Button(action: { exportSession() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Messages Area
    
    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if sessionMessages.isEmpty {
                        emptyMessagesView
                    } else {
                        ForEach(sessionMessages, id: \.id) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                    }
                    
                    if isSending {
                        loadingMessageView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .onChange(of: sessionMessages.count) { _, _ in
                if let lastMessage = sessionMessages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Input Area
    
    private var inputArea: some View {
        VStack(spacing: 12) {
            // Template Picker
            if let template = selectedTemplate {
                templatePreview(template)
            }
            
            // Input Field
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Type your message...", text: $currentMessage, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue.opacity(0.2), lineWidth: 1)
                        )
                        .lineLimit(1...10)
                    
                    HStack {
                        Button(action: { showingTemplatePicker = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 12))
                                Text("Templates")
                                    .font(.system(size: 12))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        Text("\(currentMessage.count) characters")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showingTemplatePicker) {
            templatePickerSheet
        }
        .sheet(isPresented: $showingDocumentList) {
            documentListSheet
        }
    }
    
    // MARK: - Empty States
    
    private var emptyMessagesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Start the Conversation")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Ask me anything about Veterans Benefits claims, or use a template to get started")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if !session.documents.isEmpty {
                Text("📄 \(session.documents.count) document(s) available for context")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    private var loadingMessageView: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Copilot")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(.blue)
                            .frame(width: 6, height: 6)
                            .scaleEffect(isSending ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: isSending
                            )
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Template Preview
    
    private func templatePreview(_ template: PromptTemplate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.category.icon)
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                
                Text(template.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { selectedTemplate = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text(template.templateDescription)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Template Picker Sheet
    
    private var templatePickerSheet: some View {
        NavigationView {
            TemplatePickerView(
                selectedTemplate: $selectedTemplate,
                onTemplateSelected: { template in
                    selectedTemplate = template
                    showingTemplatePicker = false
                }
            )
            .navigationTitle("Prompt Templates")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingTemplatePicker = false
                    }
                }
            }
        }
        .frame(minWidth: 600, idealWidth: 800, maxWidth: 1000)
        .frame(minHeight: 400, idealHeight: 600, maxHeight: 800)
    }
    
    // MARK: - Document List Sheet
    
    private var documentListSheet: some View {
        NavigationView {
            DocumentListView(session: session, documentService: documentService)
                .navigationTitle("Session Documents")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showingDocumentList = false
                        }
                    }
                }
        }
        .frame(minWidth: 600, idealWidth: 800, maxWidth: 1000)
        .frame(minHeight: 400, idealHeight: 600, maxHeight: 800)
    }
    
    // MARK: - Helper Methods
    
    private func sendMessage() {
        let messageText = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        isSending = true
        
        Task {
            do {
                // Create user message
                let userMessage = ChatMessage(
                    role: .user,
                    content: messageText
                )
                userMessage.session = session
                
               // Smart de-identification: Only de-identify if actual PHI detected in user query
               let deidentificationService = DeIdentificationService()
               
               if await deidentificationService.shouldDeidentify(messageText, context: .userQuery) {
                   let deidentificationResult = await deidentificationService.deidentifyWithGPT4(text: messageText, context: .userQuery)
                   
                   if deidentificationResult.redactionLog != "No PHI/PII detected or redacted." {
                       userMessage.isDeidentified = true
                       userMessage.deidentifiedContent = deidentificationResult.deidentifiedText
                   }
               }
                
                // Update model on main thread
                await MainActor.run {
                    modelContext.insert(userMessage)
                    session.updateLastMessage()
                    try? modelContext.save()
                }
                
                // Send ORIGINAL message to OpenAI for response (not de-identified version)
                // This allows helpful responses to hypothetical cases
                let messages = openAIService.createMessageArray(
                    conversationHistory: sessionMessages,
                    currentMessage: messageText  // Use original, not de-identified
                )
                
                let response = try await openAIService.sendChatCompletion(messages: messages)
                
                // Create assistant message
                let assistantMessage = ChatMessage(
                    role: .assistant,
                    content: response
                )
                assistantMessage.session = session
                assistantMessage.modelUsed = "gpt-4"
                assistantMessage.processingTime = 0.0 // Would be calculated in real implementation
                
                // Update model on main thread
                await MainActor.run {
                    modelContext.insert(assistantMessage)
                    session.updateLastMessage()
                    try? modelContext.save()
                }
                
                // Clear input
                await MainActor.run {
                    currentMessage = ""
                    selectedTemplate = nil
                    isSending = false
                }
                
            } catch {
                await MainActor.run {
                    isSending = false
                    print("Failed to send message: \(error)")
                }
            }
        }
    }
    
    private func exportSession() {
        Task {
            do {
                let messages = sessionMessages
                _ = try await pdfExporter.exportChatSessionWithPicker(
                    session,
                    messages: messages,
                    exportedBy: "Current User" // In production, get actual user
                )
            } catch {
                print("Failed to export session: \(error)")
            }
        }
    }
}

// MARK: - Supporting Views

struct TemplatePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var templates: [PromptTemplate]
    
    @Binding var selectedTemplate: PromptTemplate?
    let onTemplateSelected: (PromptTemplate) -> Void
    
    var body: some View {
        List(templates, id: \.id) { template in
            TemplatePickerRowView(
                template: template,
                isSelected: selectedTemplate?.id == template.id,
                onSelect: { onTemplateSelected(template) }
            )
        }
        .listStyle(.sidebar)
    }
}

struct TemplatePickerRowView: View {
    let template: PromptTemplate
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: template.category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                
                Text(template.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
            }
            
            Text(template.templateDescription)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            if !template.variables.isEmpty {
                Text("Variables: \(template.variables.joined(separator: ", "))")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct DocumentListView: View {
    let session: ChatSession
    let documentService: CopilotDocumentService
    
    var body: some View {
        List(session.documents, id: \.id) { document in
            DocumentRowView(document: document, documentService: documentService)
        }
        .listStyle(.sidebar)
    }
}

struct DocumentRowView: View {
    let document: ChatDocument
    let documentService: CopilotDocumentService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                
                Text(document.fileName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(document.fileSizeString)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            if let summary = document.summary {
                Text(summary)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            HStack {
                Text(document.processingStatus)
                    .font(.system(size: 11))
                    .foregroundColor(document.isReady ? .green : .orange)
                
                Spacer()
                
                Text(formatDate(document.uploadDate))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    ChatInterfaceView(
        session: ChatSession(title: "Test Session"),
        openAIService: OpenAIService(),
        documentService: CopilotDocumentService(),
        pdfExporter: ChatPDFExporter()
    )
    .modelContainer(for: [ChatSession.self, ChatMessage.self, ChatDocument.self, PromptTemplate.self], inMemory: true)
}
