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
    
    // File upload state - passed from parent to avoid Menu/fileImporter conflict
    @Binding var showingFileUpload: Bool
    
    @State private var currentMessage = ""
    @State private var isSending = false
    @State private var selectedTemplate: PromptTemplate?
    @State private var showingTemplatePicker = false
    @State private var showingDocumentList = false
    @State private var showingDocumentSelector = false
    @State private var showingUploadError = false
    @State private var uploadErrorMessage = ""
    
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
        .alert("Upload Error", isPresented: $showingUploadError) {
            Button("OK") { }
        } message: {
            Text(uploadErrorMessage)
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
                    
                    if !session.documents.isEmpty {
                        Text("📄 \(session.documents.count) document(s)")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Single Upload Button
                Button(action: {
                    triggerFileUpload()
                }) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Upload File")
                
                // View Documents Button
                Button(action: { showingDocumentList = true }) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(session.documents.isEmpty)
                
                // Export Button
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
            // Upload Progress Indicator
            if documentService.isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing document...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(documentService.processingProgress * 100))%")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Attached Documents List
            if !session.documents.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(session.documents, id: \.id) { document in
                            HStack(spacing: 6) {
                                Image(systemName: "doc.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                                Text(document.fileName)
                                    .font(.system(size: 11))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            
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
        .sheet(isPresented: $showingDocumentSelector) {
            DocumentSelectorView(
                session: session,
                documentService: documentService,
                onDocumentSelected: { document in
                    attachDocumentToSession(document)
                }
            )
            .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
            .frame(minHeight: 600, idealHeight: 700, maxHeight: 800)
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
                // Include session documents so OpenAI can reference them
                
                // Get fresh documents from session (force relationship refresh)
                let sessionDocuments = Array(session.documents)
                print("📄 Preparing to send message with \(sessionDocuments.count) document(s)")
                
                if !sessionDocuments.isEmpty {
                    for (index, doc) in sessionDocuments.enumerated() {
                        print("  Document \(index + 1): \(doc.fileName)")
                        print("    - Has extracted text: \(doc.extractedText != nil)")
                        print("    - Has deidentified text: \(doc.deidentifiedText != nil)")
                        print("    - Has summary: \(doc.summary != nil)")
                    }
                } else {
                    print("⚠️ No documents found in session - documents may not be properly associated")
                }
                
                let messages = openAIService.createMessageArray(
                    conversationHistory: sessionMessages,
                    currentMessage: messageText,  // Use original, not de-identified
                    sessionDocuments: sessionDocuments  // Pass documents to OpenAI
                )
                
                print("📤 Sending \(messages.count) messages to OpenAI (including system messages)")
                
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
    
    private func triggerFileUpload() {
        print("📎 Upload button tapped - triggering file upload")
        // Reset state first, then set to true after delay (workaround for Menu/fileImporter conflict)
        // This ensures the Menu is fully dismissed before fileImporter presents
        Task { @MainActor in
            // Reset to false first
            showingFileUpload = false
            // Small delay to ensure Menu is fully dismissed
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            print("📎 Setting showingFileUpload = true")
            showingFileUpload = true
        }
    }
    
    private func handleFileUpload(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            Task { @MainActor in
                // Ensure session is saved to database before processing documents
                do {
                    try modelContext.save()
                } catch {
                    await MainActor.run {
                        uploadErrorMessage = "Failed to save session: \(error.localizedDescription)"
                        showingUploadError = true
                    }
                    return
                }
                
                // Capture ModelContext on main actor to avoid Sendable warning
                nonisolated(unsafe) let context = modelContext
                
                var successCount = 0
                var errorMessages: [String] = []
                
                for url in urls {
                    do {
                        _ = try await documentService.processDocument(
                            fileURL: url,
                            fileName: url.lastPathComponent,
                            sessionId: session.id,
                            context: context
                        )
                        successCount += 1
                    } catch {
                        let errorMsg = "Failed to process \(url.lastPathComponent): \(error.localizedDescription)"
                        print("❌ \(errorMsg)")
                        errorMessages.append(errorMsg)
                    }
                }
                
                // Show results to user
                await MainActor.run {
                    if !errorMessages.isEmpty {
                        if successCount > 0 {
                            uploadErrorMessage = "\(successCount) file(s) uploaded successfully.\n\nErrors:\n\(errorMessages.joined(separator: "\n"))"
                        } else {
                            uploadErrorMessage = "Failed to upload files:\n\(errorMessages.joined(separator: "\n"))"
                        }
                        showingUploadError = true
                    }
                }
            }
        case .failure(let error):
            Task { @MainActor in
                uploadErrorMessage = "File selection failed: \(error.localizedDescription)"
                showingUploadError = true
            }
            print("❌ File upload failed: \(error)")
        }
    }
    
    private func attachDocumentToSession(_ document: Document) {
        Task { @MainActor in
            // Capture ModelContext on main actor to avoid Sendable warning
            nonisolated(unsafe) let context = modelContext
            do {
                // Try to create URL from filePath
                var fileURL: URL?
                
                // First, try as absolute path
                if document.filePath.hasPrefix("/") {
                    fileURL = URL(fileURLWithPath: document.filePath)
                } else if let url = URL(string: document.filePath), url.scheme != nil {
                    // Try as URL string
                    fileURL = url
                } else {
                    // Try relative to documents directory
                    if let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        fileURL = documentsDir.appendingPathComponent(document.filePath)
                    }
                }
                
                guard let filePath = fileURL else {
                    print("Invalid document path: \(document.filePath)")
                    return
                }
                
                // Check if file exists
                if !FileManager.default.fileExists(atPath: filePath.path) {
                    print("Document file not found at path: \(filePath.path)")
                    // Still try to process - the file might be accessible via security-scoped resource
                }
                
                // Process the document through CopilotDocumentService
                _ = try await documentService.processDocument(
                    fileURL: filePath,
                    fileName: document.fileName,
                    sessionId: session.id,
                    context: context
                )
                
                showingDocumentSelector = false
            } catch {
                print("Failed to attach document to session: \(error)")
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

// MARK: - Document Selector View

struct DocumentSelectorView: View {
    let session: ChatSession
    let documentService: CopilotDocumentService
    let onDocumentSelected: (Document) -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var documents: [Document]
    @Query private var veterans: [Veteran]
    
    @State private var searchText = ""
    @State private var selectedVeteran: Veteran?
    @State private var showingVeteranFilter = false
    
    private var filteredDocuments: [Document] {
        var filtered = documents
        
        // Filter by veteran if selected
        if let veteran = selectedVeteran {
            filtered = filtered.filter { $0.veteran?.id == veteran.id }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { document in
                document.fileName.localizedCaseInsensitiveContains(searchText) ||
                document.documentType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                document.documentDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.fileName < $1.fileName }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select Document")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Choose a document to attach to this chat session")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Search and Filter
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Search documents...", text: $searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14))
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.blue.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Veteran Filter
                    Menu {
                        Button(action: {
                            selectedVeteran = nil
                        }) {
                            Label("All Veterans", systemImage: selectedVeteran == nil ? "checkmark" : "")
                        }
                        
                        Divider()
                        
                        ForEach(veterans, id: \.id) { veteran in
                            Button(action: {
                                selectedVeteran = veteran
                            }) {
                                Label(veteran.fullName, systemImage: selectedVeteran?.id == veteran.id ? "checkmark" : "")
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                            Text(selectedVeteran?.fullName ?? "All Veterans")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Documents List
            if filteredDocuments.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Documents Found")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(searchText.isEmpty && selectedVeteran == nil ? "No documents in database" : "No documents match your filters")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredDocuments, id: \.id) { document in
                            DocumentSelectionRow(document: document) {
                                onDocumentSelected(document)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}

// MARK: - Document Selection Row

struct DocumentSelectionRow: View {
    let document: Document
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Document Icon
                Image(systemName: "doc.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                
                // Document Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fileName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        Text(document.documentType.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let veteran = document.veteran {
                            Text("• \(veteran.fullName)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        Text("• \(formatFileSize(document.fileSize))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Select Icon
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.blue.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Preview

#Preview {
    ChatInterfaceView(
        session: ChatSession(title: "Test Session"),
        openAIService: OpenAIService(),
        documentService: CopilotDocumentService(),
        pdfExporter: ChatPDFExporter(),
        showingFileUpload: .constant(false)
    )
    .modelContainer(for: [ChatSession.self, ChatMessage.self, ChatDocument.self, PromptTemplate.self], inMemory: true)
}
