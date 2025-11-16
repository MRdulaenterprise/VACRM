//
//  CopilotView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Main Copilot interface with three-panel layout
/// Left: Session list, Center: Chat interface, Right: Options and templates
@MainActor
struct CopilotView: View {
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [ChatSession]
    @Query private var templates: [PromptTemplate]
    
    @StateObject private var openAIService = OpenAIService()
    @StateObject private var documentService = CopilotDocumentService()
    @StateObject private var pdfExporter = ChatPDFExporter()
    
    @State private var selectedSession: ChatSession?
    @State private var searchText = ""
    @State private var showingSettings = false
    @State private var showingTemplateManager = false
    @State private var showingDocumentPicker = false
    @State private var newSessionTitle = ""
    @State private var showingNewSessionDialog = false
    @State private var showingFileUpload = false // For ChatInterfaceView file uploads
    
    // MARK: - Computed Properties
    
    private var filteredSessions: [ChatSession] {
        if searchText.isEmpty {
            return sessions.sorted { $0.lastMessageAt > $1.lastMessageAt }
        } else {
            return sessions.filter { session in
                session.title.localizedCaseInsensitiveContains(searchText) ||
                session.associatedVeteran?.fullName.localizedCaseInsensitiveContains(searchText) == true
            }.sorted { $0.lastMessageAt > $1.lastMessageAt }
        }
    }
    
    private var groupedSessions: [(String, [ChatSession])] {
        let calendar = Calendar.current
        let now = Date()
        
        let today = sessions.filter { calendar.isDateInToday($0.lastMessageAt) }
        let yesterday = sessions.filter { calendar.isDateInYesterday($0.lastMessageAt) }
        let thisWeek = sessions.filter { 
            calendar.isDate($0.lastMessageAt, equalTo: now, toGranularity: .weekOfYear) &&
            !calendar.isDateInToday($0.lastMessageAt) &&
            !calendar.isDateInYesterday($0.lastMessageAt)
        }
        let older = sessions.filter { 
            !calendar.isDate($0.lastMessageAt, equalTo: now, toGranularity: .weekOfYear)
        }
        
        var groups: [(String, [ChatSession])] = []
        
        if !today.isEmpty {
            groups.append(("Today", today))
        }
        if !yesterday.isEmpty {
            groups.append(("Yesterday", yesterday))
        }
        if !thisWeek.isEmpty {
            groups.append(("This Week", thisWeek))
        }
        if !older.isEmpty {
            groups.append(("Older", older))
        }
        
        return groups
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel - Session List
            sessionListPanel
                .frame(width: 300)
                .background(.regularMaterial)
            
            Divider()
            
            // Right Panel - Chat Interface
            chatInterfacePanel
                .frame(maxWidth: .infinity)
        }
        .navigationTitle("Copilot")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack {
                    Button(action: { showingTemplateManager = true }) {
                        Image(systemName: "doc.text")
                    }
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            CopilotSettingsView(onSave: { _ in })
        }
        .sheet(isPresented: $showingTemplateManager) {
            PromptTemplateManager()
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: 1200)
                .frame(minHeight: 600, idealHeight: 800, maxHeight: 1000)
        }
        .sheet(isPresented: $showingNewSessionDialog) {
            newSessionDialog
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleDocumentImport(result)
        }
        .fileImporter(
            isPresented: $showingFileUpload,
            allowedContentTypes: [.pdf, .text, .plainText, .data],
            allowsMultipleSelection: true
        ) { result in
            handleChatFileUpload(result)
        }
        .onAppear {
            initializeDefaultTemplates()
        }
    }
    
    // MARK: - Session List Panel
    
    private var sessionListPanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Chat Sessions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: { showingNewSessionDialog = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                
                TextField("Search sessions...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Sessions List
            if filteredSessions.isEmpty {
                emptySessionsView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedSessions, id: \.0) { group in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(group.0)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                
                                ForEach(group.1, id: \.id) { session in
                                    SessionRowView(
                                        session: session,
                                        isSelected: selectedSession?.id == session.id,
                                        onSelect: { selectedSession = session },
                                        onDelete: { deleteSession(session) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Chat Interface Panel
    
    private var chatInterfacePanel: some View {
        VStack(spacing: 0) {
            if let session = selectedSession {
                ChatInterfaceView(
                    session: session,
                    openAIService: openAIService,
                    documentService: documentService,
                    pdfExporter: pdfExporter,
                    showingFileUpload: $showingFileUpload
                )
            } else {
                emptyChatView
            }
        }
    }
    
    // MARK: - Options Panel
    
    private var optionsPanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Options")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Prompt Templates Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Prompt Templates")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: { showingTemplateManager = true }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if templates.isEmpty {
                            Text("No templates available")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(templates.prefix(3), id: \.id) { template in
                                TemplateRowView(template: template)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Quick Actions Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 8) {
                            Button(action: { showingDocumentPicker = true }) {
                                HStack {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.system(size: 14))
                                    Text("Upload Document")
                                        .font(.system(size: 14))
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(selectedSession == nil)
                            
                            if let session = selectedSession {
                                Button(action: { exportSession(session) }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 14))
                                        Text("Export to PDF")
                                            .font(.system(size: 14))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                        .padding(.horizontal, 16)
                    
                    // Session Info Section
                    if let session = selectedSession {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Session Info")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                CopilotInfoRow(label: "Messages", value: "\(session.messageCount)")
                                CopilotInfoRow(label: "Created", value: formatDate(session.createdAt))
                                CopilotInfoRow(label: "Last Activity", value: formatDate(session.lastMessageAt))
                                
                                if let veteran = session.associatedVeteran {
                                    CopilotInfoRow(label: "Veteran", value: veteran.fullName)
                                }
                                
                                if let template = session.promptTemplate {
                                    CopilotInfoRow(label: "Template", value: template.name)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Empty States
    
    private var emptySessionsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Chat Sessions")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Start a new conversation to get help with Veterans Benefits claims")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("New Chat") {
                showingNewSessionDialog = true
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyChatView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Welcome to Copilot")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Your AI assistant for Veterans Benefits Claims")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Select a chat session from the left panel or start a new conversation to begin")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - New Session Dialog
    
    private var newSessionDialog: some View {
        VStack(spacing: 20) {
            Text("New Chat Session")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Session Title")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                TextField("Enter session title...", text: $newSessionTitle)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    showingNewSessionDialog = false
                    newSessionTitle = ""
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Create") {
                    createNewSession()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(newSessionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
    
    // MARK: - Helper Methods
    
    private func initializeDefaultTemplates() {
        if templates.isEmpty {
            PromptTemplates.initializeDefaultTemplates(in: modelContext)
        }
    }
    
    private func createNewSession() {
        let title = newSessionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        
        let session = ChatSession(title: title)
        modelContext.insert(session)
        
        do {
            try modelContext.save()
            selectedSession = session
            showingNewSessionDialog = false
            newSessionTitle = ""
        } catch {
            print("Failed to create new session: \(error)")
        }
    }
    
    private func deleteSession(_ session: ChatSession) {
        modelContext.delete(session)
        
        do {
            try modelContext.save()
            if selectedSession?.id == session.id {
                selectedSession = nil
            }
        } catch {
            print("Failed to delete session: \(error)")
        }
    }
    
    private func exportSession(_ session: ChatSession) {
        Task {
            do {
                let messages = session.messages.sorted { $0.timestamp < $1.timestamp }
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
    
    private func handleChatFileUpload(_ result: Result<[URL], Error>) {
        guard let session = selectedSession else {
            print("❌ No session selected for file upload")
            return
        }
        
        switch result {
        case .success(let urls):
            Task { @MainActor in
                // Ensure session is saved to database before processing documents
                do {
                    try modelContext.save()
                } catch {
                    print("❌ Failed to save session: \(error)")
                    return
                }
                
                // Capture ModelContext on main actor to avoid Sendable warning
                nonisolated(unsafe) let context = modelContext
                
                var successCount = 0
                var errorMessages: [String] = []
                
                for url in urls {
                    do {
                        let chatDocument = try await documentService.processDocument(
                            fileURL: url,
                            fileName: url.lastPathComponent,
                            sessionId: session.id,
                            context: context
                        )
                        
                        // Ensure document is associated with session
                        if chatDocument.session == nil {
                            chatDocument.session = session
                            print("🔗 Manually associated document with session")
                        }
                        
                        // Save context to persist the relationship
                        try context.save()
                        print("💾 Context saved after document processing")
                        
                        // Verify document is in session
                        let sessionDocuments = session.documents
                        if sessionDocuments.contains(where: { $0.id == chatDocument.id }) {
                            print("✅ Document confirmed in session.documents: \(chatDocument.fileName)")
                        } else {
                            print("⚠️ Document not found in session.documents - forcing refresh")
                            // Force refresh by accessing the relationship
                            _ = session.documents
                            try context.save()
                        }
                        
                        successCount += 1
                        print("✅ Successfully uploaded: \(url.lastPathComponent)")
                    } catch {
                        let errorMsg = "Failed to process \(url.lastPathComponent): \(error.localizedDescription)"
                        print("❌ \(errorMsg)")
                        errorMessages.append(errorMsg)
                    }
                }
                
                // Final save to ensure everything is persisted
                try context.save()
                print("💾 Final context save completed")
                
                if !errorMessages.isEmpty {
                    print("⚠️ Upload completed with errors: \(errorMessages.joined(separator: ", "))")
                } else {
                    print("✅ All \(successCount) file(s) uploaded successfully")
                    print("📄 Session now has \(session.documents.count) document(s)")
                }
            }
        case .failure(let error):
            print("❌ File upload failed: \(error.localizedDescription)")
        }
    }
    
    private func handleDocumentImport(_ result: Result<[URL], Error>) {
        guard let session = selectedSession else { return }
        
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            Task { @MainActor in
                // Capture ModelContext on main actor to avoid Sendable warning
                nonisolated(unsafe) let context = modelContext
                do {
                    // Note: ModelContext Sendable warning is expected with SwiftData
                    // This is safe in this context as we're on the main actor
                    _ = try await documentService.processDocument(
                        fileURL: url,
                        fileName: url.lastPathComponent,
                        sessionId: session.id,
                        context: context
                    )
                } catch {
                    print("Failed to process document: \(error)")
                }
            }
            
        case .failure(let error):
            print("Document import failed: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct SessionRowView: View {
    let session: ChatSession
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(formatDate(session.lastMessageAt))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                if let veteran = session.associatedVeteran {
                    Text("Veteran: \(veteran.fullName)")
                        .font(.system(size: 11))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("\(session.messageCount)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.regularMaterial, in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TemplateRowView: View {
    let template: PromptTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: template.category.icon)
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                
                Text(template.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(template.templateDescription)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
    }
}

struct CopilotInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    CopilotView()
        .modelContainer(for: [ChatSession.self, ChatMessage.self, ChatDocument.self, PromptTemplate.self], inMemory: true)
}
