import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct EmailComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Properties
    let veteran: Veteran?
    
    // MARK: - State Variables
    @State private var selectedTemplate: EmailTemplate?
    @State private var selectedVeterans: [Veteran] = []
    @State private var selectedTeamMembers: [String] = []
    @State private var manualEmails: String = ""
    @State private var subject: String = ""
    @State private var emailBody: String = ""
    @State private var attachments: [EmailAttachment] = []
    @State private var showingFilePicker = false
    @State private var showingDocumentSelector = false
    @State private var isLoading: Bool = false
    
    // MARK: - Initializer
    init(veteran: Veteran? = nil) {
        self.veteran = veteran
    }
    
    // MARK: - Computed Properties
    private var availableTemplates: [EmailTemplate] {
        EmailTemplateManager.allTemplates
    }
    
    private var availableVeterans: [Veteran] {
        // TODO: Implement veteran fetching from modelContext
        []
    }
    
    private var availableTeamMembers: [String] {
        // TODO: Implement team member fetching
        []
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Compose Email")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    templateSelectionSection
                    recipientsSection
                    emailContentSection
                    attachmentsSection
                    sendSection
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.pdf, .image, .text, .data, .item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    handleFileUpload(url: url)
                }
            case .failure(let error):
                print("File picker error: \(error.localizedDescription)")
            }
        }
        .sheet(isPresented: $showingDocumentSelector) {
            EmailDocumentSelectorView(
                onDocumentSelected: { document in
                    handleDocumentSelection(document: document)
                }
            )
        }
        .onAppear {
            if let veteran = veteran {
                manualEmails = veteran.emailPrimary
            }
        }
    }
    
    // MARK: - Template Selection Section
    private var templateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email Template")
                .font(.headline)
            
            HStack {
                Text("Template:")
                    .font(.subheadline)
                
                Spacer()
                
                Menu {
                    Button("Custom Email") {
                        selectedTemplate = nil
                        subject = ""
                        emailBody = ""
                    }
                    
                    ForEach(availableTemplates, id: \.id) { template in
                        Button(template.name) {
                            selectedTemplate = template
                            // Populate the form with template content
                            subject = template.subject
                            emailBody = template.htmlBody
                        }
                    }
                } label: {
                    Text(selectedTemplate?.name ?? "Custom Email")
                        .foregroundColor(.primary)
                }
                .menuStyle(.borderlessButton)
            }
            
            if let template = selectedTemplate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Template: \(template.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(template.subject)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: - Recipients Section
    private var recipientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recipients")
                .font(.headline)
            
            // Veteran Selection
            DisclosureGroup("Select Veterans") {
                ForEach(availableVeterans, id: \.id) { veteran in
                    veteranSelectionRow(veteran)
                }
            }
            
            // Team Member Selection
            DisclosureGroup("Select Team Members") {
                ForEach(availableTeamMembers, id: \.self) { member in
                    teamMemberSelectionRow(member)
                }
            }
            
            // Manual Email Entry
            VStack(alignment: .leading, spacing: 8) {
                Text("Manual Email Addresses")
                    .font(.headline)
                
                TextField("Enter email addresses (comma-separated)", text: $manualEmails)
                    .textFieldStyle(.modern)
            }
        }
    }
    
    // MARK: - Email Content Section
    private var emailContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email Content")
                .font(.headline)
            
            TextField("Subject", text: $subject)
                .textFieldStyle(.modern)
            
            TextEditor(text: $emailBody)
                .frame(minHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Attachments Section
    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attachments")
                .font(.headline)
            
            Menu {
                Button("Upload New File") {
                    showingFilePicker = true
                }
                
                Button("Select from Documents") {
                    showingDocumentSelector = true
                }
            } label: {
                Label("Add Attachment", systemImage: "paperclip")
            }
            .buttonStyle(.bordered)
            
            if !attachments.isEmpty {
                ForEach(attachments.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: "paperclip")
                        VStack(alignment: .leading) {
                            Text(attachments[index].fileName)
                                .font(.subheadline)
                            Text(attachments[index].contentType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Remove") {
                            attachments.remove(at: index)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // MARK: - Attachment Helpers
    private func handleFileUpload(url: URL) {
        do {
            // Start accessing security-scoped resource (may not be needed for all files)
            let needsAccess = url.startAccessingSecurityScopedResource()
            defer {
                if needsAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let data = try Data(contentsOf: url)
            let contentType = getContentType(for: url.pathExtension)
            let attachment = EmailAttachment(
                fileName: url.lastPathComponent,
                contentType: contentType,
                data: data
            )
            attachments.append(attachment)
            print("Successfully attached file: \(url.lastPathComponent)")
        } catch {
            print("Error loading file: \(error.localizedDescription)")
        }
    }
    
    private func handleDocumentSelection(document: Document) {
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
            // Still try to read - might be accessible via security-scoped resource
        }
        
        do {
            // Start accessing security-scoped resource if needed
            let needsAccess = filePath.startAccessingSecurityScopedResource()
            defer {
                if needsAccess {
                    filePath.stopAccessingSecurityScopedResource()
                }
            }
            
            let data = try Data(contentsOf: filePath)
            let contentType = getContentType(for: document.fileType)
            let attachment = EmailAttachment(
                fileName: document.fileName,
                contentType: contentType,
                data: data
            )
            attachments.append(attachment)
        } catch {
            print("Error loading document: \(error.localizedDescription)")
        }
    }
    
    private func getContentType(for fileExtension: String) -> String {
        let ext = fileExtension.lowercased()
        switch ext {
        case "pdf":
            return "application/pdf"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "txt":
            return "text/plain"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls":
            return "application/vnd.ms-excel"
        case "xlsx":
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        default:
            return "application/octet-stream"
        }
    }
    
    // MARK: - Send Section
    private var sendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button("Send Email") {
                sendEmail()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || allRecipients.isEmpty)
            
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Sending email...")
                }
            }
        }
    }
    
    // MARK: - Helper Views
    private func veteranSelectionRow(_ veteran: Veteran) -> some View {
        HStack {
            Button(action: {
                toggleVeteranSelection(veteran)
            }) {
                HStack {
                    Image(systemName: selectedVeterans.contains(where: { $0.id == veteran.id }) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(veteran.fullName)
                            .font(.headline)
                        Text(veteran.emailPrimary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    private func teamMemberSelectionRow(_ member: String) -> some View {
        HStack {
            Button(action: {
                toggleTeamMemberSelection(member)
            }) {
                HStack {
                    Image(systemName: selectedTeamMembers.contains(member) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(member)
                            .font(.headline)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Helper Functions
    private func toggleVeteranSelection(_ veteran: Veteran) {
        if let index = selectedVeterans.firstIndex(where: { $0.id == veteran.id }) {
            selectedVeterans.remove(at: index)
        } else {
            selectedVeterans.append(veteran)
        }
    }
    
    private func toggleTeamMemberSelection(_ member: String) {
        if let index = selectedTeamMembers.firstIndex(of: member) {
            selectedTeamMembers.remove(at: index)
        } else {
            selectedTeamMembers.append(member)
        }
    }
    
    private var allRecipients: [String] {
        let veteranEmails = selectedVeterans.map { $0.emailPrimary }
        let teamEmails = selectedTeamMembers
        let manualEmailList = manualEmails.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return veteranEmails + teamEmails + manualEmailList
    }
    
    private func sendEmail() {
        guard !allRecipients.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let emailService = PaulBoxEmailService()
                let messageId = try await emailService.sendEmail(
                    to: allRecipients,
                    subject: subject,
                    htmlBody: emailBody,
                    attachments: attachments
                )
                
                await MainActor.run {
                    isLoading = false
                    print("Email sent successfully with message ID: \(messageId)")
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("Error sending email: \(error)")
                }
            }
        }
    }
}

// MARK: - Email Document Selector View

struct EmailDocumentSelectorView: View {
    let onDocumentSelected: (Document) -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var documents: [Document]
    @Query private var veterans: [Veteran]
    
    @State private var searchText = ""
    @State private var selectedVeteran: Veteran?
    
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
                    
                    Text("Choose a document to attach to this email")
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
                        Button("All Veterans") {
                            selectedVeteran = nil
                        }
                        
                        Divider()
                        
                        ForEach(veterans, id: \.id) { veteran in
                            Button(veteran.fullName) {
                                selectedVeteran = veteran
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                            Text(selectedVeteran?.fullName ?? "All Veterans")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            
            // Documents List
            if filteredDocuments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No documents found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if !searchText.isEmpty || selectedVeteran != nil {
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredDocuments, id: \.id) { document in
                            EmailDocumentRowView(document: document) {
                                onDocumentSelected(document)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - Email Document Row View

struct EmailDocumentRowView: View {
    let document: Document
    let onSelect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: documentIcon(for: document.fileType))
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fileName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        if let veteran = document.veteran {
                            Text(veteran.fullName)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(document.fileType.uppercased())
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(formatFileSize(document.fileSize))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isHovered ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isHovered ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func documentIcon(for fileType: String) -> String {
        let ext = fileType.lowercased()
        switch ext {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif":
            return "photo.fill"
        case "doc", "docx":
            return "doc.text.fill"
        case "xls", "xlsx":
            return "tablecells.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Preview
struct EmailComposeView_Previews: PreviewProvider {
    static var previews: some View {
        Text("EmailComposeView Preview")
    }
}