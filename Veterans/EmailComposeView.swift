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
            
            Button("Add Attachment") {
                showingFilePicker = true
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
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    do {
                        let data = try Data(contentsOf: url)
                        let attachment = EmailAttachment(
                            fileName: url.lastPathComponent,
                            contentType: url.pathExtension.lowercased() == "pdf" ? "application/pdf" : "application/octet-stream",
                            data: data
                        )
                        attachments.append(attachment)
                    } catch {
                        print("Error loading file: \(error)")
                    }
                }
            case .failure(let error):
                print("File picker error: \(error)")
            }
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

// MARK: - Preview
struct EmailComposeView_Previews: PreviewProvider {
    static var previews: some View {
        Text("EmailComposeView Preview")
    }
}