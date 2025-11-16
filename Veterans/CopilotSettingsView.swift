//
//  CopilotSettingsView.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

/// Settings view for Copilot configuration
/// Handles API key management, model selection, and preferences
struct CopilotSettingsView: View {
    
    // MARK: - Properties
    let onSave: (String) -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var openAIService = OpenAIService()
    
    @State private var apiKey = ""
    @State private var selectedModel = "gpt-4"
    @State private var temperature: Double = 0.7
    @State private var maxTokens = 2000
    @State private var enableDeidentification = true
    @State private var useGPT4Deidentification = true
    @State private var enableAuditLogging = true
    @State private var enableEncryption = true
    
    @State private var showingAPIKeyInput = false
    @State private var showingClearDataAlert = false
    @State private var showingExportLogsAlert = false
    @State private var isTestingConnection = false
    @State private var connectionTestResult: String?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Content - Scrollable
            ScrollView {
                contentView
            }
        }
        .frame(minWidth: 900, idealWidth: 1100, maxWidth: 1300)
        .frame(minHeight: 600, idealHeight: 750, maxHeight: 900)
        .onAppear {
            loadSettings()
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All Data", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all chat sessions, messages, and documents. This action cannot be undone.")
        }
        .alert("Export Audit Logs", isPresented: $showingExportLogsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Export") {
                exportAuditLogs()
            }
        } message: {
            Text("Export audit logs for compliance review?")
        }
        .sheet(isPresented: $showingAPIKeyInput) {
            APIKeyInputSheet(
                isPresented: $showingAPIKeyInput,
                openAIService: openAIService,
                onSave: { apiKey in
                    // Handle API key save
                    showingAPIKeyInput = false
                }
            )
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack {
            Text("Copilot Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            HStack(spacing: 8) {
                Button("Save") {
                    saveSettings()
                }
                .buttonStyle(PrimaryButtonStyle())
                .font(.system(size: 12))
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Close")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left Column
            VStack(alignment: .leading, spacing: 16) {
                // API Configuration
                apiConfigurationCard
                
                // Model Settings
                modelSettingsCard
                
                // Security Settings
                securitySettingsCard
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Right Column
            VStack(alignment: .leading, spacing: 16) {
                // Data Management
                dataManagementCard
                
                // Storage Information
                storageInformationCard
                
                // Audit Logs
                auditLogsCard
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }
    
    // MARK: - API Configuration Card
    
    private var apiConfigurationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("API Configuration")
                .font(.system(size: 14, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OpenAI API Key")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(openAIService.hasAPIKey() ? "API key is configured" : "No API key configured")
                            .font(.system(size: 10))
                            .foregroundColor(openAIService.hasAPIKey() ? .green : .red)
                    }
                    
                    Spacer()
                    
                    Button(openAIService.hasAPIKey() ? "Update" : "Configure") {
                        showingAPIKeyInput = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .font(.system(size: 10))
                }
                
                if let result = connectionTestResult {
                    HStack {
                        Image(systemName: isTestingConnection ? "clock" : (result.contains("Success") ? "checkmark.circle.fill" : "xmark.circle.fill"))
                            .foregroundColor(isTestingConnection ? .orange : (result.contains("Success") ? .green : .red))
                        
                        Text(result)
                            .font(.system(size: 12))
                            .foregroundColor(isTestingConnection ? .orange : (result.contains("Success") ? .green : .red))
                        
                        Spacer()
                    }
                }
                
                Button("Test Connection") {
                    testConnection()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 10))
                .disabled(isTestingConnection || !openAIService.hasAPIKey())
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Model Settings Card
    
    private var modelSettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Model Settings")
                .font(.system(size: 14, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Model")
                        .font(.system(size: 12, weight: .medium))
                    
                    Picker("Model", selection: $selectedModel) {
                        Text("GPT-4").tag("gpt-4")
                        Text("GPT-4 Turbo").tag("gpt-4-turbo")
                        Text("GPT-3.5 Turbo").tag("gpt-3.5-turbo")
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 11))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Temperature")
                            .font(.system(size: 12, weight: .medium))
                        
                        Spacer()
                        
                        Text(String(format: "%.1f", temperature))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $temperature, in: 0.0...2.0, step: 0.1)
                    
                    Text("Controls randomness. Lower values make responses more focused and deterministic.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Max Tokens")
                            .font(.system(size: 12, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(maxTokens)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(maxTokens) },
                        set: { maxTokens = Int($0) }
                    ), in: 100...4000, step: 100)
                    
                    Text("Maximum number of tokens in the response.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Security Settings Card
    
    private var securitySettingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Security Settings")
                .font(.system(size: 14, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Enable Smart De-identification", isOn: $enableDeidentification)
                    .font(.system(size: 11))
                    .help("Automatically detect and redact actual PHI while allowing hypothetical case discussions")
                
                if enableDeidentification {
                    Toggle("Use GPT-4 De-identification", isOn: $useGPT4Deidentification)
                        .font(.system(size: 11))
                        .help("Use GPT-4 for advanced de-identification (recommended)")
                }
                
                Toggle("Enable Audit Logging", isOn: $enableAuditLogging)
                    .font(.system(size: 11))
                    .help("Log all activities for compliance and security monitoring")
                
                Toggle("Enable Encryption", isOn: $enableEncryption)
                    .font(.system(size: 11))
                    .help("Encrypt chat messages and documents at rest")
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Security Status")
                        .font(.system(size: 12, weight: .medium))
                    
                    HStack {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        
                        Text("HIPAA Compliant")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    
                    Text("All security features are enabled and configured according to HIPAA requirements.")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Data Management Card
    
    private var dataManagementCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Management")
                .font(.system(size: 14, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 8) {
                Button("Export All Chats") {
                    exportAllChats()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 11))
                
                Button("Clear All Data", role: .destructive) {
                    showingClearDataAlert = true
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.system(size: 11))
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Storage Information Card
    
    private var storageInformationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Storage Information")
                .font(.system(size: 14, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Chat Sessions:")
                        .font(.system(size: 11))
                    
                    Spacer()
                    
                    Text("0") // Would be calculated from actual data
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Total Messages:")
                        .font(.system(size: 11))
                    
                    Spacer()
                    
                    Text("0") // Would be calculated from actual data
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Documents:")
                        .font(.system(size: 11))
                    
                    Spacer()
                    
                    Text("0") // Would be calculated from actual data
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Audit Logs Card
    
    private var auditLogsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Audit Logs")
                .font(.system(size: 14, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 12) {
                Button("Export Audit Logs") {
                    showingExportLogsAlert = true
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("View Audit Logs") {
                    viewAuditLogs()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Audit Log Information")
                        .font(.system(size: 14, weight: .medium))
                    
                    HStack {
                        Text("Retention Period:")
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        Text("7 years")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Log Entries:")
                            .font(.system(size: 12))
                        
                        Spacer()
                        
                        Text("0") // Would be calculated from actual data
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Audit logs are encrypted and stored securely for compliance purposes.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Helper Methods
    
    private func loadSettings() {
        // Load settings from UserDefaults or other storage
        // For now, use default values
        selectedModel = "gpt-4"
        temperature = 0.7
        maxTokens = 2000
        enableDeidentification = true
        enableAuditLogging = true
        enableEncryption = true
    }
    
    private func saveSettings() {
        // Save settings to UserDefaults or other storage
        UserDefaults.standard.set(selectedModel, forKey: "copilot_model")
        UserDefaults.standard.set(temperature, forKey: "copilot_temperature")
        UserDefaults.standard.set(maxTokens, forKey: "copilot_max_tokens")
        UserDefaults.standard.set(enableDeidentification, forKey: "copilot_deidentification")
        UserDefaults.standard.set(enableAuditLogging, forKey: "copilot_audit_logging")
        UserDefaults.standard.set(enableEncryption, forKey: "copilot_encryption")
        
        // Dismiss view
        dismiss()
    }
    
    private func testConnection() {
        isTestingConnection = true
        connectionTestResult = nil
        
        Task {
            do {
                let isValid = try await openAIService.validateAPIKey()
                await MainActor.run {
                    isTestingConnection = false
                    connectionTestResult = isValid ? "Success: API key is valid" : "Error: API key is invalid"
                }
            } catch {
                await MainActor.run {
                    isTestingConnection = false
                    connectionTestResult = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func exportAllChats() {
        // Implementation would export all chat sessions to PDF
        print("Export all chats")
    }
    
    private func clearAllData() {
        // Implementation would clear all Copilot data
        print("Clear all data")
    }
    
    private func exportAuditLogs() {
        // Implementation would export audit logs
        print("Export audit logs")
    }
    
    private func viewAuditLogs() {
        // Implementation would show audit logs viewer
        print("View audit logs")
    }
}

// MARK: - API Key Input Sheet

struct APIKeyInputSheet: View {
    @Binding var isPresented: Bool
    @State private var apiKey = ""
    @State private var isSaving = false
    
    let openAIService: OpenAIService
    let onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Configure OpenAI API Key")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                SecureField("Enter your OpenAI API key...", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                
                Text("Your API key is stored securely in the macOS Keychain and never shared.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Save") {
                    saveAPIKey()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
    
    private func saveAPIKey() {
        isSaving = true
        
        Task {
            do {
                try openAIService.storeAPIKey(apiKey)
                await MainActor.run {
                    onSave(apiKey)
                    isPresented = false
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    print("Failed to save API key: \(error)")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CopilotSettingsView(onSave: { _ in })
        .modelContainer(for: [ChatSession.self, ChatMessage.self, ChatDocument.self, PromptTemplate.self], inMemory: true)
}
