//
//  ImportView.swift
//  Veterans
//
//  Created for Import/Export Feature
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var importService = DataImportService()
    @State private var selectedFileURL: URL?
    @State private var password: String = ""
    @State private var conflictResolution: ImportConflictResolution = .skip
    @State private var showingFilePicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var importResult: ImportResult?
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
        }
        .frame(minWidth: 700, idealWidth: 800, maxWidth: 1000)
        .frame(minHeight: 500, idealHeight: 600, maxHeight: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.zip, .data],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .alert("Import Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingResult) {
            if let result = importResult {
                ImportResultView(result: result) {
                    dismiss()
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.down")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Import Data")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Import veteran data from file")
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
                .disabled(importService.isImporting)
                
                Button("Import") {
                    startImport()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canImport || importService.isImporting)
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
                // File Selection
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Select Import File")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    HStack(spacing: 12) {
                        if let fileURL = selectedFileURL {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fileURL.lastPathComponent)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(1)
                                
                                Text(fileURL.path)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Button("Change") {
                                showingFilePicker = true
                            }
                            .buttonStyle(.bordered)
                        } else {
                            Text("No file selected")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Choose File") {
                                showingFilePicker = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Password Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text("Decryption Password")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    SecureField("Enter password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Conflict Resolution
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.orange)
                        
                        Text("Conflict Resolution")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    
                    Text("How should conflicts be handled when importing records that already exist?")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Picker("Resolution", selection: $conflictResolution) {
                        Text("Skip").tag(ImportConflictResolution.skip)
                        Text("Replace").tag(ImportConflictResolution.replace)
                        Text("Merge").tag(ImportConflictResolution.merge)
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        conflictResolutionDescription
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                
                // Progress Section
                if importService.isImporting {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(importService.currentStep)
                            .font(.system(size: 14, weight: .medium))
                        
                        ProgressView(value: importService.importProgress)
                            .progressViewStyle(.linear)
                        
                        Text("\(Int(importService.importProgress * 100))%")
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
    
    private var conflictResolutionDescription: some View {
        Group {
            switch conflictResolution {
            case .skip:
                Text("Skip existing records and only import new ones.")
                    .font(.system(size: 12))
            case .replace:
                Text("Replace existing records with imported data.")
                    .font(.system(size: 12))
            case .merge:
                Text("Merge imported data with existing records.")
                    .font(.system(size: 12))
            }
        }
    }
    
    private var canImport: Bool {
        selectedFileURL != nil && !password.isEmpty
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                selectedFileURL = url
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func startImport() {
        guard let fileURL = selectedFileURL else { return }
        
        Task {
            await performImport(from: fileURL)
        }
    }
    
    private func performImport(from url: URL) async {
        do {
            let result = try await importService.importData(
                from: url,
                password: password,
                conflictResolution: conflictResolution,
                context: modelContext
            )
            
            // Log import activity
            LoggingManager.shared.logDataImported(
                veteranCount: result.veteransImported,
                claimCount: result.claimsImported,
                documentCount: result.documentsImported,
                importedBy: NSUserName(),
                modelContext: modelContext
            )
            
            await MainActor.run {
                importResult = result
                showingResult = true
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// MARK: - Import Result View
struct ImportResultView: View {
    let result: ImportResult
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Import Complete")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Done") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
            .background(.regularMaterial)
            .overlay(
                Rectangle()
                    .fill(.primary.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Import Summary")
                            .font(.system(size: 18, weight: .semibold))
                        
                        VStack(spacing: 12) {
                            SummaryRow(label: "Veterans", count: result.veteransImported)
                            SummaryRow(label: "Claims", count: result.claimsImported)
                            SummaryRow(label: "Documents", count: result.documentsImported)
                            SummaryRow(label: "Activities", count: result.activitiesImported)
                            SummaryRow(label: "Medical Conditions", count: result.medicalConditionsImported)
                        }
                    }
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Conflicts
                    if !result.conflicts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                
                                Text("Conflicts (\(result.conflicts.count))")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            ForEach(Array(result.conflicts.enumerated()), id: \.offset) { index, conflict in
                                ConflictRow(conflict: conflict)
                            }
                        }
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Errors
                    if !result.errors.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                
                                Text("Errors (\(result.errors.count))")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            ForEach(Array(result.errors.enumerated()), id: \.offset) { index, error in
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .padding(8)
                                    .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                            }
                        }
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(20)
            }
        }
        .frame(minWidth: 600, idealWidth: 700, maxWidth: 800)
        .frame(minHeight: 400, idealHeight: 500, maxHeight: 600)
    }
}

struct SummaryRow: View {
    let label: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(count)")
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .font(.system(size: 14))
    }
}

struct ConflictRow: View {
    let conflict: ImportConflict
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conflict.type.capitalized)
                .font(.system(size: 12, weight: .semibold))
            
            HStack {
                Text("Existing:")
                    .foregroundColor(.secondary)
                Text(conflict.existingRecord)
            }
            .font(.system(size: 11))
            
            HStack {
                Text("Imported:")
                    .foregroundColor(.secondary)
                Text(conflict.importedRecord)
            }
            .font(.system(size: 11))
        }
        .padding(8)
        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
    }
}

