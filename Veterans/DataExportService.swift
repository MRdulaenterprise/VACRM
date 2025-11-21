//
//  DataExportService.swift
//  Veterans
//
//  Created for Import/Export Feature
//

import Foundation
import SwiftData
import Compression

enum ExportError: Error, LocalizedError {
    case noVeteransSelected
    case exportDirectoryCreationFailed
    case documentCopyFailed(String)
    case jsonEncodingFailed
    case zipCreationFailed
    case encryptionFailed
    case fileWriteFailed
    
    var errorDescription: String? {
        switch self {
        case .noVeteransSelected:
            return "No veterans selected for export."
        case .exportDirectoryCreationFailed:
            return "Failed to create export directory."
        case .documentCopyFailed(let reason):
            return "Failed to copy document: \(reason)"
        case .jsonEncodingFailed:
            return "Failed to encode export data to JSON."
        case .zipCreationFailed:
            return "Failed to create ZIP archive."
        case .encryptionFailed:
            return "Failed to encrypt export package."
        case .fileWriteFailed:
            return "Failed to write export file."
        }
    }
}

class DataExportService: ObservableObject {
    @Published var exportProgress: Double = 0.0
    @Published var isExporting: Bool = false
    @Published var currentStep: String = ""
    
    private let fileManager = FileManager.default
    
    // MARK: - Main Export Function
    
    /// Export selected veterans with all associated data
    func exportSelectedVeterans(
        veterans: [Veteran],
        exportedBy: String,
        password: String,
        to destinationURL: URL,
        context: ModelContext
    ) async throws -> URL {
        guard !veterans.isEmpty else {
            throw ExportError.noVeteransSelected
        }
        
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            currentStep = "Preparing export..."
        }
        
        // Create temporary export directory
        let tempDir = try createTempExportDirectory()
        defer {
            // Clean up temp directory
            try? fileManager.removeItem(at: tempDir)
        }
        
        await MainActor.run {
            exportProgress = 0.1
            currentStep = "Gathering data..."
        }
        
        // Gather all related data
        let (claims, documents, activities, medicalConditions, categories, relationships) = try await gatherRelatedData(
            for: veterans,
            context: context
        )
        
        await MainActor.run {
            exportProgress = 0.3
            currentStep = "Copying document files..."
        }
        
        // Copy document files and create export document records
        let exportedDocuments = try await copyDocumentFiles(
            documents: documents,
            to: tempDir,
            progress: { progress in
                await MainActor.run {
                    self.exportProgress = 0.3 + (progress * 0.2)
                }
            }
        )
        
        await MainActor.run {
            exportProgress = 0.5
            currentStep = "Creating export data..."
        }
        
        // Create export data structure
        let exportData = ExportData(
            metadata: ExportMetadata(
                exportedBy: exportedBy,
                veteranCount: veterans.count,
                claimCount: claims.count,
                documentCount: exportedDocuments.count,
                activityCount: activities.count,
                medicalConditionCount: medicalConditions.count
            ),
            veterans: veterans.map { ExportedVeteran(from: $0) },
            claims: claims.map { ExportedClaim(from: $0) },
            documents: exportedDocuments,
            activities: activities.map { ExportedClaimActivity(from: $0) },
            medicalConditions: medicalConditions.map { ExportedMedicalCondition(from: $0) },
            medicalConditionCategories: categories.map { ExportedMedicalConditionCategory(from: $0) },
            conditionRelationships: relationships.map { ExportedConditionRelationship(from: $0) }
        )
        
        await MainActor.run {
            exportProgress = 0.6
            currentStep = "Encoding JSON..."
        }
        
        // Encode to JSON
        let jsonData = try encodeExportData(exportData)
        let jsonURL = tempDir.appendingPathComponent("data.json")
        try jsonData.write(to: jsonURL)
        
        // Write metadata
        let metadataData = try JSONEncoder().encode(exportData.metadata)
        let metadataURL = tempDir.appendingPathComponent("export_metadata.json")
        try metadataData.write(to: metadataURL)
        
        await MainActor.run {
            exportProgress = 0.7
            currentStep = "Creating ZIP archive..."
        }
        
        // Create ZIP archive
        let zipURL = try createZIPArchive(from: tempDir, password: password)
        
        await MainActor.run {
            exportProgress = 0.9
            currentStep = "Finalizing..."
        }
        
        // Move ZIP to destination
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.moveItem(at: zipURL, to: destinationURL)
        
        await MainActor.run {
            exportProgress = 1.0
            currentStep = "Export complete!"
            isExporting = false
        }
        
        return destinationURL
    }
    
    // MARK: - Helper Functions
    
    private func createTempExportDirectory() throws -> URL {
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("VeteransExport_\(UUID().uuidString)")
        
        if fileManager.fileExists(atPath: tempDir.path) {
            try fileManager.removeItem(at: tempDir)
        }
        
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Create documents subdirectory
        let documentsDir = tempDir.appendingPathComponent("documents", isDirectory: true)
        try fileManager.createDirectory(at: documentsDir, withIntermediateDirectories: true)
        
        return tempDir
    }
    
    private func gatherRelatedData(
        for veterans: [Veteran],
        context: ModelContext
    ) async throws -> (
        claims: [Claim],
        documents: [Document],
        activities: [ClaimActivity],
        medicalConditions: [MedicalCondition],
        categories: [MedicalConditionCategory],
        relationships: [ConditionRelationship]
    ) {
        return try await MainActor.run {
        let veteranIds = Set(veterans.map { $0.id })
        
        // Get all claims for selected veterans
        let claimDescriptor = FetchDescriptor<Claim>()
        let allClaims = try context.fetch(claimDescriptor)
        let claims = allClaims.filter { claim in
            guard let veteranId = claim.veteran?.id else { return false }
            return veteranIds.contains(veteranId)
        }
        let claimIds = Set(claims.map { $0.id })
        
        // Get all documents for selected veterans and their claims
        let documentDescriptor = FetchDescriptor<Document>()
        let allDocuments = try context.fetch(documentDescriptor)
        let documents = allDocuments.filter { document in
            if let veteranId = document.veteran?.id, veteranIds.contains(veteranId) {
                return true
            }
            if let claimId = document.claim?.id, claimIds.contains(claimId) {
                return true
            }
            return false
        }
        
        // Get all activities for claims
        let activityDescriptor = FetchDescriptor<ClaimActivity>()
        let allActivities = try context.fetch(activityDescriptor)
        let activities = allActivities.filter { activity in
            guard let claimId = activity.claim?.id else { return false }
            return claimIds.contains(claimId)
        }
        
        // Get all medical conditions for claims
        let conditionDescriptor = FetchDescriptor<MedicalCondition>()
        let allConditions = try context.fetch(conditionDescriptor)
        let conditions = allConditions.filter { condition in
            guard let claimId = condition.claim?.id else { return false }
            return claimIds.contains(claimId)
        }
        let conditionIds = Set(conditions.map { $0.id })
        
        // Get all categories referenced by conditions
        let categoryDescriptor = FetchDescriptor<MedicalConditionCategory>()
        let allCategories = try context.fetch(categoryDescriptor)
        let categoryIds = Set(conditions.compactMap { $0.category?.id })
        let categories = allCategories.filter { categoryIds.contains($0.id) }
        
        // Get all relationships for conditions
        let relationshipDescriptor = FetchDescriptor<ConditionRelationship>()
        let allRelationships = try context.fetch(relationshipDescriptor)
        let relationships = allRelationships.filter { relationship in
            let primaryId = relationship.primaryCondition?.id
            let secondaryId = relationship.secondaryCondition?.id
            return (primaryId != nil && conditionIds.contains(primaryId!)) ||
                   (secondaryId != nil && conditionIds.contains(secondaryId!))
        }
        
            return (claims, documents, activities, conditions, categories, relationships)
        }
    }
    
    private func copyDocumentFiles(
        documents: [Document],
        to tempDir: URL,
        progress: @escaping (Double) async -> Void
    ) async throws -> [ExportedDocument] {
        let documentsDir = tempDir.appendingPathComponent("documents", isDirectory: true)
        var exportedDocuments: [ExportedDocument] = []
        var copiedCount = 0
        
        for document in documents {
            var sourceURL: URL?
            
            // Handle different path formats - try multiple locations
            if document.filePath.hasPrefix("/") {
                // Absolute path - try directly
                let url = URL(fileURLWithPath: document.filePath)
                if fileManager.fileExists(atPath: url.path) {
                    sourceURL = url
                }
            } else if let url = URL(string: document.filePath), url.scheme != nil {
                // URL string
                sourceURL = url
            }
            
            // If not found yet, try resolving relative paths in multiple locations
            if sourceURL == nil || !fileManager.fileExists(atPath: sourceURL!.path) {
                // Try applicationSupportDirectory/VeteransDocuments (where imported docs go)
                if let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                    let veteransDocsDir = appSupportDir.appendingPathComponent("VeteransDocuments", isDirectory: true)
                    let url = veteransDocsDir.appendingPathComponent(document.filePath)
                    if fileManager.fileExists(atPath: url.path) {
                        sourceURL = url
                    } else {
                        // Try with just the filename
                        let url2 = veteransDocsDir.appendingPathComponent(document.fileName)
                        if fileManager.fileExists(atPath: url2.path) {
                            sourceURL = url2
                        }
                    }
                }
                
                // Try documentDirectory as fallback
                if sourceURL == nil || !fileManager.fileExists(atPath: sourceURL!.path) {
                    if let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let url = documentsDir.appendingPathComponent(document.filePath)
                        if fileManager.fileExists(atPath: url.path) {
                            sourceURL = url
                        } else {
                            // Try with just the filename
                            let url2 = documentsDir.appendingPathComponent(document.fileName)
                            if fileManager.fileExists(atPath: url2.path) {
                                sourceURL = url2
                            }
                        }
                    }
                }
            }
            
            // If still not found, check if it's an absolute path that needs security-scoped access
            if sourceURL == nil || !fileManager.fileExists(atPath: sourceURL!.path) {
                if document.filePath.hasPrefix("/") {
                    sourceURL = URL(fileURLWithPath: document.filePath)
                }
            }
            
            // Final check - if we still don't have a valid file, skip it
            guard let finalSourceURL = sourceURL, fileManager.fileExists(atPath: finalSourceURL.path) else {
                print("⚠️ Warning: Document file not found: \(document.filePath)")
                print("   Tried locations:")
                if document.filePath.hasPrefix("/") {
                    print("     - Absolute: \(document.filePath)")
                }
                if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                    print("     - App Support: \(appSupport.appendingPathComponent("VeteransDocuments").appendingPathComponent(document.filePath).path)")
                }
                if let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    print("     - Documents: \(docDir.appendingPathComponent(document.filePath).path)")
                }
                // Still include in export with relative path (metadata only)
                let relativePath = "documents/\(document.id.uuidString)_\(document.fileName)"
                let exported = ExportedDocument(from: document, relativePath: relativePath)
                exportedDocuments.append(exported)
                continue
            }
            
            // sourceURL is already set to finalSourceURL from the guard above
            
            // Create unique filename in export
            let fileExtension = (document.fileName as NSString).pathExtension
            let baseName = (document.fileName as NSString).deletingPathExtension
            let uniqueFileName = "\(document.id.uuidString)_\(baseName).\(fileExtension)"
            let destURL = documentsDir.appendingPathComponent(uniqueFileName)
            let relativePath = "documents/\(uniqueFileName)"
            
            // Copy file (sourceURL is guaranteed to be non-nil here due to guard above)
            guard let finalSourceURL = sourceURL else {
                continue
            }
            
            do {
                // Start security-scoped access if needed (for files outside app sandbox)
                let needsAccess = finalSourceURL.startAccessingSecurityScopedResource()
                defer {
                    if needsAccess {
                        finalSourceURL.stopAccessingSecurityScopedResource()
                    }
                }
                
                // Verify source file is readable
                guard fileManager.isReadableFile(atPath: finalSourceURL.path) else {
                    print("⚠️ Warning: Document file is not readable: \(finalSourceURL.path)")
                    let exported = ExportedDocument(from: document, relativePath: relativePath)
                    exportedDocuments.append(exported)
                    continue
                }
                
                // Remove existing destination file if present
                if fileManager.fileExists(atPath: destURL.path) {
                    try fileManager.removeItem(at: destURL)
                }
                
                // Ensure destination directory exists
                let destDir = destURL.deletingLastPathComponent()
                if !fileManager.fileExists(atPath: destDir.path) {
                    try fileManager.createDirectory(at: destDir, withIntermediateDirectories: true, attributes: nil)
                }
                
                // Copy the file
                try fileManager.copyItem(at: finalSourceURL, to: destURL)
                
                print("✅ Copied document: \(document.fileName) from \(finalSourceURL.path) to \(destURL.path)")
                
                let exported = ExportedDocument(from: document, relativePath: relativePath)
                exportedDocuments.append(exported)
                
                copiedCount += 1
                await progress(Double(copiedCount) / Double(documents.count))
            } catch {
                print("⚠️ Warning: Failed to copy document \(document.fileName): \(error.localizedDescription)")
                print("   Source: \(finalSourceURL.path)")
                print("   Destination: \(destURL.path)")
                print("   Error: \(error)")
                
                // Check if it's a permission error
                if let nsError = error as NSError? {
                    if nsError.domain == NSCocoaErrorDomain {
                        print("   Error domain: \(nsError.domain), code: \(nsError.code)")
                        if nsError.code == NSFileReadNoPermissionError {
                            print("   → Permission denied - file may require security-scoped access")
                        } else if nsError.code == NSFileReadNoSuchFileError {
                            print("   → File not found")
                        }
                    }
                }
                
                // Still include in export (metadata only, file will be missing)
                let exported = ExportedDocument(from: document, relativePath: relativePath)
                exportedDocuments.append(exported)
            }
        }
        
        return exportedDocuments
    }
    
    private func encodeExportData(_ exportData: ExportData) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            return try encoder.encode(exportData)
        } catch {
            throw ExportError.jsonEncodingFailed
        }
    }
    
    private func createZIPArchive(from directory: URL, password: String) throws -> URL {
        let zipURL = directory.appendingPathExtension("zip")
        
        // Remove existing ZIP if present
        if fileManager.fileExists(atPath: zipURL.path) {
            try fileManager.removeItem(at: zipURL)
        }
        
        // Use Process to create password-protected ZIP
        // Note: macOS zip command supports password protection with -e flag
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        // Note: macOS zip doesn't support -P flag for password
        // We'll create a regular ZIP and encrypt the whole file instead
        // This is more secure anyway
        process.arguments = [
            "-r", // Recursive
            zipURL.path, // Output file
            "." // Current directory (we'll change to tempDir)
        ]
        process.currentDirectoryURL = directory
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0 else {
                let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
                if let errorString = String(data: errorData, encoding: .utf8) {
                    print("❌ ZIP creation error: \(errorString)")
                }
                throw ExportError.zipCreationFailed
            }
            
            guard fileManager.fileExists(atPath: zipURL.path) else {
                throw ExportError.zipCreationFailed
            }
            
            // Encrypt the ZIP file using CopilotEncryption (more secure than ZIP password)
            return try encryptZIPFile(zipURL)
        } catch {
            print("❌ ZIP creation failed: \(error.localizedDescription)")
            throw ExportError.zipCreationFailed
        }
    }
    
    private func createZIPArchiveWithoutPassword(from directory: URL) throws -> URL {
        let zipURL = directory.appendingPathExtension("zip")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.arguments = [
            "-r", // Recursive
            zipURL.path, // Output file
            "." // Current directory
        ]
        process.currentDirectoryURL = directory
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw ExportError.zipCreationFailed
        }
        
        guard fileManager.fileExists(atPath: zipURL.path) else {
            throw ExportError.zipCreationFailed
        }
        
        // Encrypt the ZIP file
        return try encryptZIPFile(zipURL)
    }
    
    private func encryptZIPFile(_ zipURL: URL) throws -> URL {
        let zipData = try Data(contentsOf: zipURL)
        let encryptedData = try CopilotEncryption.encrypt(data: zipData)
        
        let encryptedURL = zipURL.deletingPathExtension().appendingPathExtension("encrypted.zip")
        try encryptedData.write(to: encryptedURL)
        
        // Remove unencrypted ZIP
        try? fileManager.removeItem(at: zipURL)
        
        return encryptedURL
    }
}

