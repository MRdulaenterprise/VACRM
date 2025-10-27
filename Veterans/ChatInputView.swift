//
//  ChatInputView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Input view for chat messages with attachments and prompt selection
struct ChatInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var messageText: String
    @Binding var selectedTemplate: PromptTemplate?
    @Binding var attachedDocuments: [ChatDocument]
    let onSendMessage: () -> Void
    let onAttachDocument: () -> Void
    
    @State private var isExpanded = false
    @State private var showingTemplatePicker = false
    @State private var characterCount = 0
    @State private var showingPHIWarning = false
    
    @Query private var templates: [PromptTemplate]
    
    private let maxCharacters = 4000
    private let deidentificationService = DeIdentificationService()
    
    var body: some View {
        VStack(spacing: 12) {
            // PHI Warning
            if showingPHIWarning {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Personal information detected. Content will be de-identified before sending.")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                    Button("Dismiss") {
                        showingPHIWarning = false
                    }
                    .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Attached Documents
            if !attachedDocuments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(attachedDocuments) { document in
                            DocumentAttachmentView(document: document) {
                                removeDocument(document)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Main Input Area
            VStack(spacing: 8) {
                // Template Selector
                if !templates.isEmpty {
                    HStack {
                        Button(action: { showingTemplatePicker = true }) {
                            HStack {
                                Image(systemName: "text.badge.plus")
                                Text(selectedTemplate?.name ?? "Select Template")
                                    .font(.caption)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        
                        if selectedTemplate != nil {
                            Button(action: { selectedTemplate = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                    }
                }
                
                // Text Input
                HStack(alignment: .bottom, spacing: 12) {
                    // Text Field
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(NSColor.controlBackgroundColor))
                                .frame(minHeight: 44, maxHeight: 120)
                            
                            TextEditor(text: $messageText)
                                .padding(8)
                                .background(Color.clear)
                                .scrollContentBackground(.hidden)
                                .onChange(of: messageText) { _, newValue in
                                    characterCount = newValue.count
                                    checkForPHI(newValue)
                                }
                            
                            if messageText.isEmpty {
                                Text("Type your message...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        // Character Count
                        HStack {
                            Spacer()
                            Text("\(characterCount)/\(maxCharacters)")
                                .font(.caption2)
                                .foregroundColor(characterCount > maxCharacters ? .red : .secondary)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 8) {
                        // Attach Document Button
                        Button(action: onAttachDocument) {
                            Image(systemName: "paperclip")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help("Attach Document")
                        
                        // Send Button
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(canSend ? .accentColor : .secondary)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canSend)
                        .help("Send Message")
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .sheet(isPresented: $showingTemplatePicker) {
            ChatTemplatePickerView(selectedTemplate: $selectedTemplate)
        }
    }
    
    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        characterCount <= maxCharacters &&
        (!messageText.isEmpty || !attachedDocuments.isEmpty)
    }
    
    private func sendMessage() {
        guard canSend else { return }
        onSendMessage()
    }
    
    private func removeDocument(_ document: ChatDocument) {
        attachedDocuments.removeAll { $0.id == document.id }
    }
    
    private func checkForPHI(_ text: String) {
        let containsPHI = deidentificationService.containsPHI(text)
        showingPHIWarning = containsPHI
    }
}

/// Document attachment view
struct DocumentAttachmentView: View {
    let document: ChatDocument
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: documentIcon)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(document.fileName)
                    .font(.caption)
                    .lineLimit(1)
                
                Text(document.fileSizeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var documentIcon: String {
        switch document.fileType.lowercased() {
        case "pdf":
            return "doc.text.fill"
        case "doc", "docx":
            return "doc.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        case "txt":
            return "doc.plaintext.fill"
        default:
            return "doc.fill"
        }
    }
}

/// Template picker view for ChatInputView
struct ChatTemplatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTemplate: PromptTemplate?
    
    @Query private var templates: [PromptTemplate]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { selectedTemplate = nil; dismiss() }) {
                        HStack {
                            Text("No Template")
                            Spacer()
                            if selectedTemplate == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                ForEach(templates) { template in
                    Button(action: { selectedTemplate = template; dismiss() }) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(template.name)
                                    .font(.headline)
                                Spacer()
                                if selectedTemplate?.id == template.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            
                            Text(template.templateDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Select Template")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChatInputView(
        messageText: .constant(""),
        selectedTemplate: .constant(nil),
        attachedDocuments: .constant([]),
        onSendMessage: {},
        onAttachDocument: {}
    )
    .modelContainer(for: [PromptTemplate.self, ChatDocument.self])
}
