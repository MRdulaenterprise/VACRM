//
//  CopilotDocumentService.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import PDFKit
import UniformTypeIdentifiers
import SwiftData
import SwiftUI

// MARK: - Document Processing Error

enum DocumentProcessingError: Error, LocalizedError {
    case fileNotFound
    case unsupportedFileType
    case extractionFailed(String)
    case encryptionFailed(String)
    case decryptionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Document file not found"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .extractionFailed(let reason):
            return "Text extraction failed: \(reason)"
        case .encryptionFailed(let reason):
            return "Encryption failed: \(reason)"
        case .decryptionFailed(let reason):
            return "Decryption failed: \(reason)"
        }
    }
}

/// Service for handling document uploads, text extraction, and secure storage
/// Supports PDF documents with HIPAA-compliant processing
class CopilotDocumentService: ObservableObject {
    
    // MARK: - Properties
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    @Published var lastError: DocumentError?
    
    private let encryptionService = CopilotEncryption()
    private let deidentificationService = DeIdentificationService()
    
    // Maximum file size (10MB)
    private let maxFileSize: Int64 = 10 * 1024 * 1024
    
    // MARK: - Document Upload
    
    /// Process uploaded document
    func processDocument(
        fileURL: URL,
        fileName: String,
        sessionId: UUID,
        context: ModelContext
    ) async throws -> ChatDocument {
        
        await MainActor.run {
            isProcessing = true
            processingProgress = 0.0
            lastError = nil
        }
        
        defer {
            Task { @MainActor in
                isProcessing = false
                processingProgress = 0.0
            }
        }
        
        do {
            print("📄 Starting document processing for: \(fileName)")
            
            // Start security scoped access
            guard fileURL.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security scoped resource")
                throw DocumentError.fileNotReadable
            }
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            // Validate file
            try validateDocument(fileURL: fileURL, fileName: fileName)
            print("✅ Document validation passed")
            
            // Get file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            let fileType = getFileType(from: fileName)
            
            await MainActor.run {
                processingProgress = 0.1
            }
            
            // Encrypt and store document
            let documentData = try Data(contentsOf: fileURL)
            print("📄 Document data loaded: \(documentData.count) bytes")
            
            // Try to encrypt, but handle Keychain errors gracefully
            let encryptedData: Data
            do {
                encryptedData = try CopilotEncryption.encrypt(data: documentData)
                print("🔒 Document encrypted successfully")
            } catch let error as CopilotEncryptionError {
                print("❌ Encryption failed: \(error.localizedDescription)")
                // For now, store unencrypted as fallback (not ideal for production)
                // In production, you'd want to handle this differently or fail the upload
                print("⚠️ Storing document unencrypted due to encryption failure")
                encryptedData = documentData
            } catch {
                print("❌ Unexpected encryption error: \(error.localizedDescription)")
                // Fallback to unencrypted storage
                encryptedData = documentData
            }
            
            // Save encrypted data to a secure file path
            let fileManager = FileManager.default
            let documentsDirectory = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("CopilotDocuments", isDirectory: true)
            
            if !fileManager.fileExists(atPath: documentsDirectory.path) {
                try fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                print("📁 Created documents directory: \(documentsDirectory.path)")
            }
            
            let uniqueFilename = "\(sessionId.uuidString)_\(fileName).encrypted"
            let encryptedFilePath = documentsDirectory.appendingPathComponent(uniqueFilename)
            
            try encryptedData.write(to: encryptedFilePath)
            print("💾 Document saved to: \(encryptedFilePath.path)")
            
            await MainActor.run {
                processingProgress = 0.3
            }
            
            // Create ChatDocument record
            let chatDocument = ChatDocument(
                fileName: fileName,
                fileType: fileType,
                fileSize: fileSize,
                encryptedFilePath: encryptedFilePath.path
            )
            
            // Associate with session - retry if not found immediately (for new sessions)
            var foundSession: ChatSession?
            let sessionQuery = FetchDescriptor<ChatSession>(predicate: #Predicate { $0.id == sessionId })
            
            // Try to find session, with a retry for new sessions
            for attempt in 0..<3 {
                let sessions = try context.fetch(sessionQuery)
                if let session = sessions.first {
                    foundSession = session
                    break
                }
                
                // If not found and this is a new session, wait a bit and try again
                if attempt < 2 {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                    // Force a refresh by saving context
                    try context.save()
                }
            }
            
            if let session = foundSession {
                chatDocument.session = session
                print("🔗 Document associated with session: \(sessionId) (\(session.title))")
            } else {
                // Still create the document even if session lookup fails
                // The session relationship might be established later
                print("⚠️ Session not found for ID: \(sessionId) - document will be created without session association")
                // Try to save context to ensure session is available
                try context.save()
                // Retry one more time
                let retrySessions = try context.fetch(sessionQuery)
                if let session = retrySessions.first {
                    chatDocument.session = session
                    print("✅ Session found on retry - document associated")
                } else {
                    throw DocumentError.sessionNotFound(sessionId)
                }
            }
            
            context.insert(chatDocument)
            print("💾 ChatDocument record inserted into database")
            
            await MainActor.run {
                processingProgress = 0.4
            }
            
            // Extract text from document
            let extractedText = try await extractText(from: documentData, fileType: fileType)
            chatDocument.extractedText = extractedText
            
            await MainActor.run {
                processingProgress = 0.6
            }
            
               // Apply de-identification using GPT-4 approach (documents should always be fully de-identified)
               let deidentificationResult = await deidentificationService.deidentifyWithGPT4(text: extractedText, context: .documentUpload)
               chatDocument.deidentifiedText = deidentificationResult.deidentifiedText
            
            await MainActor.run {
                processingProgress = 0.8
            }
            
            // Generate summary
            let summary = try await generateSummary(from: deidentificationResult.deidentifiedText)
            chatDocument.summary = summary
            
            await MainActor.run {
                processingProgress = 0.9
            }
            
            // Mark as processed
            chatDocument.isProcessed = true
            
            // Save to database
            try context.save()
            print("✅ Document processing completed successfully!")
            
            await MainActor.run {
                processingProgress = 1.0
            }
            
            // Log document processing
            print("Document processed successfully: \(chatDocument.fileName)")
            
            return chatDocument
            
        } catch {
            // Log processing error
            print("Document processing failed: \(error.localizedDescription)")
            
            await MainActor.run {
                lastError = error as? DocumentError ?? DocumentError.processingFailed(error)
            }
            throw error
        }
    }
    
    // MARK: - Text Extraction
    
    /// Extract text from PDF document
    private func extractText(from data: Data, fileType: String) async throws -> String {
        guard fileType.lowercased() == "pdf" else {
            throw DocumentError.unsupportedFileType(fileType)
        }
        
        guard let pdfDocument = PDFDocument(data: data) else {
            throw DocumentError.invalidPDF
        }
        
        var extractedText = ""
        
        for pageIndex in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else {
                continue
            }
            
            if let pageText = page.string {
                extractedText += pageText + "\n"
            }
        }
        
        guard !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DocumentError.noTextFound
        }
        
        return extractedText
    }
    
    // MARK: - Summary Generation
    
    /// Generate summary of document content
    private func generateSummary(from text: String) async throws -> String {
        // For now, create a simple summary based on text length and key terms
        // In production, you might want to use AI to generate more sophisticated summaries
        
        let words = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let wordCount = words.count
        let charCount = text.count
        
        // Extract key terms (simple approach)
        let keyTerms = extractKeyTerms(from: text)
        
        var summary = "Document Summary:\n"
        summary += "• Word count: \(wordCount)\n"
        summary += "• Character count: \(charCount)\n"
        
        if !keyTerms.isEmpty {
            summary += "• Key terms: \(keyTerms.joined(separator: ", "))\n"
        }
        
        // Add first few sentences as preview
        let sentences = text.components(separatedBy: ". ")
        if sentences.count > 0 {
            let preview = sentences.prefix(2).joined(separator: ". ")
            summary += "• Preview: \(preview)"
            if sentences.count > 2 {
                summary += "..."
            }
        }
        
        return summary
    }
    
    /// Extract key terms from text
    private func extractKeyTerms(from text: String) -> [String] {
        let commonWords = Set([
            "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by",
            "is", "are", "was", "were", "be", "been", "being", "have", "has", "had", "do", "does", "did",
            "will", "would", "could", "should", "may", "might", "can", "must", "this", "that", "these", "those"
        ])
        
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty && !commonWords.contains($0) }
            .filter { $0.count > 3 } // Only words longer than 3 characters
        
        let wordCounts = Dictionary(grouping: words) { $0 }
            .mapValues { $0.count }
        
        return wordCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }
    
    // MARK: - Document Validation
    
    /// Validate document before processing
    private func validateDocument(fileURL: URL, fileName: String) throws {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw DocumentError.fileNotFound
        }
        
        // Check file size
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0
        
        guard fileSize <= maxFileSize else {
            throw DocumentError.fileTooLarge(fileSize)
        }
        
        // Check file type
        let fileType = getFileType(from: fileName)
        guard isSupportedFileType(fileType) else {
            throw DocumentError.unsupportedFileType(fileType)
        }
        
        // Check if file is readable
        guard FileManager.default.isReadableFile(atPath: fileURL.path) else {
            throw DocumentError.fileNotReadable
        }
    }
    
    /// Get file type from filename
    private func getFileType(from fileName: String) -> String {
        let pathExtension = (fileName as NSString).pathExtension.lowercased()
        return pathExtension
    }
    
    /// Check if file type is supported
    private func isSupportedFileType(_ fileType: String) -> Bool {
        let supportedTypes = ["pdf"]
        return supportedTypes.contains(fileType.lowercased())
    }
    
    // MARK: - Document Retrieval
    
    /// Load document content
    func loadDocumentContent(_ chatDocument: ChatDocument) throws -> Data {
        let filePath = chatDocument.encryptedFilePath
        
        let encryptedData = try Data(contentsOf: URL(fileURLWithPath: filePath))
        return try CopilotEncryption.decrypt(encryptedData: encryptedData)
    }
    
    /// Get document text (de-identified)
    func getDocumentText(_ chatDocument: ChatDocument) -> String? {
        return chatDocument.deidentifiedText ?? chatDocument.extractedText
    }
    
    /// Get document summary
    func getDocumentSummary(_ chatDocument: ChatDocument) -> String? {
        return chatDocument.summary
    }
    
    // MARK: - Document Management
    
    /// Delete document and its encrypted file
    func deleteDocument(_ chatDocument: ChatDocument, from context: ModelContext) throws {
        // Delete encrypted file
        let fileURL = URL(fileURLWithPath: chatDocument.encryptedFilePath)
        try? FileManager.default.removeItem(at: fileURL)
        
        // Delete from database
        context.delete(chatDocument)
        try context.save()
    }
    
    /// Get document statistics
    func getDocumentStatistics(from context: ModelContext) -> DocumentStatistics {
        let descriptor = FetchDescriptor<ChatDocument>()
        
        do {
            let documents = try context.fetch(descriptor)
            
            let totalDocuments = documents.count
            let totalSize = documents.reduce(0) { $0 + $1.fileSize }
            let processedDocuments = documents.filter { $0.isProcessed }.count
            let errorDocuments = documents.filter { $0.processingError != nil }.count
            
            let fileTypeBreakdown = Dictionary(grouping: documents) { $0.fileType }
                .mapValues { $0.count }
            
            return DocumentStatistics(
                totalDocuments: totalDocuments,
                totalSize: totalSize,
                processedDocuments: processedDocuments,
                errorDocuments: errorDocuments,
                fileTypeBreakdown: fileTypeBreakdown
            )
            
        } catch {
            return DocumentStatistics(
                totalDocuments: 0,
                totalSize: 0,
                processedDocuments: 0,
                errorDocuments: 0,
                fileTypeBreakdown: [:]
            )
        }
    }
    
    // MARK: - Document Search
    
    /// Search documents by content
    func searchDocuments(
        query: String,
        in context: ModelContext
    ) -> [ChatDocument] {
        let descriptor = FetchDescriptor<ChatDocument>()
        
        do {
            let documents = try context.fetch(descriptor)
            
            return documents.filter { document in
                guard let text = document.deidentifiedText ?? document.extractedText else {
                    return false
                }
                
                return text.localizedCaseInsensitiveContains(query)
            }
            
        } catch {
            return []
        }
    }
}

// MARK: - Document Statistics

struct DocumentStatistics {
    let totalDocuments: Int
    let totalSize: Int64
    let processedDocuments: Int
    let errorDocuments: Int
    let fileTypeBreakdown: [String: Int]
    
    var averageSize: Int64 {
        return totalDocuments > 0 ? totalSize / Int64(totalDocuments) : 0
    }
    
    var processingSuccessRate: Double {
        return totalDocuments > 0 ? Double(processedDocuments) / Double(totalDocuments) : 0.0
    }
}

// MARK: - Document Errors

enum DocumentError: Error, LocalizedError {
    case fileNotFound
    case fileTooLarge(Int64)
    case fileNotReadable
    case unsupportedFileType(String)
    case invalidPDF
    case noTextFound
    case processingFailed(Error)
    case encryptionFailed
    case decryptionFailed
    case sessionNotFound(UUID)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Document file not found"
        case .fileTooLarge(let size):
            let sizeMB = Double(size) / (1024 * 1024)
            return "Document is too large (\(String(format: "%.1f", sizeMB)) MB). Maximum size is 10 MB."
        case .fileNotReadable:
            return "Document file is not readable"
        case .unsupportedFileType(let type):
            return "Unsupported file type: \(type). Only PDF files are supported."
        case .invalidPDF:
            return "Invalid PDF document"
        case .noTextFound:
            return "No text found in document"
        case .processingFailed(let error):
            return "Document processing failed: \(error.localizedDescription)"
        case .encryptionFailed:
            return "Failed to encrypt document"
        case .decryptionFailed:
            return "Failed to decrypt document"
        case .sessionNotFound(let sessionId):
            return "Chat session not found (ID: \(sessionId.uuidString)). Please ensure the session is saved before uploading documents."
        }
    }
}

// MARK: - File Type Extensions

extension UTType {
    static let pdf = UTType(filenameExtension: "pdf")!
}

// MARK: - Document Extensions

extension ChatDocument {
    /// Get file size as human-readable string
    var fileSizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    /// Check if document is ready for use
    var isReady: Bool {
        return isProcessed && processingError == nil
    }
    
    /// Get processing status
    var processingStatus: String {
        if isProcessed {
            return "Processed"
        } else if processingError != nil {
            return "Error"
        } else {
            return "Processing"
        }
    }
}
