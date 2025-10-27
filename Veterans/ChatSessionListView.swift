//
//  ChatSessionListView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Sidebar view for managing chat sessions
struct ChatSessionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatSession.lastMessageAt, order: .reverse) private var sessions: [ChatSession]
    @Binding var selectedSession: ChatSession?
    @State private var searchText = ""
    @State private var showingNewSession = false
    @State private var showingDeleteConfirmation = false
    @State private var sessionToDelete: ChatSession?
    
    var filteredSessions: [ChatSession] {
        if searchText.isEmpty {
            return sessions
        } else {
            return sessions.filter { session in
                session.title.localizedCaseInsensitiveContains(searchText) ||
                session.associatedVeteran?.firstName.localizedCaseInsensitiveContains(searchText) == true ||
                session.associatedVeteran?.lastName.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var groupedSessions: [(String, [ChatSession])] {
        let calendar = Calendar.current
        let now = Date()
        
        var groups: [(String, [ChatSession])] = []
        
        // Today
        let todaySessions = filteredSessions.filter { session in
            calendar.isDate(session.lastMessageAt, inSameDayAs: now)
        }
        if !todaySessions.isEmpty {
            groups.append(("Today", todaySessions))
        }
        
        // Yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let yesterdaySessions = filteredSessions.filter { session in
            calendar.isDate(session.lastMessageAt, inSameDayAs: yesterday)
        }
        if !yesterdaySessions.isEmpty {
            groups.append(("Yesterday", yesterdaySessions))
        }
        
        // This Week
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        let thisWeekSessions = filteredSessions.filter { session in
            session.lastMessageAt >= weekAgo && !calendar.isDate(session.lastMessageAt, inSameDayAs: now) && !calendar.isDate(session.lastMessageAt, inSameDayAs: yesterday)
        }
        if !thisWeekSessions.isEmpty {
            groups.append(("This Week", thisWeekSessions))
        }
        
        // Older
        let olderSessions = filteredSessions.filter { session in
            session.lastMessageAt < weekAgo
        }
        if !olderSessions.isEmpty {
            groups.append(("Older", olderSessions))
        }
        
        return groups
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Chat Sessions")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingNewSession = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            // Search
            SearchBar(text: $searchText)
                .padding(.horizontal)
            
            // Sessions List
            if groupedSessions.isEmpty {
                ContentUnavailableView(
                    "No Chat Sessions",
                    systemImage: "bubble.left.and.bubble.right",
                    description: Text("Start a new conversation to get help with Veterans Benefits claims.")
                )
            } else {
                List(selection: $selectedSession) {
                    ForEach(groupedSessions, id: \.0) { groupTitle, groupSessions in
                        Section(groupTitle) {
                            ForEach(groupSessions) { session in
                                ChatSessionRowView(
                                    session: session,
                                    isSelected: selectedSession?.id == session.id,
                                    onDelete: { sessionToDelete = session }
                                )
                                .tag(session)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .sheet(isPresented: $showingNewSession) {
            NewChatSessionView(selectedSession: $selectedSession)
        }
        .confirmationDialog(
            "Delete Chat Session",
            isPresented: $showingDeleteConfirmation,
            presenting: sessionToDelete
        ) { session in
            Button("Delete", role: .destructive) {
                deleteSession(session)
            }
        } message: { session in
            Text("Are you sure you want to delete '\(session.title)'? This action cannot be undone.")
        }
    }
    
    private func deleteSession(_ session: ChatSession) {
        modelContext.delete(session)
        try? modelContext.save()
        
        if selectedSession?.id == session.id {
            selectedSession = nil
        }
    }
}

/// Individual session row view
struct ChatSessionRowView: View {
    let session: ChatSession
    let isSelected: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Session Icon
            VStack {
                Image(systemName: session.isPinned ? "pin.fill" : "bubble.left.and.bubble.right.fill")
                    .font(.title2)
                    .foregroundColor(session.isPinned ? .orange : .accentColor)
                
                if session.associatedVeteran != nil {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .frame(width: 30)
            
            // Session Info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if let veteran = session.associatedVeteran {
                    Text("\(veteran.firstName) \(veteran.lastName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(session.lastMessageAt, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(session.messageCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            Menu {
                Button(action: { session.isPinned.toggle() }) {
                    Label(session.isPinned ? "Unpin" : "Pin", systemImage: session.isPinned ? "pin.slash" : "pin")
                }
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
    }
}

/// Search bar component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search sessions...", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

/// New chat session creation view
struct NewChatSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedSession: ChatSession?
    
    @State private var sessionTitle = ""
    @State private var selectedVeteran: Veteran?
    @State private var selectedTemplate: PromptTemplate?
    
    @Query private var veterans: [Veteran]
    @Query private var templates: [PromptTemplate]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Details") {
                    TextField("Session Title", text: $sessionTitle)
                    
                    Picker("Associate with Veteran", selection: $selectedVeteran) {
                        Text("None").tag(nil as Veteran?)
                        ForEach(veterans) { veteran in
                            Text("\(veteran.firstName) \(veteran.lastName)").tag(veteran as Veteran?)
                        }
                    }
                    
                    Picker("Prompt Template", selection: $selectedTemplate) {
                        Text("None").tag(nil as PromptTemplate?)
                        ForEach(templates) { template in
                            Text(template.name).tag(template as PromptTemplate?)
                        }
                    }
                }
                
                if let template = selectedTemplate {
                    Section("Template Preview") {
                            Text(template.templateDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Chat Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createSession()
                    }
                    .disabled(sessionTitle.isEmpty)
                }
            }
        }
    }
    
    private func createSession() {
        let newSession = ChatSession(
            title: sessionTitle,
            associatedVeteran: selectedVeteran,
            promptTemplate: selectedTemplate
        )
        
        modelContext.insert(newSession)
        try? modelContext.save()
        
        selectedSession = newSession
        dismiss()
    }
}

#Preview {
    ChatSessionListView(selectedSession: .constant(nil))
        .modelContainer(for: [ChatSession.self, Veteran.self, PromptTemplate.self])
}
