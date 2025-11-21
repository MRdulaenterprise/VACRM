//
//  ExportView.swift
//  Veterans
//
//  Created for Import/Export Feature
//

import SwiftUI
import SwiftData
import AppKit

struct ExportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allVeterans: [Veteran]
    
    @StateObject private var exportService = DataExportService()
    @State private var selectedVeteranIds: Set<UUID> = []
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var exportComplete = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
        }
        .frame(minWidth: 700, idealWidth: 800, maxWidth: 1000)
        .frame(minHeight: 500, idealHeight: 600, maxHeight: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .alert("Export Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Export Complete", isPresented: $exportComplete) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Export completed successfully!")
        }
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Export Data")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select veterans to export")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .disabled(exportService.isExporting)
                
                Button("Export") {
                    startExport()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canExport || exportService.isExporting)
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .fill(.primary.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Veteran Selection
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Select Veterans")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                        
                        Button(action: selectAll) {
                            Text("Select All")
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.borderless)
                        
                        Button(action: deselectAll) {
                            Text("Deselect All")
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    if allVeterans.isEmpty {
                        Text("No veterans found")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(allVeterans) { veteran in
                                VeteranSelectionRow(
                                    veteran: veteran,
                                    isSelected: selectedVeteranIds.contains(veteran.id)
                                ) {
                                    toggleSelection(veteran.id)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Password Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Encryption Password")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        SecureField("Enter password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Confirm password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                        
                        if !password.isEmpty && password != confirmPassword {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Progress Section
                if exportService.isExporting {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(exportService.currentStep)
                            .font(.system(size: 14, weight: .medium))
                        
                        ProgressView(value: exportService.exportProgress)
                            .progressViewStyle(.linear)
                        
                        Text("\(Int(exportService.exportProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
        }
    }
    
    private var canExport: Bool {
        !selectedVeteranIds.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter
    }
    
    private func selectAll() {
        selectedVeteranIds = Set(allVeterans.map { $0.id })
    }
    
    private func deselectAll() {
        selectedVeteranIds.removeAll()
    }
    
    private func toggleSelection(_ id: UUID) {
        if selectedVeteranIds.contains(id) {
            selectedVeteranIds.remove(id)
        } else {
            selectedVeteranIds.insert(id)
        }
    }
    
    private func startExport() {
        guard canExport else { return }
        
        // Show save panel
        let savePanel = NSSavePanel()
        savePanel.title = "Export Veterans Data"
        savePanel.allowedContentTypes = [.zip]
        savePanel.nameFieldStringValue = "VeteransExport_\(dateFormatter.string(from: Date())).zip"
        savePanel.canCreateDirectories = true
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                Task {
                    await performExport(to: url)
                }
            }
        }
    }
    
    private func performExport(to url: URL) async {
        let selectedVeterans = allVeterans.filter { selectedVeteranIds.contains($0.id) }
        
        do {
            _ = try await exportService.exportSelectedVeterans(
                veterans: selectedVeterans,
                exportedBy: NSUserName(), // Or get actual user name
                password: password,
                to: url,
                context: modelContext
            )
            
            // Log export activity
            LoggingManager.shared.logDataExported(
                veteranCount: selectedVeterans.count,
                exportedBy: NSUserName(),
                modelContext: modelContext
            )
            
            await MainActor.run {
                exportComplete = true
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// MARK: - Veteran Selection Row
struct VeteranSelectionRow: View {
    let veteran: Veteran
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(veteran.fullName)
                    .font(.system(size: 15, weight: .medium))
                
                Text("\(veteran.claims.count) claims, \(veteran.documents.count) documents")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

