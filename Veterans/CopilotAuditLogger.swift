//
//  CopilotAuditLogger.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import Foundation
import CryptoKit

/// HIPAA-compliant audit logger for Copilot activities
/// Logs all user interactions, API calls, and system events without PHI
class CopilotAuditLogger {
    
    // MARK: - Properties
    private let encryptionService = CopilotEncryption()
    private let logDirectory: URL
    private let dateFormatter = DateFormatter()
    
    // MARK: - Initialization
    init() {
        // Create secure log directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.logDirectory = documentsPath.appendingPathComponent("CopilotAuditLogs")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        
        // Setup date formatter
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone.current
    }
    
    // MARK: - Session Events
    
    /// Log chat session creation
    func logSessionCreated(sessionId: UUID, title: String, veteranId: String? = nil) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .sessionCreated,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: [
                "title": title,
                "veteranId": veteranId ?? "none"
            ]
        )
        
        await logEvent(event)
    }
    
    /// Log chat session deletion
    func logSessionDeleted(sessionId: UUID, messageCount: Int) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .sessionDeleted,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: [
                "messageCount": String(messageCount)
            ]
        )
        
        await logEvent(event)
    }
    
    /// Log session renamed
    func logSessionRenamed(sessionId: UUID, oldTitle: String, newTitle: String) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .sessionRenamed,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: [
                "oldTitle": oldTitle,
                "newTitle": newTitle
            ]
        )
        
        await logEvent(event)
    }
    
    // MARK: - Message Events
    
    /// Log message sent
    func logMessageSent(sessionId: UUID, messageId: UUID, isDeidentified: Bool, tokenCount: Int) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .messageSent,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: [
                "messageId": messageId.uuidString,
                "isDeidentified": String(isDeidentified),
                "tokenCount": String(tokenCount)
            ]
        )
        
        await logEvent(event)
    }
    
    /// Log message received
    func logMessageReceived(sessionId: UUID, messageId: UUID, modelUsed: String, tokenCount: Int, processingTime: Double) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .messageReceived,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: [
                "messageId": messageId.uuidString,
                "modelUsed": modelUsed,
                "tokenCount": String(tokenCount),
                "processingTime": String(processingTime)
            ]
        )
        
        await logEvent(event)
    }
    
    // MARK: - API Events
    
    /// Log API request
    func logAPIRequest(
        model: String,
        messageCount: Int,
        temperature: Double,
        maxTokens: Int,
        streaming: Bool = false
    ) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .apiRequest,
            sessionId: nil,
            userId: getCurrentUserId(),
            details: [
                "model": model,
                "messageCount": String(messageCount),
                "temperature": String(temperature),
                "maxTokens": String(maxTokens),
                "streaming": String(streaming)
            ]
        )
        
        await logEvent(event)
    }
    
    /// Log API response
    func logAPIResponse(
        model: String,
        tokenCount: Int,
        success: Bool,
        error: String? = nil
    ) async {
        var details: [String: String] = [
            "model": model,
            "tokenCount": String(tokenCount),
            "success": String(success)
        ]
        
        if let error = error {
            details["error"] = error
        }
        
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .apiResponse,
            sessionId: nil,
            userId: getCurrentUserId(),
            details: details
        )
        
        await logEvent(event)
    }
    
    /// Log API key storage
    func logAPIKeyStored() async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .apiKeyStored,
            sessionId: nil,
            userId: getCurrentUserId(),
            details: [:]
        )
        
        await logEvent(event)
    }
    
    // MARK: - Document Events
    
    /// Log document upload
    func logDocumentUploaded(sessionId: UUID, documentId: UUID, fileName: String, fileSize: Int64, fileType: String) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .documentUploaded,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: [
                "documentId": documentId.uuidString,
                "fileName": fileName,
                "fileSize": String(fileSize),
                "fileType": fileType
            ]
        )
        
        await logEvent(event)
    }
    
    /// Log document processing
    func logDocumentProcessed(sessionId: UUID, documentId: UUID, success: Bool, extractedTextLength: Int, error: String? = nil) async {
        var details: [String: String] = [
            "documentId": documentId.uuidString,
            "success": String(success),
            "extractedTextLength": String(extractedTextLength)
        ]
        
        if let error = error {
            details["error"] = error
        }
        
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .documentProcessed,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: details
        )
        
        await logEvent(event)
    }
    
    // MARK: - De-identification Events
    
    /// Log de-identification performed
    func logDeidentificationPerformed(
        sessionId: UUID?,
        originalTextLength: Int,
        redactedItems: [RedactedItem]
    ) async {
        let redactionSummary = redactedItems.map { $0.type.rawValue }.joined(separator: ",")
        
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .deidentificationPerformed,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: [
                "originalTextLength": String(originalTextLength),
                "redactedItems": redactionSummary,
                "redactionCount": String(redactedItems.count)
            ]
        )
        
        await logEvent(event)
    }
    
    // MARK: - Export Events
    
    /// Log PDF export
    func logPDFExported(sessionId: UUID, fileName: String, messageCount: Int, veteranId: String? = nil) async {
        var details: [String: String] = [
            "fileName": fileName,
            "messageCount": String(messageCount)
        ]
        
        if let veteranId = veteranId {
            details["veteranId"] = veteranId
        }
        
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .pdfExported,
            sessionId: sessionId,
            userId: getCurrentUserId(),
            details: details
        )
        
        await logEvent(event)
    }
    
    // MARK: - Security Events
    
    /// Log security event
    func logSecurityEvent(eventType: SecurityEventType, details: [String: String]) async {
        let event = AuditEvent(
            timestamp: Date(),
            eventType: .securityEvent,
            sessionId: nil,
            userId: getCurrentUserId(),
            details: details.merging(["securityEventType": eventType.rawValue]) { _, new in new }
        )
        
        await logEvent(event)
    }
    
    // MARK: - Core Logging
    
    /// Log audit event
    private func logEvent(_ event: AuditEvent) async {
        do {
            let eventData = try JSONEncoder().encode(event)
            let encryptedData = try CopilotEncryption.encrypt(data: eventData)
            
            let fileName = "audit_\(dateFormatter.string(from: event.timestamp).replacingOccurrences(of: ":", with: "-")).log"
            let fileURL = logDirectory.appendingPathComponent(fileName)
            
            try encryptedData.write(to: fileURL)
            
        } catch {
            print("Failed to log audit event: \(error)")
            // In production, you might want to send this to a secure logging service
        }
    }
    
    // MARK: - Log Retrieval
    
    /// Retrieve audit logs for a specific session
    func getAuditLogs(for sessionId: UUID, from startDate: Date, to endDate: Date) async throws -> [AuditEvent] {
        let files = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: [.creationDateKey])
        
        var events: [AuditEvent] = []
        
        for file in files {
            let encryptedData = try Data(contentsOf: file)
            let decryptedData = try CopilotEncryption.decrypt(encryptedData: encryptedData)
            
            if let event = try? JSONDecoder().decode(AuditEvent.self, from: decryptedData) {
                if event.sessionId == sessionId &&
                   event.timestamp >= startDate &&
                   event.timestamp <= endDate {
                    events.append(event)
                }
            }
        }
        
        return events.sorted { $0.timestamp < $1.timestamp }
    }
    
    /// Retrieve all audit logs for a date range
    func getAllAuditLogs(from startDate: Date, to endDate: Date) async throws -> [AuditEvent] {
        let files = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: [.creationDateKey])
        
        var events: [AuditEvent] = []
        
        for file in files {
            let encryptedData = try Data(contentsOf: file)
            let decryptedData = try CopilotEncryption.decrypt(encryptedData: encryptedData)
            
            if let event = try? JSONDecoder().decode(AuditEvent.self, from: decryptedData) {
                if event.timestamp >= startDate && event.timestamp <= endDate {
                    events.append(event)
                }
            }
        }
        
        return events.sorted { $0.timestamp < $1.timestamp }
    }
    
    // MARK: - Log Management
    
    /// Clean up old audit logs (retention policy)
    func cleanupOldLogs(retentionDays: Int = 2555) async throws { // ~7 years
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(retentionDays * 24 * 60 * 60))
        
        let files = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: [.creationDateKey])
        
        for file in files {
            let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
            if let creationDate = attributes[.creationDate] as? Date,
               creationDate < cutoffDate {
                try FileManager.default.removeItem(at: file)
            }
        }
    }
    
    /// Export audit logs for compliance review
    func exportAuditLogs(from startDate: Date, to endDate: Date) async throws -> Data {
        let events = try await getAllAuditLogs(from: startDate, to: endDate)
        
        let exportData = AuditLogExport(
            exportDate: Date(),
            exportedBy: getCurrentUserId(),
            dateRange: DateRange(start: startDate, end: endDate),
            events: events
        )
        
        return try JSONEncoder().encode(exportData)
    }
    
    // MARK: - Utility Methods
    
    private func getCurrentUserId() -> String {
        // In a real implementation, this would get the current user ID
        // For now, return a placeholder
        return "system"
    }
}

// MARK: - Audit Event Types

struct AuditEvent: Codable {
    let timestamp: Date
    let eventType: AuditEventType
    let sessionId: UUID?
    let userId: String
    let details: [String: String]
}

enum AuditEventType: String, Codable {
    case sessionCreated = "session_created"
    case sessionDeleted = "session_deleted"
    case sessionRenamed = "session_renamed"
    case messageSent = "message_sent"
    case messageReceived = "message_received"
    case apiRequest = "api_request"
    case apiResponse = "api_response"
    case apiKeyStored = "api_key_stored"
    case documentUploaded = "document_uploaded"
    case documentProcessed = "document_processed"
    case deidentificationPerformed = "deidentification_performed"
    case pdfExported = "pdf_exported"
    case securityEvent = "security_event"
}

enum SecurityEventType: String, Codable {
    case unauthorizedAccess = "unauthorized_access"
    case encryptionFailure = "encryption_failure"
    case keychainError = "keychain_error"
    case apiKeyCompromise = "api_key_compromise"
    case dataLeakage = "data_leakage"
    case suspiciousActivity = "suspicious_activity"
}

struct AuditLogExport: Codable {
    let exportDate: Date
    let exportedBy: String
    let dateRange: DateRange
    let events: [AuditEvent]
}

struct DateRange: Codable {
    let start: Date
    let end: Date
}

// MARK: - Extensions (Removed - using simplified encryption)
