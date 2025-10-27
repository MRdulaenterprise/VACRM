import SwiftUI
import Security

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Variables
    // PaulBox Settings
    @State private var paulBoxAPIKey: String = ""
    @State private var fromEmail: String = "matt@mrdula.co"
    @State private var domain: String = "mrdula.co"
    @State private var enableNotifications: Bool = true
    @State private var enableClaimNotifications: Bool = true
    @State private var enableDocumentNotifications: Bool = true
    @State private var enableActivityNotifications: Bool = true
    @State private var showPaulBoxAPIKeyAlert: Bool = false
    @State private var newPaulBoxAPIKey: String = ""
    @State private var paulBoxTestConnectionStatus: ConnectionStatus = .idle
    
    // OpenAI Settings
    @StateObject private var openAIService = OpenAIService()
    @State private var showOpenAIAPIKeyAlert: Bool = false
    @State private var newOpenAIAPIKey: String = ""
    @State private var openAITestConnectionStatus: ConnectionStatus = .idle
    @State private var openAISaveStatus: String = ""
    
    // VA.GOV Settings
    @StateObject private var vaGovService = VAGovAPIService()
    @State private var showVAGovAPIKeyAlert: Bool = false
    @State private var newVAGovAPIKey: String = ""
    @State private var vaGovEnvironment: String = "sandbox"
    @State private var vaGovTestConnectionStatus: ConnectionStatus = .idle
    @State private var vaGovSaveStatus: String = ""
    
    enum ConnectionStatus {
        case idle, testing, success, failure
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    saveSettings()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - OpenAI API Configuration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("OpenAI API Configuration")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("API Key")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Change") {
                                    openAISaveStatus = ""
                                    showOpenAIAPIKeyAlert = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            
                            HStack {
                                Text("Status:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(openAIService.hasAPIKey() ? "Configured" : "Not configured")
                                    .font(.caption)
                                    .foregroundColor(openAIService.hasAPIKey() ? .green : .orange)
                                
                                Spacer()
                                
                                Image(systemName: openAIService.hasAPIKey() ? "checkmark.circle.fill" : "exclamationmark.triangle")
                                    .foregroundColor(openAIService.hasAPIKey() ? .green : .orange)
                            }
                            
                            if !openAISaveStatus.isEmpty {
                                Text(openAISaveStatus)
                                    .font(.caption)
                                    .foregroundColor(openAISaveStatus.contains("Error") ? .red : .green)
                            }
                        }
                        
                        // OpenAI Connection Test
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connection Test")
                                .font(.headline)
                            
                            HStack {
                                Button("Test Connection") {
                                    testOpenAIConnection()
                                }
                                .buttonStyle(.bordered)
                                .disabled(openAITestConnectionStatus == .testing || !openAIService.hasAPIKey())
                                
                                Spacer()
                                
                                if openAITestConnectionStatus == .testing {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: openAITestConnectionStatus == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(openAITestConnectionStatus == .success ? .green : .red)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // MARK: - PaulBox API Configuration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PaulBox API Configuration")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("API Key")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Change") {
                                    showPaulBoxAPIKeyAlert = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            
                            HStack {
                                Text("Status:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(paulBoxAPIKey.isEmpty ? "Not configured" : "Configured")
                                    .font(.caption)
                                    .foregroundColor(paulBoxAPIKey.isEmpty ? .orange : .green)
                                
                                Spacer()
                                
                                Image(systemName: paulBoxAPIKey.isEmpty ? "exclamationmark.triangle" : "checkmark.circle.fill")
                                    .foregroundColor(paulBoxAPIKey.isEmpty ? .orange : .green)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("From Email Address")
                                .font(.headline)
                            
                            TextField("Enter your from email address", text: $fromEmail)
                                .textFieldStyle(.modern)
                                .disableAutocorrection(true)
                                .onChange(of: fromEmail) { _, newValue in
                                    saveFromEmail(newValue)
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Domain")
                                .font(.headline)
                            
                            TextField("Domain", text: $domain)
                                .textFieldStyle(.modern)
                                .disableAutocorrection(true)
                        }
                    }
                    
                        // PaulBox Connection Test
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connection Test")
                                .font(.headline)
                            
                            HStack {
                                Button("Test Connection") {
                                    testPaulBoxConnection()
                                }
                                .buttonStyle(.bordered)
                                .disabled(paulBoxTestConnectionStatus == .testing)
                                
                                Spacer()
                                
                                if paulBoxTestConnectionStatus == .testing {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: paulBoxTestConnectionStatus == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(paulBoxTestConnectionStatus == .success ? .green : .red)
                                }
                            }
                        }
                    
                    // MARK: - Notification Settings
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Email Notifications")
                            .font(.headline)
                        
                        Toggle("Enable Email Notifications", isOn: $enableNotifications)
                            .toggleStyle(.switch)
                        
                        if enableNotifications {
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle("Claim Notifications", isOn: $enableClaimNotifications)
                                    .toggleStyle(.switch)
                                
                                Toggle("Document Notifications", isOn: $enableDocumentNotifications)
                                    .toggleStyle(.switch)
                                
                                Toggle("Activity Notifications", isOn: $enableActivityNotifications)
                                    .toggleStyle(.switch)
                            }
                            .padding(.leading, 20)
                        }
                    }
                    
                    // MARK: - Current Configuration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Configuration")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("API Endpoint:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("https://api.paubox.net/v1/mrdula")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("Domain:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(domain)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("From Email:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(fromEmail)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("API Key:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(paulBoxAPIKey.isEmpty ? "Not configured" : "Configured")
                                    .font(.caption)
                                    .foregroundColor(paulBoxAPIKey.isEmpty ? .orange : .green)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // MARK: - VA.GOV API Configuration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("VA.GOV API Configuration")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("API Key")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button("Change") {
                                    vaGovSaveStatus = ""
                                    showVAGovAPIKeyAlert = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            
                            HStack {
                                Text("Status:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(vaGovService.hasAPIKey() ? "Configured" : "Not configured")
                                    .font(.caption)
                                    .foregroundColor(vaGovService.hasAPIKey() ? .green : .orange)
                                
                                Spacer()
                                
                                Image(systemName: vaGovService.hasAPIKey() ? "checkmark.circle.fill" : "exclamationmark.triangle")
                                    .foregroundColor(vaGovService.hasAPIKey() ? .green : .orange)
                            }
                            
                            if !vaGovSaveStatus.isEmpty {
                                Text(vaGovSaveStatus)
                                    .font(.caption)
                                    .foregroundColor(vaGovSaveStatus.contains("Error") ? .red : .green)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Environment")
                                .font(.headline)
                            
                            Picker("Environment", selection: $vaGovEnvironment) {
                                Text("Sandbox").tag("sandbox")
                                Text("Production").tag("production")
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: vaGovEnvironment) { _, newValue in
                                let environment = VAGovAPIService.Environment(rawValue: newValue) ?? .sandbox
                                vaGovService.setEnvironment(environment)
                            }
                        }
                        
                        // VA.GOV Connection Test
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connection Test")
                                .font(.headline)
                            
                            HStack {
                                Button("Test Connection") {
                                    testVAGovConnection()
                                }
                                .buttonStyle(.bordered)
                                .disabled(vaGovTestConnectionStatus == .testing || !vaGovService.hasAPIKey())
                                
                                Spacer()
                                
                                if vaGovTestConnectionStatus == .testing {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: vaGovTestConnectionStatus == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(vaGovTestConnectionStatus == .success ? .green : .red)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Configuration Details")
                                .font(.headline)
                            
                            HStack {
                                Text("Environment:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(vaGovEnvironment == "sandbox" ? "Sandbox" : "Production")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("Base URL:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(vaGovEnvironment == "sandbox" ? "https://sandbox-api.va.gov" : "https://api.va.gov")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("API Key:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(vaGovService.hasAPIKey() ? "Configured" : "Not configured")
                                    .font(.caption)
                                    .foregroundColor(vaGovService.hasAPIKey() ? .green : .orange)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                    
                    // MARK: - Usage Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Usage Information")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Email notifications are sent automatically when:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("• New veterans are added")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("• Claims are created or updated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("• Documents are uploaded")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // MARK: - HIPAA Compliance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HIPAA Compliance")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("This email integration is HIPAA-compliant:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("• End-to-end encryption")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("• Secure data transmission")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("• Audit trail logging")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Change OpenAI API Key", isPresented: $showOpenAIAPIKeyAlert) {
            SecureField("New OpenAI API Key", text: $newOpenAIAPIKey)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                saveOpenAIAPIKey()
            }
        } message: {
            Text("Enter your new OpenAI API key. This will be stored securely in the macOS Keychain.")
        }
        .alert("Change PaulBox API Key", isPresented: $showPaulBoxAPIKeyAlert) {
            SecureField("New PaulBox API Key", text: $newPaulBoxAPIKey)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                savePaulBoxAPIKey()
            }
        } message: {
            Text("Enter your new PaulBox API key. This will be stored securely in the macOS Keychain.")
        }
        .alert("Change VA.GOV API Key", isPresented: $showVAGovAPIKeyAlert) {
            SecureField("New VA.GOV API Key", text: $newVAGovAPIKey)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                saveVAGovAPIKey()
            }
        } message: {
            Text("Enter your new VA.GOV API key. This will be stored securely in the macOS Keychain.")
        }
            .onAppear {
                loadSettings()
            }
        }
        
        // MARK: - Helper Methods
        private func loadSettings() {
            // Load PaulBox API key from Keychain
            paulBoxAPIKey = loadPaulBoxAPIKeyFromKeychain()
            
            // Load VA.GOV environment
            vaGovEnvironment = UserDefaults.standard.string(forKey: "vaGovEnvironment") ?? "sandbox"
            let environment = VAGovAPIService.Environment(rawValue: vaGovEnvironment) ?? .sandbox
            vaGovService.setEnvironment(environment)
            
            // Load other settings from UserDefaults
            fromEmail = UserDefaults.standard.string(forKey: "emailFromAddress") ?? "matt@mrdula.co"
            domain = UserDefaults.standard.string(forKey: "emailDomain") ?? "mrdula.co"
            enableNotifications = UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
            enableClaimNotifications = UserDefaults.standard.bool(forKey: "emailClaimNotificationsEnabled")
            enableDocumentNotifications = UserDefaults.standard.bool(forKey: "emailDocumentNotificationsEnabled")
            enableActivityNotifications = UserDefaults.standard.bool(forKey: "emailActivityNotificationsEnabled")
        }
    
        private func saveSettings() {
            // Save settings to UserDefaults
            UserDefaults.standard.set(fromEmail, forKey: "emailFromAddress")
            UserDefaults.standard.set(domain, forKey: "emailDomain")
            UserDefaults.standard.set(vaGovEnvironment, forKey: "vaGovEnvironment")
            UserDefaults.standard.set(enableNotifications, forKey: "emailNotificationsEnabled")
            UserDefaults.standard.set(enableClaimNotifications, forKey: "emailClaimNotificationsEnabled")
            UserDefaults.standard.set(enableDocumentNotifications, forKey: "emailDocumentNotificationsEnabled")
            UserDefaults.standard.set(enableActivityNotifications, forKey: "emailActivityNotificationsEnabled")
            
            dismiss()
        }
    
        private func saveOpenAIAPIKey() {
            print("🔑 Attempting to save OpenAI API key...")
            print("🔑 Key length: \(newOpenAIAPIKey.count)")
            print("🔑 Key starts with: \(String(newOpenAIAPIKey.prefix(10)))...")
            
            guard !newOpenAIAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                openAISaveStatus = "Error: API key cannot be empty"
                print("❌ API key is empty")
                return
            }
            
            do {
                try openAIService.storeAPIKey(newOpenAIAPIKey)
                newOpenAIAPIKey = ""
                openAISaveStatus = "API key saved successfully"
                print("✅ OpenAI API key saved successfully")
            } catch {
                openAISaveStatus = "Error: Failed to save API key - \(error.localizedDescription)"
                print("❌ Failed to save OpenAI API key: \(error)")
            }
        }
    
        private func savePaulBoxAPIKey() {
            paulBoxAPIKey = newPaulBoxAPIKey
            _ = savePaulBoxAPIKeyToKeychain(paulBoxAPIKey)
            newPaulBoxAPIKey = ""
        }
    
        private func saveFromEmail(_ email: String) {
            UserDefaults.standard.set(email, forKey: "emailFromAddress")
        }
    
        private func testOpenAIConnection() {
            print("🧪 Testing OpenAI connection...")
            openAITestConnectionStatus = .testing
            
            Task.detached {
                do {
                    let isValid = try await openAIService.validateAPIKey()
                    
                    await MainActor.run {
                        openAITestConnectionStatus = isValid ? .success : .failure
                        print("🧪 OpenAI test result: \(isValid ? "SUCCESS" : "FAILURE")")
                    }
                } catch {
                    await MainActor.run {
                        openAITestConnectionStatus = .failure
                        print("❌ OpenAI test connection failed: \(error)")
                    }
                }
            }
        }
    
        private func testPaulBoxConnection() {
            paulBoxTestConnectionStatus = .testing
            
            Task.detached {
                do {
                    let emailService = PaulBoxEmailService()
                    let success = try await emailService.testConnection()
                    
                    await MainActor.run {
                        paulBoxTestConnectionStatus = success ? .success : .failure
                    }
                } catch {
                    await MainActor.run {
                        paulBoxTestConnectionStatus = .failure
                        print("PaulBox test connection failed: \(error)")
                    }
                }
            }
        }
    
        private func testVAGovConnection() {
            print("🧪 Testing VA.GOV connection...")
            vaGovTestConnectionStatus = .testing
            
            Task.detached {
                do {
                    let isValid = try await vaGovService.testConnection()
                    
                    await MainActor.run {
                        vaGovTestConnectionStatus = isValid ? .success : .failure
                        print("🧪 VA.GOV test result: \(isValid ? "SUCCESS" : "FAILURE")")
                    }
                } catch {
                    await MainActor.run {
                        vaGovTestConnectionStatus = .failure
                        print("❌ VA.GOV test connection failed: \(error)")
                    }
                }
            }
        }
    
        private func saveVAGovAPIKey() {
            guard !newVAGovAPIKey.isEmpty else {
                vaGovSaveStatus = "Error: API key cannot be empty"
                return
            }
            
            do {
                try vaGovService.storeAPIKey(newVAGovAPIKey)
                vaGovSaveStatus = "VA.GOV API key saved successfully"
                newVAGovAPIKey = ""
            } catch {
                vaGovSaveStatus = "Error saving VA.GOV API key: \(error.localizedDescription)"
            }
        }
    
        // MARK: - Keychain Methods
        private func loadPaulBoxAPIKeyFromKeychain() -> String {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "PaulBoxAPIKey",
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            if status == errSecSuccess,
               let data = result as? Data,
               let apiKey = String(data: data, encoding: .utf8) {
                return apiKey
            }
            
            return ""
        }
    
        private func savePaulBoxAPIKeyToKeychain(_ apiKey: String) -> Bool {
            // First, delete any existing item
            let deleteQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "PaulBoxAPIKey"
            ]
            SecItemDelete(deleteQuery as CFDictionary)
            
            // Then add the new item
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "PaulBoxAPIKey",
                kSecValueData as String: apiKey.data(using: .utf8)!
            ]
            
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
    }

// MARK: - Email Settings Manager
class EmailSettingsManager: ObservableObject {
    static let shared = EmailSettingsManager()
    
    @Published var isConfigured: Bool = false
    @Published var lastTestResult: Bool = false
    
    private init() {
        checkConfiguration()
    }
    
    func checkConfiguration() {
        let apiKey = UserDefaults.standard.string(forKey: "PaulBoxAPIKey") ?? ""
        isConfigured = !apiKey.isEmpty
    }
    
    func testConnection() async -> Bool {
        do {
            let emailService = PaulBoxEmailService()
            let _ = try await emailService.sendEmail(
                to: ["test@example.com"],
                subject: "Connection Test",
                htmlBody: "<p>This is a test email.</p>"
            )
            
            await MainActor.run {
                lastTestResult = true
            }
            return true
        } catch {
            await MainActor.run {
                lastTestResult = false
            }
            return false
        }
    }
    
    func shouldSendNotification(for type: EmailNotificationType) -> Bool {
        guard isConfigured else { return false }
        
        let enableNotifications = UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
        guard enableNotifications else { return false }
        
        switch type {
        case .veteranCreated:
            return UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
        case .claimCreated, .claimUpdated:
            return UserDefaults.standard.bool(forKey: "emailClaimNotificationsEnabled")
        case .documentUploaded:
            return UserDefaults.standard.bool(forKey: "emailDocumentNotificationsEnabled")
        case .activityLogged:
            return UserDefaults.standard.bool(forKey: "emailActivityNotificationsEnabled")
        case .teamAlert:
            return UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
        }
    }
}

// MARK: - Notification Types
enum EmailNotificationType: String, CaseIterable {
    case veteranCreated
    case claimCreated
    case claimUpdated
    case documentUploaded
    case activityLogged
    case teamAlert
}

// MARK: - Preview
#Preview {
    SettingsView()
}